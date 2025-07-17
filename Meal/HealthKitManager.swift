//
//  HealthKitManager.swift
//  Meal
//
//  Created by shh on 19/05/2025.
//


//
//  HealthKitManager.swift
//  MealMood
//
//  Created by shh on 19/05/2025.
//


import HealthKit
import SwiftUI

class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()
    @Published var sleepData: [HKCategorySample] = []
    @Published var heartRateData: [HKQuantitySample] = []
    @Published var hrvData: [HKQuantitySample] = []
    @Published var hasAccess: Bool = false
    
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit not available on this device")
            return
        }
        
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            HKObjectType.quantityType(forIdentifier: .restingHeartRate)!
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            DispatchQueue.main.async {
                self.hasAccess = success
                if success {
                    self.fetchRecentHealthData()
                } else if let error = error {
                    print("HealthKit authorization error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func fetchRecentHealthData() {
        fetchSleepData()
        fetchHeartRateData()
        fetchHRVData()
    }
    
    private func fetchSleepData() {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            return
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: sleepType, predicate: nil, limit: 7, sortDescriptors: [sortDescriptor]) { query, samples, error in
            guard let samples = samples as? [HKCategorySample], error == nil else {
                print("Error fetching sleep data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                self.sleepData = samples
                self.processSleepData(samples)
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchHeartRateData() {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            return
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let predicate = HKQuery.predicateForSamples(withStart: Date().addingTimeInterval(-86400 * 3), end: Date(), options: .strictEndDate)
        let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: 100, sortDescriptors: [sortDescriptor]) { query, samples, error in
            guard let samples = samples as? [HKQuantitySample], error == nil else {
                print("Error fetching heart rate data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                self.heartRateData = samples
                self.processHeartRateData(samples)
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchHRVData() {
        guard let hrvType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
            return
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let predicate = HKQuery.predicateForSamples(withStart: Date().addingTimeInterval(-86400 * 3), end: Date(), options: .strictEndDate)
        let query = HKSampleQuery(sampleType: hrvType, predicate: predicate, limit: 100, sortDescriptors: [sortDescriptor]) { query, samples, error in
            guard let samples = samples as? [HKQuantitySample], error == nil else {
                print("Error fetching HRV data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                self.hrvData = samples
                self.processHRVData(samples)
            }
        }
        
        healthStore.execute(query)
    }
    
    private func processSleepData(_ samples: [HKCategorySample]) {
        for sample in samples {
            let hours = Int(sample.endDate.timeIntervalSince(sample.startDate) / 3600)
            let minutes = (Int(sample.endDate.timeIntervalSince(sample.startDate)) % 3600) / 60
            
            // Determine sleep quality based on duration and time
            var quality: SleepQuality
            if hours >= 7 {
                quality = .excellent
            } else if hours >= 6 {
                quality = .good
            } else if hours >= 5 {
                quality = .fair
            } else {
                quality = .poor
            }
            
            let sleepData = SleepData(hours: hours, minutes: minutes, quality: quality)
            let healthData = HealthData(sleep: sleepData, heartRate: nil, hrv: nil)
            
            let event = TimelineEvent(
                id: UUID(),
                type: .sleep,
                timestamp: sample.startDate,
                title: "Sleep",
                subtitle: "\(hours)h \(minutes)m",
                icon: "bed.double",
                healthData: healthData
            )
            
            DispatchQueue.main.async {
                if !(AppState.shared.timelineEvents.contains { $0.timestamp == event.timestamp }) {
                    AppState.shared.timelineEvents.append(event)
                    AppState.shared.timelineEvents.sort { $0.timestamp > $1.timestamp }
                }
            }
        }
    }
    
    private func processHeartRateData(_ samples: [HKQuantitySample]) {
        for sample in samples {
            let heartRateUnit = HKUnit(from: "count/min")
            let value = sample.quantity.doubleValue(for: heartRateUnit)
            
            // Determine if this is resting heart rate (between 1-4 AM)
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: sample.startDate)
            let isResting = hour >= 1 && hour <= 4
            
            let heartRateData = HeartRateData(value: value, isResting: isResting)
            let healthData = HealthData(sleep: nil, heartRate: heartRateData, hrv: nil)
            
            let event = TimelineEvent(
                id: UUID(),
                type: .health,
                timestamp: sample.startDate,
                title: isResting ? "Resting HR" : "Heart Rate",
                subtitle: "\(Int(value)) bpm",
                icon: "heart",
                healthData: healthData
            )
            
            DispatchQueue.main.async {
                if !(AppState.shared.timelineEvents.contains { $0.timestamp == event.timestamp }) {
                    AppState.shared.timelineEvents.append(event)
                    AppState.shared.timelineEvents.sort { $0.timestamp > $1.timestamp }
                }
            }
        }
    }
    
    private func processHRVData(_ samples: [HKQuantitySample]) {
        for sample in samples {
            let value = sample.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))
            
            let healthData = HealthData(sleep: nil, heartRate: nil, hrv: value)
            
            let event = TimelineEvent(
                id: UUID(),
                type: .health,
                timestamp: sample.startDate,
                title: "HRV",
                subtitle: String(format: "%.1f ms", value),
                icon: "waveform.path.ecg",
                healthData: healthData
            )
            
            DispatchQueue.main.async {
                if !(AppState.shared.timelineEvents.contains { $0.timestamp == event.timestamp }) {
                    AppState.shared.timelineEvents.append(event)
                    AppState.shared.timelineEvents.sort { $0.timestamp > $1.timestamp }
                }
            }
        }
    }
}

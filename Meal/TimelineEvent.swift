//
//  TimelineEvent.swift
//  Meal
//
//  Created by shh on 19/05/2025.
//


//
//  TimelineEvent.swift
//  MealMood
//
//  Created by shh on 19/05/2025.
//


import Foundation
import SwiftUICore

struct TimelineEvent: Identifiable, Equatable {
    static func == (lhs: TimelineEvent, rhs: TimelineEvent) -> Bool {
        return false
    }
    
    let id: UUID
    let type: EventType
    let timestamp: Date
    let title: String
    let subtitle: String
    let icon: String
    var healthData: HealthData?
    var insight: String?
}

enum EventType {
    case meal, mood, sleep, health
    
    var color: Color {
        switch self {
        case .meal: return Color.orange
        case .mood: return Color.purple
        case .sleep: return Color.blue
        case .health: return Color.green
        }
    }
}

struct HealthData {
    var sleep: SleepData?
    var heartRate: HeartRateData?
    var hrv: Double?
}

struct SleepData {
    let hours: Int
    let minutes: Int
    let quality: SleepQuality
    
    var duration: TimeInterval {
        TimeInterval(hours * 3600 + minutes * 60)
    }
}

enum SleepQuality {
    case excellent, good, fair, poor
    
    var color: Color {
        switch self {
        case .excellent: return Color.green
        case .good: return Color.blue
        case .fair: return Color.orange
        case .poor: return Color.red
        }
    }
}

struct HeartRateData {
    let value: Double
    let isResting: Bool
    
    var bpm: Int {
        Int(value.rounded())
    }
    
    var color: Color {
        if isResting {
            return value < 60 ? .blue : (value < 80 ? .green : .orange)
        } else {
            return value < 100 ? .green : (value < 120 ? .orange : .red)
        }
    }
}

class TimelineEngine {
    static func generateInsight(from events: [TimelineEvent]) -> String? {
        // Simple pattern detection
        guard events.count >= 3 else { return nil }
        
        let meals = events.filter { $0.type == .meal }
        let moods = events.filter { $0.type == .mood }
        
        // Look for meals followed by negative moods
        for i in 0..<meals.count {
            let meal = meals[i]
            let nextMoods = moods.filter { $0.timestamp > meal.timestamp && $0.timestamp < meal.timestamp.addingTimeInterval(4 * 3600) }
            
            let negativeMoods = nextMoods.filter { mood in
                let moodState = MoodState(rawValue: mood.title) ?? .neutral
                return moodState == .sad || moodState == .angry || moodState == .anxious || moodState == .tired
            }
            
            if negativeMoods.count >= 2 {
                return "\(meal.title) may cause \(negativeMoods[0].title.lowercased()) feelings"
            }
        }
        
        // Look for sleep quality patterns
        let sleepEvents = events.filter { $0.type == .sleep }
        for sleep in sleepEvents {
            let previousMeals = meals.filter { $0.timestamp < sleep.timestamp && $0.timestamp > sleep.timestamp.addingTimeInterval(-6 * 3600) }
            
            if !previousMeals.isEmpty, let sleepData = sleep.healthData?.sleep, sleepData.quality == .poor {
                return "Late \(previousMeals[0].title) may affect sleep quality"
            }
        }
        
        return nil
    }
}

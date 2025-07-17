//
//  TimelineView.swift
//  Meal
//
//  Created by shh on 19/05/2025.
//


//
//  TimelineView.swift
//  MealMood
//
//  Created by shh on 19/05/2025.
//


import SwiftUI

struct TimelineView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var healthKitManager: HealthKitManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(appState.timelineEvents) { event in
                    TimelineEventCard(event: event)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    
                    if event != appState.timelineEvents.last {
                        TimelineConnector()
                            .frame(height: 30)
                            .padding(.leading, 30)
                    }
                }
                
                if appState.timelineEvents.isEmpty {
                    emptyTimelineView()
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Your Timeline")
        .onAppear {
            healthKitManager.fetchRecentHealthData()
        }
    }
    
    private func emptyTimelineView() -> some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 60))
                .foregroundColor(Color("AccentColor"))
            
            Text("Your timeline is empty")
                .font(.title2)
            
            Text("Start by logging meals and moods to see how they affect you")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal, 40)
        }
        .padding(.top, 100)
    }
}

struct TimelineEventCard: View {
    let event: TimelineEvent
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: event.icon)
                .font(.title)
                .foregroundColor(event.type.color)
                .frame(width: 50, height: 50)
                .background(event.type.color.opacity(0.2))
                .cornerRadius(25)
                .padding(.top, 5)
            
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(event.title)
                        .font(.headline)
                    
                    Spacer()
                    
                    Text(event.timestamp.formatted(date: .omitted, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Text(event.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                if let healthData = event.healthData {
                    HealthDataView(data: healthData)
                }
                
                if let insight = event.insight {
                    InsightBadge(insight: insight)
                }
            }
        }
        .padding()
        .background(Color("appPrimaryColor").opacity(0.05))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct TimelineConnector: View {
    var body: some View {
        Rectangle()
            .fill(Color("AccentColor").opacity(0.3))
            .frame(width: 2)
    }
}

struct HealthDataView: View {
    let data: HealthData
    
    var body: some View {
        HStack(spacing: 15) {
            if let sleep = data.sleep {
                HStack(spacing: 5) {
                    Image(systemName: "bed.double")
                    Text("\(sleep.hours)h \(sleep.minutes)m")
                        .font(.caption)
                }
                .foregroundColor(sleep.quality.color)
            }
            
            if let heartRate = data.heartRate {
                HStack(spacing: 5) {
                    Image(systemName: "heart")
                    Text("\(heartRate)bpm")
                        .font(.caption)
                }
                .foregroundColor(heartRate.color)
            }
        }
        .padding(.top, 5)
    }
}

struct InsightBadge: View {
    let insight: String
    
    var body: some View {
        HStack {
            Image(systemName: "lightbulb")
            Text(insight)
                .font(.caption)
        }
        .padding(8)
        .background(Color("AccentColor").opacity(0.2))
        .cornerRadius(10)
        .padding(.top, 5)
    }
}

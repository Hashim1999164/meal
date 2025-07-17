//
//  AppState.swift
//  Meal
//
//  Created by shh on 19/05/2025.
//


//
//  AppState.swift
//  MealMood
//
//  Created by shh on 19/05/2025.
//


import Combine
import SwiftUI

final class AppState: ObservableObject {
    
    static let shared = AppState()

    @Published var currentView: AppView = .mealCapture
    @Published var meals: [Meal] = []
    @Published var moodEntries: [MoodEntry] = []
    @Published var timelineEvents: [TimelineEvent] = []
    @Published var isLoading = false
    @Published var hasCameraAccess = false
    @Published var hasHealthKitAccess = false
    
    func addMeal(_ meal: Meal) {
        meals.append(meal)
        generateTimelineEvent(for: meal)
    }
    
    func addMoodEntry(_ entry: MoodEntry) {
        moodEntries.append(entry)
        generateTimelineEvent(for: entry)
    }
    
    private func generateTimelineEvent(for meal: Meal) {
        let event = TimelineEvent(
            id: UUID(),
            type: .meal,
            timestamp: meal.timestamp,
            title: meal.foodType,
            subtitle: meal.description,
            icon: meal.foodType.foodIcon
        )
        timelineEvents.append(event)
        timelineEvents.sort { $0.timestamp > $1.timestamp }
    }
    
    private func generateTimelineEvent(for mood: MoodEntry) {
        let event = TimelineEvent(
            id: UUID(),
            type: .mood,
            timestamp: mood.timestamp,
            title: mood.moodState.rawValue,
            subtitle: "\(mood.moodState.emoji) \(mood.intensity)%",
            icon: mood.moodState.iconName
        )
        timelineEvents.append(event)
        timelineEvents.sort { $0.timestamp > $1.timestamp }
    }
}

enum AppView {
    case mealCapture, moodTracker, timeline, insights
}

extension AppView {
    var title: String {
        switch self {
        case .mealCapture: return "Log Meal"
        case .moodTracker: return "Mood Check"
        case .timeline: return "Your Timeline"
        case .insights: return "Insights"
        }
    }
    
    var icon: String {
        switch self {
        case .mealCapture: return "camera"
        case .moodTracker: return "face.smiling"
        case .timeline: return "chart.line.uptrend.xyaxis"
        case .insights: return "lightbulb"
        }
    }
}

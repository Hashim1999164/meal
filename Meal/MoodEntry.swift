//
//  MoodEntry.swift
//  Meal
//
//  Created by shh on 19/05/2025.
//


//
//  MoodEntry.swift
//  MealMood
//
//  Created by shh on 19/05/2025.
//


import Foundation

struct MoodEntry: Identifiable, Equatable {
    let id: UUID
    let moodState: MoodState
    let intensity: Int
    let timestamp: Date
    let source: MoodSource
    
    static func == (lhs: MoodEntry, rhs: MoodEntry) -> Bool {
        lhs.id == rhs.id
    }
}

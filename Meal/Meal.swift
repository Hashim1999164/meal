//
//  Meal.swift
//  Meal
//
//  Created by shh on 19/05/2025.
//


//
//  Meal.swift
//  MealMood
//
//  Created by shh on 19/05/2025.
//


import UIKit

struct Meal: Identifiable, Equatable {
    let id: UUID
    let image: UIImage
    let foodType: String
    let description: String
    let timestamp: Date
    
    static func == (lhs: Meal, rhs: Meal) -> Bool {
        lhs.id == rhs.id
    }
}

extension String {
    var foodIcon: String {
        let lowercased = self.lowercased()
        
        if lowercased.contains("pizza") { return "🍕" }
        if lowercased.contains("burger") { return "🍔" }
        if lowercased.contains("pasta") || lowercased.contains("noodle") { return "🍝" }
        if lowercased.contains("salad") { return "🥗" }
        if lowercased.contains("sushi") { return "🍣" }
        if lowercased.contains("rice") { return "🍚" }
        if lowercased.contains("soup") { return "🍲" }
        if lowercased.contains("sandwich") { return "🥪" }
        if lowercased.contains("fruit") { return "🍎" }
        if lowercased.contains("vegetable") { return "🥦" }
        if lowercased.contains("meat") { return "🍖" }
        if lowercased.contains("fish") { return "🐟" }
        if lowercased.contains("egg") { return "🥚" }
        if lowercased.contains("bread") { return "🍞" }
        if lowercased.contains("cake") || lowercased.contains("dessert") { return "🍰" }
        if lowercased.contains("coffee") || lowercased.contains("tea") { return "☕" }
        
        return "🍽"
    }
}

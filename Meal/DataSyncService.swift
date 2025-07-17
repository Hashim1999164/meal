//
//  DataSyncService.swift
//  Meal
//
//  Created by shh on 19/05/2025.
//


//
//  DataSyncService.swift
//  MealMood
//
//  Created by shh on 19/05/2025.
//


import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class DataSyncService: ObservableObject {
    private var db = Firestore.firestore()
    private var userId: String?
    private var listener: ListenerRegistration?
    
    func initialize() {
        setupAuth()
    }
    
    private func setupAuth() {
        Auth.auth().signInAnonymously { authResult, error in
            if let error = error {
              print("🔥 Firebase auth error: \(error.localizedDescription)")
              return
            }
            self.userId = authResult?.user.uid
            print("✅ Firebase anonymous user ID: \(self.userId ?? "unknown")")
            self.setupListeners()
          }
    }
    
    private func setupListeners() {
        guard let userId = userId else { return }
        
        // Sync meals
        listener = db.collection("users").document(userId).collection("meals")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                let meals = documents.compactMap { document -> Meal? in
                    do {
                        return try document.data(as: Meal.self)
                    } catch {
                        print("Error decoding meal: \(error)")
                        return nil
                    }
                }
                
                DispatchQueue.main.async {
                    AppState.shared.meals = meals
                }
            }
    }
    
    func syncMeal(_ meal: Meal) {
        guard let userId = userId else { return }
        
        do {
            try db.collection("users").document(userId).collection("meals").document(meal.id.uuidString).setData(from: meal)
        } catch {
            print("Error syncing meal: \(error.localizedDescription)")
        }
    }
    
    func syncMoodEntry(_ entry: MoodEntry) {
        guard let userId = userId else { return }
        
        do {
            try db.collection("users").document(userId).collection("moodEntries").document(entry.id.uuidString).setData(from: entry)
        } catch {
            print("Error syncing mood entry: \(error.localizedDescription)")
        }
    }
}

extension Meal: Codable {
    enum CodingKeys: String, CodingKey {
        case id, foodType, description, timestamp
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        foodType = try container.decode(String.self, forKey: .foodType)
        description = try container.decode(String.self, forKey: .description)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        
        // Image is not stored in Firestore
        image = UIImage(systemName: "photo")!
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(foodType, forKey: .foodType)
        try container.encode(description, forKey: .description)
        try container.encode(timestamp, forKey: .timestamp)
    }
}

extension MoodEntry: Codable {
    enum CodingKeys: String, CodingKey {
        case id, moodState, intensity, timestamp, source
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        moodState = try container.decode(MoodState.self, forKey: .moodState)
        intensity = try container.decode(Int.self, forKey: .intensity)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        source = try container.decode(MoodSource.self, forKey: .source)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(moodState, forKey: .moodState)
        try container.encode(intensity, forKey: .intensity)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(source, forKey: .source)
    }
}

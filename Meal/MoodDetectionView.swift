//
//  MoodDetectionView.swift
//  Meal
//
//  Created by shh on 19/05/2025.
//


//
//  MoodDetectionView.swift
//  MealMood
//
//  Created by shh on 19/05/2025.
//

import SwiftUI

struct MoodDetectionView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var faceDetector = FaceEmotionDetector()
    @State private var currentMood: MoodState = .neutral
    @State private var intensity: Double = 50
    @State private var showManualEntry = false
    @State private var isDetecting = false
    @State private var detectionResult: String?
    
    var body: some View {
        VStack(spacing: 30) {
            if isDetecting {
                VStack(spacing: 20) {
                    Text("Analyzing your mood...")
                        .font(.title2)
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color("AccentColor")))
                        .scaleEffect(1.5)
                    
                    if let result = detectionResult {
                        Text(result)
                            .font(.headline)
                            .foregroundColor(Color("AccentColor"))
                            .transition(.opacity)
                    }
                }
                .padding()
                .transition(.scale)
            } else if showManualEntry {
                manualMoodEntryView()
                    .transition(.move(edge: .bottom))
            } else {
                VStack(spacing: 30) {
                    Image(systemName: "face.smiling")
                        .font(.system(size: 60))
                        .foregroundColor(Color("AccentColor"))
                    
                    Text("How are you feeling now?")
                        .font(.title2)
                    
                    VStack(spacing: 20) {
                        Button(action: startFaceDetection) {
                            Text("Detect Automatically")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("appPrimaryColor"))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Button(action: { withAnimation { showManualEntry = true } }) {
                            Text("Enter Manually")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("AccentColor").opacity(0.2))
                                .foregroundColor(Color("AccentColor"))
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            
            Spacer()
        }
        .navigationTitle("Mood Check")
        .onAppear {
            faceDetector.startDetection()
        }
    }
    
    private func manualMoodEntryView() -> some View {
        VStack(spacing: 30) {
            Text(currentMood.rawValue)
                .font(.largeTitle)
                .foregroundColor(currentMood.color)
            
            Picker("Mood", selection: $currentMood) {
                ForEach(MoodState.allCases, id: \.self) { mood in
                    Text(mood.rawValue).tag(mood)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(height: 150)
            
            VStack {
                Text("Intensity: \(Int(intensity))%")
                    .font(.headline)
                
                Slider(value: $intensity, in: 0...100, step: 1)
                    .accentColor(currentMood.color)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color("appPrimaryColor").opacity(0.1))
                    )
            }
            
            Button(action: saveMoodEntry) {
                Text("Save Mood")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("AccentColor"))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Button(action: { withAnimation { showManualEntry = false } }) {
                Text("Cancel")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.gray)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
    }
    
    private func startFaceDetection() {
        isDetecting = true
        faceDetector.startDetection() // Start the camera
        
        // Use DispatchQueue instead of Timer for better SwiftUI compatibility
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // No [weak self] needed since Views are value types
            withAnimation {
                let mood = self.faceDetector.currentMood
                self.currentMood = mood
                self.intensity = Double.random(in: 60...90)
                
                
                self.detectionResult = "Detected: \(mood.rawValue)"
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.saveMoodEntry()
                    // Optional: stop detection after saving
                    // self.faceDetector.stopDetection()
                    // self.isDetecting = false
                }
            }
        }
    }
    
    private func saveMoodEntry() {
        let entry = MoodEntry(
            id: UUID(),
            moodState: currentMood,
            intensity: Int(intensity),
            timestamp: Date(),
            source: showManualEntry ? .manual : .automatic
        )
        
        appState.addMoodEntry(entry)
        
        // Reset for next entry
        withAnimation {
            isDetecting = false
            showManualEntry = false
            currentMood = .neutral
            intensity = 50
            detectionResult = nil
        }
    }
}

enum MoodState: String, CaseIterable, Codable {
    case happy = "Happy"
    case sad = "Sad"
    case angry = "Angry"
    case surprised = "Surprised"
    case neutral = "Neutral"
    case anxious = "Anxious"
    case tired = "Tired"
    case noresult = "No Results"
    
    var emoji: String {
        switch self {
        case .happy: return "😊"
        case .sad: return "😢"
        case .angry: return "😠"
        case .surprised: return "😲"
        case .neutral: return "😐"
        case .anxious: return "😰"
        case .tired: return "😴"
        case .noresult: return ""
        }
    }
    
    var color: Color {
        switch self {
        case .happy: return Color.green
        case .sad: return Color.blue
        case .angry: return Color.red
        case .surprised: return Color.orange
        case .neutral: return Color.gray
        case .anxious: return Color.purple
        case .tired: return Color.yellow
        case .noresult: return Color.black
        }
    }
    
    var iconName: String {
        switch self {
        case .happy: return "face.smiling"
        case .sad: return "face.dashed"
        case .angry: return "face.frown"
        case .surprised: return "eyebrow"
        case .neutral: return "facemask"
        case .anxious: return "brain.head.profile"
        case .tired: return "bed.double"
        case .noresult: return "facemask"
        }
    }
}

enum MoodSource: Codable {
    case automatic, manual
}

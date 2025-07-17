//
//  ContentView.swift
//  Meal
//
//  Created by shh on 19/05/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TabView(selection: $appState.currentView) {
            MealCaptureView()
                .tabItem {
                    Label(AppView.mealCapture.title, systemImage: AppView.mealCapture.icon)
                }
                .tag(AppView.mealCapture)
            
            MoodDetectionView()
                .tabItem {
                    Label(AppView.moodTracker.title, systemImage: AppView.moodTracker.icon)
                }
                .tag(AppView.moodTracker)
            
            TimelineView()
                .tabItem {
                    Label(AppView.timeline.title, systemImage: AppView.timeline.icon)
                }
                .tag(AppView.timeline)
            
            InsightsView()
                .tabItem {
                    Label(AppView.insights.title, systemImage: AppView.insights.icon)
                }
                .tag(AppView.insights)
        }
        .accentColor(Color("AccentColor"))
        .overlay(
            Group {
                if appState.isLoading {
                    LoadingOverlay()
                }
            }
        )
    }
}

struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                
                Text("Analyzing your data...")
                    .foregroundColor(.white)
                    .font(.headline)
            }
            .padding(30)
            .background(Color("appPrimaryColor").opacity(0.9))
            .cornerRadius(15)
        }
    }
}

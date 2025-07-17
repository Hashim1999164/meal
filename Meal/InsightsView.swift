//
//  InsightsView.swift
//  Meal
//
//  Created by shh on 19/05/2025.
//


//
//  InsightsView.swift
//  MealMood
//
//  Created by shh on 19/05/2025.
//


import SwiftUI
import Charts

struct InsightsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var healthKitManager: HealthKitManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                if appState.timelineEvents.count >= 3 {
                    moodCorrelationChart()
                    sleepImpactChart()
                    topInsightsView()
                } else {
                    emptyInsightsView()
                }
            }
            .padding()
        }
        .navigationTitle("Insights")
        .onAppear {
            healthKitManager.fetchRecentHealthData()
        }
    }
    func asd() -> some View {
        
        Chart {
            ForEach(appState.meals) { meal in
                
                let filteredEntries = appState.moodEntries.filter { entry in
                    entry.timestamp > meal.timestamp &&
                    entry.timestamp < meal.timestamp.addingTimeInterval(4 * 3600)
                }
                
                ForEach(filteredEntries) { mood in
                    
                    BarMark(
                        x: .value("Meal", meal.foodType),
                        y: .value("Mood", mood.intensity),
                        width: .ratio(0.6)
                    )
                    .foregroundStyle(mood.moodState.color)
                }
            }
        }
        
    }
    
    func asdasd() -> some View {
        
        Chart {
            ForEach(appState.meals) { meal in
                let sleepEvent = appState.timelineEvents.first(where: {
                    $0.type == .sleep
                })
                   
                let sleepData = sleepEvent?.healthData?.sleep
                let duration = (sleepData?.duration ?? 3600) / 3600
                
                PointMark(
                    x: .value("Meal", meal.foodType),
                    y: .value("Sleep Hours", duration)
                )
                .foregroundStyle(sleepData?.quality.color ?? Color.accentColor)
                
            }
        }
        
        
    }


    
    private func moodCorrelationChart() -> some View {
        VStack(alignment: .leading) {
            Text("Mood After Meals")
                .font(.headline)
                .padding(.bottom, 5)
            
//            Chart {
//                ForEach(appState.meals) { meal in
//                    
//                    let filteredEntries = appState.moodEntries.filter { entry in
//                        entry.timestamp > meal.timestamp &&
//                        entry.timestamp < meal.timestamp.addingTimeInterval(4 * 3600)
//                    }
//                    
//                    ForEach(filteredEntries) { mood in
//                        
//                        BarMark(
//                            x: .value("Meal", meal.foodType),
//                            y: .value("Mood", mood.intensity),
//                            width: .ratio(0.6)
//                        )
//                        .foregroundStyle(mood.moodState.color)
//                    }
//                }
//            }
            asd()
            .chartForegroundStyleScale([
                "Happy": Color.green,
                "Sad": Color.blue,
                "Angry": Color.red,
                "Neutral": Color.gray,
                "Anxious": Color.purple,
                "Tired": Color.orange
            ])
            .frame(height: 200)
        }
        .padding()
        .background(Color("appPrimaryColor").opacity(0.05))
        .cornerRadius(15)
    }
    
    private func sleepImpactChart() -> some View {
        VStack(alignment: .leading) {
            Text("Sleep Quality After Meals")
                .font(.headline)
                .padding(.bottom, 5)
            
//            Chart {
//                ForEach(appState.meals) { meal in
//                    if let sleepEvent = appState.timelineEvents.first(where: {
//                        $0.type == .sleep && $0.timestamp > meal.timestamp && $0.timestamp < meal.timestamp.addingTimeInterval(12 * 3600)
//                    }),
//                       let sleepData = sleepEvent.healthData?.sleep {
//                        PointMark(
//                            x: .value("Meal", meal.foodType.prefix(10)),
//                            y: .value("Sleep Hours", sleepData.duration / 3600)
//                        )
//                        .foregroundStyle(sleepData.quality.color)
//                    }
//                }
//            }
            asdasd()
            .chartForegroundStyleScale([
                "excellent": Color.green,
                "good": Color.blue,
                "fair": Color.orange,
                "poor": Color.red
            ])
            .frame(height: 200)
        }
        .padding()
        .background(Color("appPrimaryColor").opacity(0.05))
        .cornerRadius(15)
    }
    
    private func topInsightsView() -> some View {
        VStack(alignment: .leading) {
            Text("Top Insights")
                .font(.headline)
                .padding(.bottom, 5)
            
            let insights = generateInsights()
            
            if insights.isEmpty {
                Text("No significant patterns detected yet. Keep logging to discover insights.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            } else {
                VStack(alignment: .leading, spacing: 15) {
                    ForEach(insights, id: \.self) { insight in
                        HStack(alignment: .top) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(Color("AccentColor"))
                            Text(insight)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color("appPrimaryColor").opacity(0.05))
        .cornerRadius(15)
    }
    
    private func emptyInsightsView() -> some View {
        VStack(spacing: 20) {
            Image(systemName: "lightbulb")
                .font(.system(size: 60))
                .foregroundColor(Color("AccentColor"))
            
            Text("No insights yet")
                .font(.title2)
            
            Text("Log at least 3 meals and mood entries to start seeing patterns")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal, 40)
        }
        .padding(.top, 100)
    }
    
    private func generateInsights() -> [String] {
        var insights: [String] = []
        
        // Mood patterns
        let moodPatterns = detectMoodPatterns()
        insights.append(contentsOf: moodPatterns)
        
        // Sleep patterns
        let sleepPatterns = detectSleepPatterns()
        insights.append(contentsOf: sleepPatterns)
        
        return insights
    }
    
    private func detectMoodPatterns() -> [String] {
        var patterns: [String] = []
        
        for meal in appState.meals {
            let subsequentMoods = appState.moodEntries.filter {
                $0.timestamp > meal.timestamp && $0.timestamp < meal.timestamp.addingTimeInterval(4 * 3600)
            }
            
            let negativeMoods = subsequentMoods.filter {
                $0.moodState == .sad || $0.moodState == .angry || $0.moodState == .anxious
            }
            
            if negativeMoods.count >= 2 {
                patterns.append("After eating \(meal.foodType.lowercased()), you often feel \(negativeMoods[0].moodState.rawValue.lowercased())")
            }
        }
        
        return patterns
    }
    
    

    
    private func detectSleepPatterns() -> [String] {
        var patterns: [String] = []
        
        for meal in appState.meals {
            guard let sleepEvent = appState.timelineEvents.first(where: {
                $0.type == .sleep && $0.timestamp > meal.timestamp && $0.timestamp < meal.timestamp.addingTimeInterval(12 * 3600)
            }),
            let sleepData = sleepEvent.healthData?.sleep,
            sleepData.quality == .poor else {
                continue
            }
            
            patterns.append("Eating \(meal.foodType.lowercased()) before bed may lead to poorer sleep")
        }
        
        return patterns
    }
}

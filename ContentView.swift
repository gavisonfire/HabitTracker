//
//  ContentView.swift
//  Habit Tracker
//
//  Professional Habit Tracker with Activity Ratios
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var habitManager: HabitManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Suggestion", systemImage: "lightbulb.fill", value: 0) {
                ActivitySuggestionView()
                    .environmentObject(habitManager)
            }
            
            Tab("Log", systemImage: "list.bullet", value: 1) {
                ActivityLogView()
                    .environmentObject(habitManager)
            }
            
            Tab("Settings", systemImage: "gear", value: 2) {
                SettingsView()
                    .environmentObject(habitManager)
            }
        }
        .tint(.blue)
    }
}

#Preview {
    ContentView()
        .environmentObject(HabitManager())
}


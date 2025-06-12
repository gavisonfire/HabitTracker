//
//  HabitTrackerApp.swift
//  Habit Tracker
//
//  Created on iOS Development
//

import SwiftUI

@main
struct HabitTrackerApp: App {
    @StateObject private var habitManager = HabitManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(habitManager)
        }
    }
}


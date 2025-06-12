//
//  Models.swift
//  Habit Tracker
//
//  Data Models for Habit Tracking
//

import Foundation

struct Activity: Identifiable, Codable {
    let id = UUID()
    var name: String
    var ratio: Int
    var color: String // Hex color string
    
    init(name: String, ratio: Int, color: String = "#007AFF") {
        self.name = name
        self.ratio = ratio
        self.color = color
    }
}

struct ActivityLog: Identifiable, Codable {
    let id = UUID()
    let activityName: String
    let timestamp: Date
    
    init(activityName: String, timestamp: Date = Date()) {
        self.activityName = activityName
        self.timestamp = timestamp
    }
}

struct ActivityCount {
    let activity: Activity
    let count: Int
    let targetCount: Int
    let percentage: Double
    
    var isOnTarget: Bool {
        return count >= targetCount
    }
    
    var deficit: Int {
        return max(0, targetCount - count)
    }
}

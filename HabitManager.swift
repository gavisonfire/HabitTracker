//
//  HabitManager.swift
//  Habit Tracker
//
//  Main ViewModel for managing activities and logs
//

import Foundation
import SwiftUI

class HabitManager: ObservableObject {
    @Published var activities: [Activity] = []
    @Published var activityLogs: [ActivityLog] = []
    
    private let activitiesKey = "SavedActivities"
    private let logsKey = "SavedActivityLogs"
    
    init() {
        loadData()
        setupDefaultActivities()
    }
    
    // MARK: - Data Persistence
    
    private func saveData() {
        saveActivities()
        saveLogs()
    }
    
    private func saveActivities() {
        if let encoded = try? JSONEncoder().encode(activities) {
            UserDefaults.standard.set(encoded, forKey: activitiesKey)
        }
    }
    
    private func saveLogs() {
        if let encoded = try? JSONEncoder().encode(activityLogs) {
            UserDefaults.standard.set(encoded, forKey: logsKey)
        }
    }
    
   
    private func loadActivities() {
        if let data = UserDefaults.standard.data(forKey: activitiesKey),
           let decoded = try? JSONDecoder().decode([Activity].self, from: data) {
            activities = decoded
        }
    }

    private func loadData() {
        loadActivities()
        loadLogs()
    }
    
    private func loadLogs() {
        if let data = UserDefaults.standard.data(forKey: logsKey),
           let decoded = try? JSONDecoder().decode([ActivityLog].self, from: data) {
            activityLogs = decoded
        }
    }
    
    // MARK: - Setup Default Activities
    
    private func setupDefaultActivities() {
        if activities.isEmpty {
            activities = [
                Activity(name: "Gaming", ratio: 1, color: "#FF6B6B"),
                Activity(name: "Music Making", ratio: 2, color: "#4ECDC4"),
                Activity(name: "Siobhan Time", ratio: 3, color: "#45B7D1")
            ]
            saveActivities()
        }
    }
    
    // MARK: - Activity Management
    
    func addActivity(_ activity: Activity) {
        activities.append(activity)
        saveActivities()
    }
    
    func removeActivity(at offsets: IndexSet) {
        let removedActivities = offsets.map { activities[$0].name }
        activities.remove(atOffsets: offsets)
        
        // Remove logs for deleted activities
        activityLogs.removeAll { log in
            removedActivities.contains(log.activityName)
        }
        
        saveData()
    }
    
    func updateActivity(_ activity: Activity) {
        if let index = activities.firstIndex(where: { $0.id == activity.id }) {
            activities[index] = activity
            saveActivities()
        }
    }
    
    // MARK: - Activity Logging
    
    func logActivity(_ activityName: String) {
        let log = ActivityLog(activityName: activityName)
        activityLogs.append(log)
        saveLogs()
    }
    
    func removeLog(at offsets: IndexSet) {
        activityLogs.remove(atOffsets: offsets)
        saveLogs()
    }
    
    func purgeAllLogs() {
        activityLogs.removeAll()
        saveLogs()
    }
    
    // MARK: - Analytics and Suggestions
    
    func getActivityCounts() -> [ActivityCount] {
        let totalRatio = activities.reduce(0) { $0 + $1.ratio }
        let totalLogs = activityLogs.count
        
        return activities.map { activity in
            let count = activityLogs.filter { $0.activityName == activity.name }.count
            let targetCount = totalLogs > 0 ? Int(ceil(Double(totalLogs * activity.ratio) / Double(totalRatio))) : 0
            let percentage = totalLogs > 0 ? Double(count) / Double(totalLogs) * 100 : 0
            
            return ActivityCount(
                activity: activity,
                count: count,
                targetCount: targetCount,
                percentage: percentage
            )
        }
    }
    
    func getSuggestedActivity() -> Activity? {
        let activityCounts = getActivityCounts()
        
        // Find activity with largest deficit
        let sortedByDeficit = activityCounts.sorted { $0.deficit > $1.deficit }
        
        return sortedByDeficit.first?.activity
    }
    
    func getRecentLogs(limit: Int = 50) -> [ActivityLog] {
        return Array(activityLogs.sorted { $0.timestamp > $1.timestamp }.prefix(limit))
    }
}

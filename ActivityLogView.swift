//
//  ActivityLogView.swift
//  Habit Tracker
//
//  View for displaying activity logs with search and filtering
//

import SwiftUI

struct ActivityLogView: View {
    @EnvironmentObject var habitManager: HabitManager
    @State private var showingLogSheet = false
    @State private var searchText = ""
    
    var filteredLogs: [ActivityLog] {
        let logs = habitManager.getRecentLogs()
        if searchText.isEmpty {
            return logs
        } else {
            return logs.filter { $0.activityName.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if filteredLogs.isEmpty {
                    emptyStateView
                } else {
                    logListView
                }
            }
            .navigationTitle("Activity Log")
            .searchable(text: $searchText, prompt: "Search activities...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Log Activity") {
                        showingLogSheet = true
                    }
                    .font(.system(size: 16, weight: .medium))
                }
            }
            .sheet(isPresented: $showingLogSheet) {
                LogActivitySheet()
                    .environmentObject(habitManager)
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Activities Logged")
                .font(.system(size: 24, weight: .semibold))
            
            Text("Start logging activities to see them here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Log First Activity") {
                showingLogSheet = true
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(.blue)
            .clipShape(RoundedRectangle(cornerRadius: 25))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Log List
    
    private var logListView: some View {
        List {
            ForEach(groupedLogs.keys.sorted(by: >), id: \.self) { date in
                Section(header: Text(formatSectionDate(date))) {
                    ForEach(groupedLogs[date] ?? []) { log in
                        LogRowView(log: log)
                    }
                    .onDelete { indexSet in
                        deleteItems(at: indexSet, for: date)
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    // MARK: - Grouped Logs by Date
    
    private var groupedLogs: [String: [ActivityLog]] {
        Dictionary(grouping: filteredLogs) { log in
            Calendar.current.startOfDay(for: log.timestamp).ISO8601Format()
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatSectionDate(_ dateString: String) -> String {
        guard let date = ISO8601DateFormatter().date(from: dateString) else {
            return "Unknown Date"
        }
        
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }
    
    private func deleteItems(at offsets: IndexSet, for dateString: String) {
        guard let logsForDate = groupedLogs[dateString] else { return }
        let logsToDelete = offsets.map { logsForDate[$0] }
        
        for logToDelete in logsToDelete {
            if let index = habitManager.activityLogs.firstIndex(where: { $0.id == logToDelete.id }) {
                habitManager.activityLogs.remove(at: index)
            }
        }
        habitManager.objectWillChange.send()
    }
}

// MARK: - Log Row View

struct LogRowView: View {
    let log: ActivityLog
    @EnvironmentObject var habitManager: HabitManager
    
    private var activity: Activity? {
        habitManager.activities.first { $0.name == log.activityName }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Activity color indicator
            Circle()
                .fill(Color(hex: activity?.color ?? "#007AFF"))
                .frame(width: 8, height: 8)
            
            // Activity name
            Text(log.activityName)
                .font(.system(size: 16, weight: .medium))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Timestamp
            Text(log.timestamp, format: .dateTime.hour().minute())
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ActivityLogView()
        .environmentObject(HabitManager())
}

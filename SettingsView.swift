//
//  SettingsView.swift
//  Habit Tracker
//
//  Settings view for managing activities and app preferences
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var habitManager: HabitManager
    @State private var showingAddActivity = false
    @State private var showingPurgeAlert = false
    @State private var showingLogSheet = false
    
    var body: some View {
        NavigationView {
            List {
                // Activities Section
                activitiesSection
                
                // Actions Section
                actionsSection
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Log Activity") {
                        showingLogSheet = true
                    }
                    .font(.system(size: 16, weight: .medium))
                }
            }
            .sheet(isPresented: $showingAddActivity) {
                AddActivitySheet()
                    .environmentObject(habitManager)
            }
            .sheet(isPresented: $showingLogSheet) {
                LogActivitySheet()
                    .environmentObject(habitManager)
            }
            .alert("Purge All Logs", isPresented: $showingPurgeAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Purge", role: .destructive) {
                    withAnimation {
                        habitManager.purgeAllLogs()
                    }
                }
            } message: {
                Text("This will delete all logged activities but keep your activity options. This action cannot be undone.")
            }
        }
    }
    
    // MARK: - Activities Section
    
    private var activitiesSection: some View {
        Section {
            ForEach(habitManager.activities) { activity in
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color(hex: activity.color))
                        .frame(width: 12, height: 12)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(activity.name)
                            .font(.system(size: 16, weight: .medium))
                        
                        Text("Ratio: \(activity.ratio)")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("\(activity.ratio)")
                        .font(.system(size: 16, weight: .semibold, design: .monospaced))
                        .foregroundColor(.blue)
                }
                .padding(.vertical, 4)
            }
            .onDelete(perform: habitManager.removeActivity)
            
            Button(action: {
                showingAddActivity = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                    Text("Add New Activity")
                        .foregroundColor(.blue)
                }
            }
        } header: {
            Text("Activities")
        } footer: {
            Text("Activities are used to maintain ratios. Swipe left to delete.")
        }
    }
    
    // MARK: - Actions Section
    
    private var actionsSection: some View {
        Section {
            Button(action: {
                showingPurgeAlert = true
            }) {
                HStack {
                    Image(systemName: "trash.fill")
                        .foregroundColor(.red)
                    Text("Purge All Logs")
                        .foregroundColor(.red)
                }
            }
        } header: {
            Text("Data Management")
        } footer: {
            Text("Total logs: \(habitManager.activityLogs.count)")
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(HabitManager())
}

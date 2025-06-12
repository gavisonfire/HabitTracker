//
//  ActivitySuggestionView.swift
//  Habit Tracker
//
//  Main suggestion view with activity percentages and logging
//

import SwiftUI

struct ActivitySuggestionView: View {
    @EnvironmentObject var habitManager: HabitManager
    @State private var showingLogSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Main Suggestion Card
                    suggestionCard
                    
                    // Activity Statistics
                    statisticsSection
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .navigationTitle("Activity Suggestion")
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
            .refreshable {
                // Refresh data - useful for future enhancements
            }
        }
    }
    
    // MARK: - Suggestion Card
    
    private var suggestionCard: some View {
        VStack(spacing: 16) {
            if let suggestedActivity = habitManager.getSuggestedActivity() {
                VStack(spacing: 12) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color(hex: suggestedActivity.color))
                    
                    Text("Suggested Activity")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(suggestedActivity.name)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        withAnimation(.spring()) {
                            habitManager.logActivity(suggestedActivity.name)
                        }
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Log This Activity")
                        }
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(hex: suggestedActivity.color))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.green)
                    
                    Text("All Caught Up!")
                        .font(.system(size: 24, weight: .bold))
                    
                    Text("Your activities are perfectly balanced")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Statistics Section
    
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Activity Overview")
                .font(.system(size: 20, weight: .semibold))
                .padding(.horizontal)
            
            LazyVStack(spacing: 8) {
                ForEach(habitManager.getActivityCounts(), id: \.activity.id) { activityCount in
                    ActivityStatRow(activityCount: activityCount)
                }
            }
        }
    }
}

// MARK: - Activity Statistics Row

struct ActivityStatRow: View {
    let activityCount: ActivityCount
    
    var body: some View {
        HStack(spacing: 12) {
            // Color indicator
            Circle()
                .fill(Color(hex: activityCount.activity.color))
                .frame(width: 12, height: 12)
            
            // Activity name
            Text(activityCount.activity.name)
                .font(.system(size: 16, weight: .medium))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Statistics
            HStack(spacing: 16) {
                Text("\(activityCount.count)/\(activityCount.targetCount)")
                    .font(.system(size: 15, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                
                Text("\(activityCount.percentage, specifier: "%.1f")%")
                    .font(.system(size: 15, weight: .semibold, design: .monospaced))
                    .foregroundColor(activityCount.isOnTarget ? .green : .orange)
                    .frame(width: 50, alignment: .trailing)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    ActivitySuggestionView()
        .environmentObject(HabitManager())
}

//
//  AddActivitySheet.swift
//  Habit Tracker
//
//  Sheet for adding new activities with custom ratios and colors
//

import SwiftUI

struct AddActivitySheet: View {
    @EnvironmentObject var habitManager: HabitManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var activityName = ""
    @State private var activityRatio = 1
    @State private var selectedColor = "#007AFF"
    
    private let colorOptions = [
        "#007AFF", "#FF6B6B", "#4ECDC4", "#45B7D1", "#96CEB4",
        "#FFEAA7", "#DDA0DD", "#98D8C8", "#F7DC6F", "#BB8FCE"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Activity Name", text: $activityName)
                        .textInputAutocapitalization(.words)
                } header: {
                    Text("Activity Details")
                }
                
                Section {
                    Stepper("Ratio: \(activityRatio)", value: $activityRatio, in: 1...10)
                        .font(.system(size: 16, weight: .medium))
                } header: {
                    Text("Activity Ratio")
                } footer: {
                    Text("This sets how often you should do this activity reative to others.  For example, if you select 1 for activity A and have activity B set to 2, you want to do activity A twice for every time you do activity B.")
                }
                
                Section {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 16) {
                        ForEach(colorOptions, id: \.self) { color in
                            Circle()
                                .fill(Color(hex: color))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Circle()
                                        .stroke(selectedColor == color ? Color.primary : Color.clear, lineWidth: 3)
                                )
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Color")
                }
            }
            .navigationTitle("Add Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addActivity()
                    }
                    .disabled(activityName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .font(.system(size: 16, weight: .semibold))
                }
            }
        }
    }
    
    private func addActivity() {
        let trimmedName = activityName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        let newActivity = Activity(
            name: trimmedName,
            ratio: activityRatio,
            color: selectedColor
        )
        
        habitManager.addActivity(newActivity)
        dismiss()
    }
}

//
//  LogActivitySheet.swift
//  Habit Tracker
//
//  Sheet for quickly logging activities
//

struct LogActivitySheet: View {
    @EnvironmentObject var habitManager: HabitManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Activity List
                if habitManager.activities.isEmpty {
                    emptyStateView
                } else {
                    activityListView
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .font(.system(size: 16))
                
                Spacer()
                
                Text("Log Activity")
                    .font(.system(size: 18, weight: .semibold))
                
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                .font(.system(size: 16))
                .opacity(0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            Text("Which activity did you just complete?")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .background(Color(.systemBackground))
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "plus.app")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Activities Available")
                .font(.system(size: 20, weight: .semibold))
            
            Text("Add activities in Settings first")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    private var activityListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(habitManager.activities) { activity in
                    LogActivityButton(activity: activity) {
                        logActivity(activity)
                    }
                }
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private func logActivity(_ activity: Activity) {
        withAnimation(.spring()) {
            habitManager.logActivity(activity.name)
            dismiss()
        }
    }
}

struct LogActivityButton: View {
    let activity: Activity
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Circle()
                    .fill(Color(hex: activity.color))
                    .frame(width: 16, height: 16)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(activity.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("Ratio: \(activity.ratio)")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: activity.color))
            }
            .padding(20)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
            action()
        }
    }
}

#Preview {
    AddActivitySheet()
        .environmentObject(HabitManager())
}

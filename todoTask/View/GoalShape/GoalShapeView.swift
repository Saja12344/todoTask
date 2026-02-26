//
//  GoalShapeView.swift
//  todoTask
//
//  Created by شهد عبدالله القحطاني on 06/09/1447 AH.
//


//
//  GoalShapeView.swift
//  todoTask
//
//  يستبدل كلا الملفين GoalShape_View.swift و GoalSettingView.swift
//

import SwiftUI

// MARK: - GoalShapeView
struct GoalShapeView: View {
    @State private var selectedGoal: GoalType?
    @State private var showSettings = false

    @State private var capturedDays:       Set<Int> = [1,2,3,4,5]
    @State private var capturedStartTime:  Date     = Calendar.current.date(bySettingHour: 8,  minute: 0, second: 0, of: Date())!
    @State private var capturedEndTime:    Date     = Calendar.current.date(bySettingHour: 9,  minute: 0, second: 0, of: Date())!
    @State private var capturedTarget:     Int      = 10
    @State private var capturedUnit:       String   = ""
    @State private var capturedDeadline:   Date     = Calendar.current.date(byAdding: .month, value: 1, to: Date())!
    @State private var capturedBreakDays:  Int      = 0
    @State private var capturedPaceWeeks:  Int      = 1
    @State private var capturedScope:      Double   = 50
    @State private var capturedDailyMin:   Int      = 30
    @State private var capturedBaseline:   Int      = 0
    @State private var capturedIsReduceBy: Bool     = true

    let onFinished: ((GoalType, GoalSettings) -> Void)?
    let onBack:     (() -> Void)?

    init(
        selectedGoal: GoalType? = nil,
        showSettings: Bool      = false,
        onFinished: ((GoalType, GoalSettings) -> Void)? = nil,
        onBack: (() -> Void)?   = nil
    ) {
        self._selectedGoal = State(initialValue: selectedGoal)
        self._showSettings = State(initialValue: showSettings)
        self.onFinished    = onFinished
        self.onBack        = onBack
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(LinearGradient(colors: [.darkBlu, .dark], startPoint: .bottom, endPoint: .top))
                .ignoresSafeArea()
            Image("Gliter").resizable().scaledToFit().scaleEffect(1.9).contrast(1.8).saturation(1.8).ignoresSafeArea()

            VStack {
                // NavBar
                HStack {
                    Button(action: {
                        if showSettings { withAnimation { showSettings = false } }
                        else { onBack?() }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2).foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .glassEffect(.clear.tint(Color.black.opacity(0.4)), in: .rect(cornerRadius: 24))
                    }
                    Spacer()
                    Button(action: {
                       
                        if !showSettings {
                            if selectedGoal != nil { withAnimation { showSettings = true } }
                        } else {
                            if let type = selectedGoal { onFinished?(type, buildSettings()) }
                        }
                    }) {
                        Text("Next").font(.headline).foregroundColor(.white)
                            .padding(.horizontal, 30).padding(.vertical, 12)
                            .glassEffect(.clear.tint(Color.black.opacity(0.4)), in: .rect(cornerRadius: 24))
                    }
                }
                .padding()

                Text(showSettings ? getTitle(for: selectedGoal) : "Select Your Goal Shape")
                    .font(.system(size: 32, weight: .bold)).foregroundColor(.white).padding(.top, 1)

                Spacer()

                if !showSettings {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 20)], spacing: 15) {
                        GoalCard(icon: "scope",                     title: "Finish a Total",       description: "Reach a set number",                    isSelected: selectedGoal == .finishTotal)    { selectedGoal = .finishTotal }
                        GoalCard(icon: "calendar.badge.clock",      title: "Repeat on Schedule",   description: "Do something on certain days each week", isSelected: selectedGoal == .repeatSchedule) { selectedGoal = .repeatSchedule }
                        GoalCard(icon: "flame.fill",                title: "Build a Streak",       description: "Do it every day without stopping",       isSelected: selectedGoal == .buildStreak)    { selectedGoal = .buildStreak }
                        GoalCard(icon: "chart.line.uptrend.xyaxis", title: "Level Up Gradually",   description: "Start small and slowly do more",         isSelected: selectedGoal == .levelUp)        { selectedGoal = .levelUp }
                        GoalCard(icon: "flag.checkered",            title: "Finish by Milestones", description: "Complete a goal step by step",           isSelected: selectedGoal == .milestones)     { selectedGoal = .milestones }
                        GoalCard(icon: "arrow.down.circle",         title: "Reduce Something",     description: "Do less or stay under a limit",          isSelected: selectedGoal == .reduce)         { selectedGoal = .reduce }
                    }
                    .padding(.horizontal, 17)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            Spacer().frame(height: 40)
                            switch selectedGoal {
                            case .finishTotal:
                                FinishTotalContent(targetNumber: $capturedTarget, unit: $capturedUnit, deadlineDate: $capturedDeadline, selectedDays: $capturedDays, startTime: $capturedStartTime, endTime: $capturedEndTime)
                            case .repeatSchedule:
                                RepeatScheduleContent(unit: $capturedUnit, selectedDays: $capturedDays, startTime: $capturedStartTime, endTime: $capturedEndTime)
                            case .buildStreak:
                                BuildStreakContent(targetNumber: $capturedTarget, unit: $capturedUnit, breakDays: $capturedBreakDays)
                            case .levelUp:
                                LevelUpContent(activity: $capturedUnit, targetLevel: $capturedTarget, selectedDays: $capturedDays, stepUpPace: $capturedPaceWeeks)
                            case .milestones:
                                MilestonesContent(deadlineDate: $capturedDeadline, selectedDays: $capturedDays, scopeSize: $capturedScope, dailyTimePreference: $capturedDailyMin)
                            case .reduce:
                                ReduceContent(metricType: $capturedUnit, isReduceBy: $capturedIsReduceBy, baselineNumber: $capturedBaseline, targetNumber: $capturedTarget)
                            case .none:
                                EmptyView()
                            }
                            Spacer().frame(height: 40)
                        }
                        .padding(.horizontal, 20)
                    }
                }
                Spacer()
            }
        }
        .toolbar(.hidden, for: .tabBar)
    }

    private func buildSettings() -> GoalSettings {
        GoalSettings(
            goalType:         selectedGoal ?? .finishTotal,
            selectedDays:     capturedDays,
            startTime:        capturedStartTime,
            endTime:          capturedEndTime,
            targetNumber:     capturedTarget,
            unit:             capturedUnit,
            deadline:         capturedDeadline,
            breakDaysAllowed: capturedBreakDays,
            stepUpPaceWeeks:  capturedPaceWeeks,
            scopeSize:        capturedScope,
            dailyMinutes:     capturedDailyMin,
            baselineNumber:   capturedBaseline,
            isReduceBy:       capturedIsReduceBy
        )
    }

    func getTitle(for goalType: GoalType?) -> String {
        switch goalType {
        case .finishTotal:    return "Finish a Total"
        case .repeatSchedule: return "Repeat on Schedule"
        case .buildStreak:    return "Build a Streak"
        case .levelUp:        return "Level Up Gradually"
        case .milestones:     return "Finish by Milestones"
        case .reduce:         return "Reduce Something"
        case .none:           return "Settings"
        }
    }
}

// MARK: - Content Views (Bindings)

struct FinishTotalContent: View {
    @Binding var targetNumber: Int
    @Binding var unit:         String
    @Binding var deadlineDate: Date
    @Binding var selectedDays: Set<Int>
    @Binding var startTime:    Date
    @Binding var endTime:      Date

    var body: some View {
        GlassCard {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Target Number:")
                    NumberStepper(title: "", value: $targetNumber, range: 1...1000, suffix: "")
                }
                VStack(alignment: .leading, spacing: 6) {
                    SectionHeader(title: "Unit:")
                    CustomTextField(placeholder: "eg. Pages, Km, Bottles", text: $unit).padding(.horizontal, 25)
                }
                GlassDatePicker(title: "Deadline Date:", date: $deadlineDate)
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Days a Week:")
                    WeekDaysSelector(selectedDays: $selectedDays)
                }
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Preferred Time:")
                    HStack {
                        DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute).labelsHidden().colorScheme(.dark)
                        Text("to").foregroundColor(.white.opacity(0.6))
                        DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute).labelsHidden().colorScheme(.dark)
                    }
                }
            }
        }
    }
}

struct RepeatScheduleContent: View {
    @Binding var unit:         String
    @Binding var selectedDays: Set<Int>
    @Binding var startTime:    Date
    @Binding var endTime:      Date

    var body: some View {
        GlassCard {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Unit:")
                    CustomTextField(placeholder: "eg. Inches, Bottles", text: $unit)
                }
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Days a Week:")
                    WeekDaysSelector(selectedDays: $selectedDays)
                }
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Time Window:")
                    HStack {
                        DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute).labelsHidden().colorScheme(.dark)
                        Text("to").foregroundColor(.white.opacity(0.5))
                        DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute).labelsHidden().colorScheme(.dark)
                    }
                }
            }
        }
    }
}

struct BuildStreakContent: View {
    @Binding var targetNumber: Int
    @Binding var unit:         String
    @Binding var breakDays:    Int

    var body: some View {
        GlassCard {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Target Days:")
                    NumberStepper(title: "", value: $targetNumber, range: 1...365, suffix: "days")
                }
                VStack(alignment: .leading, spacing: 6) {
                    SectionHeader(title: "Activity:")
                    CustomTextField(placeholder: "eg. journaling, workout", text: $unit)
                }
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Break Days Allowed:")
                    NumberStepper(title: "", value: $breakDays, range: 0...7, suffix: "")
                }
            }
        }
    }
}

struct LevelUpContent: View {
    @Binding var activity:     String
    @Binding var targetLevel:  Int
    @Binding var selectedDays: Set<Int>
    @Binding var stepUpPace:   Int

    var body: some View {
        GlassCard {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Activity:")
                    CustomTextField(placeholder: "eg. running, reading", text: $activity)
                }
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Target Level:")
                    NumberStepper(title: "", value: $targetLevel, range: 1...100, suffix: "")
                }
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Days a Week:")
                    WeekDaysSelector(selectedDays: $selectedDays)
                }
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Step-up Every")
                    NumberStepper(title: "", value: $stepUpPace, range: 1...52, suffix: "Weeks")
                }
            }
        }
    }
}

struct MilestonesContent: View {
    @Binding var deadlineDate:        Date
    @Binding var selectedDays:        Set<Int>
    @Binding var scopeSize:           Double
    @Binding var dailyTimePreference: Int

    var body: some View {
        GlassCard {
            VStack(spacing: 20) {
                GlassDatePicker(title: "Deadline Date:", date: $deadlineDate)
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Days a Week:")
                    WeekDaysSelector(selectedDays: $selectedDays)
                }
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Scope Size")
                    GlassSlider(value: $scopeSize, range: 0...100)
                }
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Daily Time Preference")
                    NumberStepper(title: "", value: $dailyTimePreference, range: 5...180, suffix: "minutes")
                }
            }
        }
    }
}

struct ReduceContent: View {
    @Binding var metricType:     String
    @Binding var isReduceBy:     Bool
    @Binding var baselineNumber: Int
    @Binding var targetNumber:   Int

    var body: some View {
        GlassCard {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Metric type:")
                    CustomTextField(placeholder: "eg. screen time, sugar", text: $metricType)
                }
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Tracking mode:")
                    GlassToggle(option1: "Reduce by", option2: "Stay Under", isOption1: $isReduceBy)
                }
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Baseline Number:")
                    NumberStepper(title: "", value: $baselineNumber, range: 0...1000, suffix: "")
                }
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Target Number:")
                    NumberStepper(title: "", value: $targetNumber, range: 0...1000, suffix: "")
                }
            }
        }
    }
}

#Preview {
    GoalShapeView(onFinished: { _, _ in }, onBack: {})
}

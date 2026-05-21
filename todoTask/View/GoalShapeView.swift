//
//  GoalShapeView.swift
//  todoTask
//
//  Created by شهد عبدالله القحطاني on 04/12/1447 AH.
//


//
//  GoalShapeView.swift
//  todoTask
//

import SwiftUI

// MARK: - GoalShapeView
struct GoalShapeView: View {
    @State private var selectedGoal: GoalType?
    @State private var showSettings = false
    @State private var capturedDays:            Set<Int> = [1,2,3,4,5,6,7]
    @State private var capturedStartTime:       Date     = Calendar.current.date(bySettingHour: 8,  minute: 0, second: 0, of: Date())!
    @State private var capturedEndTime:         Date     = Calendar.current.date(bySettingHour: 9,  minute: 0, second: 0, of: Date())!
    @State private var capturedTarget:          Int      = 10
    @State private var capturedUnit:            String   = ""
    @State private var capturedDeadline:        Date     = Calendar.current.date(byAdding: .month, value: 1, to: Date())!
    @State private var capturedBreakDays:       Int      = 0
    @State private var capturedPaceWeeks:       Int      = 1
    @State private var capturedScope:           Double   = 50
    @State private var capturedDailyMin:        Int      = 30
    @State private var capturedBaseline:        Int      = 0
    @State private var capturedIsReduceBy:      Bool     = true
    @State private var capturedIsStreakMode:    Bool     = false
    @State private var capturedIsMilestoneMode: Bool     = false

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
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                        GoalCard(
                            icon: "scope",
                            title: "Reach a Target",
                            description: "Hit a number or finish step by step",
                            isSelected: selectedGoal == .reachTarget
                        ) { selectedGoal = .reachTarget }

                        GoalCard(
                            icon: "flame.fill",
                            title: "Build a Habit",
                            description: "Repeat on schedule or build a streak",
                            isSelected: selectedGoal == .buildHabit
                        ) { selectedGoal = .buildHabit }

                        GoalCard(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "Level Up",
                            description: "Start small and slowly do more",
                            isSelected: selectedGoal == .levelUp
                        ) { selectedGoal = .levelUp }

                        GoalCard(
                            icon: "arrow.down.circle",
                            title: "Reduce",
                            description: "Do less or stay under a limit",
                            isSelected: selectedGoal == .reduce
                        ) { selectedGoal = .reduce }
                    }
                    .padding(.horizontal, 17)

                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            Spacer().frame(height: 40)
                            switch selectedGoal {
                            case .reachTarget:
                                ReachTargetContent(
                                    targetNumber:        $capturedTarget,
                                    unit:                $capturedUnit,
                                    deadlineDate:        $capturedDeadline,
                                    selectedDays:        $capturedDays,
                                    startTime:           $capturedStartTime,
                                    endTime:             $capturedEndTime,
                                    isMilestoneMode:     $capturedIsMilestoneMode,
                                    scopeSize:           $capturedScope,
                                    dailyTimePreference: $capturedDailyMin
                                )
                            case .buildHabit:
                                BuildHabitContent(
                                    selectedDays:  $capturedDays,
                                    startTime:     $capturedStartTime,
                                    endTime:       $capturedEndTime,
                                    unit:          $capturedUnit,
                                    isStreakMode:  $capturedIsStreakMode,
                                    targetNumber:  $capturedTarget,
                                    breakDays:     $capturedBreakDays
                                )
                            case .levelUp:
                                LevelUpContent(
                                    activity:     $capturedUnit,
                                    targetLevel:  $capturedTarget,
                                    selectedDays: $capturedDays,
                                    stepUpPace:   $capturedPaceWeeks
                                )
                            case .reduce:
                                ReduceContent(
                                    metricType:     $capturedUnit,
                                    isReduceBy:     $capturedIsReduceBy,
                                    baselineNumber: $capturedBaseline,
                                    targetNumber:   $capturedTarget
                                )
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
            goalType:         selectedGoal ?? .reachTarget,
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
            isReduceBy:       capturedIsReduceBy,
            isStreakMode:     capturedIsStreakMode,
            isMilestoneMode:  capturedIsMilestoneMode
        )
    }

    func getTitle(for goalType: GoalType?) -> String {
        switch goalType {
        case .reachTarget: return "Reach a Target"
        case .buildHabit:  return "Build a Habit"
        case .levelUp:     return "Level Up"
        case .reduce:      return "Reduce Something"
        case .none:        return "Settings"
        }
    }
}

// MARK: - ReachTargetContent
struct ReachTargetContent: View {
    @Binding var targetNumber:        Int
    @Binding var unit:                String
    @Binding var deadlineDate:        Date
    @Binding var selectedDays:        Set<Int>
    @Binding var startTime:           Date
    @Binding var endTime:             Date
    @Binding var isMilestoneMode:     Bool
    @Binding var scopeSize:           Double
    @Binding var dailyTimePreference: Int
    @State private var showMore = false

    var body: some View {
        GlassCard {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Target number")
                    NumberStepper(title: "", value: $targetNumber, range: 1...1000, suffix: "")
                }
                GlassDatePicker(title: "Deadline Date", date: $deadlineDate)
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "How to track it").padding(.horizontal, -24)
                    GlassToggle(option1: "By Total", option2: "By Milestones", isOption1: Binding(
                        get: { !isMilestoneMode },
                        set: { isMilestoneMode = !$0 }
                    ))
                }
                if isMilestoneMode {
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader(title: "Scope Size")
                        GlassSlider(value: $scopeSize, range: 0...100).padding(.horizontal, 14)
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader(title: "Daily Time Preference")
                        NumberStepper(title: "", value: $dailyTimePreference, range: 5...180, suffix: "min")
                    }
                }
                Button {
                    withAnimation(.spring(response: 0.3)) { showMore.toggle() }
                } label: {
                    HStack(spacing: 6) {
                        Text(showMore ? "Less options" : "More options")
                            .font(.system(size: 15, weight: .medium)).foregroundColor(.white.opacity(0.55))
                        Image(systemName: showMore ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12)).foregroundColor(.white.opacity(0.55))
                    }
                }
                if showMore {
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            SectionHeader(title: "Unit")
                            CustomTextField(placeholder: "eg. Pages, Km, Bottles", text: $unit).padding(.horizontal, 14)
                        }
                        VStack(alignment: .leading) {
                            SectionHeader(title: "Days of the Week").padding(.horizontal, -10)
                            WeekDaysSelector(selectedDays: $selectedDays)
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            SectionHeader(title: "Preferred Time").padding(.horizontal, -1)
                            HStack {
                                DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute).labelsHidden().colorScheme(.dark)
                                Text("to").foregroundColor(.white.opacity(0.6))
                                DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute).labelsHidden().colorScheme(.dark)
                            }
                            .padding(.leading, 80)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }
}

// MARK: - BuildHabitContent
struct BuildHabitContent: View {
    @Binding var selectedDays: Set<Int>
    @Binding var startTime:    Date
    @Binding var endTime:      Date
    @Binding var unit:         String
    @Binding var isStreakMode:  Bool
    @Binding var targetNumber: Int
    @Binding var breakDays:    Int
    @State private var showMore = false

    var body: some View {
        GlassCard {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Habit type").padding(.horizontal, -24)
                    GlassToggle(option1: "Schedule", option2: "Streak", isOption1: Binding(
                        get: { !isStreakMode },
                        set: { isStreakMode = !$0 }
                    ))
                }
                if !isStreakMode {
                    VStack(alignment: .leading) {
                        SectionHeader(title: "Days of the Week").padding(.horizontal, -10)
                        WeekDaysSelector(selectedDays: $selectedDays)
                    }
                }
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Preferred Time").padding(.horizontal, -1)
                    HStack {
                        DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute).labelsHidden().colorScheme(.dark)
                        Text("to").foregroundColor(.white.opacity(0.6))
                        DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute).labelsHidden().colorScheme(.dark)
                    }
                    .padding(.leading, 80)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                if isStreakMode {
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader(title: "Target Days")
                        NumberStepper(title: "", value: $targetNumber, range: 1...365, suffix: "days")
                    }
                }
                Button {
                    withAnimation(.spring(response: 0.3)) { showMore.toggle() }
                } label: {
                    HStack(spacing: 6) {
                        Text(showMore ? "Less options" : "More options")
                            .font(.system(size: 15, weight: .medium)).foregroundColor(.white.opacity(0.55))
                        Image(systemName: showMore ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12)).foregroundColor(.white.opacity(0.55))
                    }
                }
                if showMore {
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            SectionHeader(title: "Activity")
                            CustomTextField(placeholder: "eg. journaling, workout", text: $unit).padding(.horizontal, 14)
                        }
                        if isStreakMode {
                            VStack(alignment: .leading, spacing: 8) {
                                SectionHeader(title: "Break Days Allowed")
                                NumberStepper(title: "", value: $breakDays, range: 0...7, suffix: "")
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - LevelUpContent
struct LevelUpContent: View {
    @Binding var activity:     String
    @Binding var targetLevel:  Int
    @Binding var selectedDays: Set<Int>
    @Binding var stepUpPace:   Int

    var body: some View {
        GlassCard {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Activity")
                    CustomTextField(placeholder: "eg. running, reading", text: $activity).padding(.horizontal, 14)
                }
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Target Level")
                    NumberStepper(title: "", value: $targetLevel, range: 1...100, suffix: "")
                }
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Days of the Week").padding(.horizontal, -10)
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

// MARK: - ReduceContent
struct ReduceContent: View {
    @Binding var metricType:     String
    @Binding var isReduceBy:     Bool
    @Binding var baselineNumber: Int
    @Binding var targetNumber:   Int

    var body: some View {
        GlassCard {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Metric type")
                    CustomTextField(placeholder: "eg. screen time, sugar", text: $metricType).padding(.horizontal, 14)
                }
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Tracking mode").padding(.horizontal, -24)
                    GlassToggle(option1: "Reduce by", option2: "Stay Under", isOption1: $isReduceBy)
                }
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Starting Number")
                    NumberStepper(title: "", value: $baselineNumber, range: 0...1000, suffix: "")
                }
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Target Number")
                    NumberStepper(title: "", value: $targetNumber, range: 0...1000, suffix: "")
                }
            }
        }
    }
}

#Preview {
    GoalShapeView(onFinished: { _, _ in }, onBack: {})
}
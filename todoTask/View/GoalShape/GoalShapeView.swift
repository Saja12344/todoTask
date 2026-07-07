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
    @EnvironmentObject private var lang: LanguageManager
    @State private var selectedGoal: GoalType?
    @State private var selectedOption: GoalShapeOption?
    @State private var showSettings = false
    @State private var capturedDays:            Set<Int> = [1,2,3,4,5,6,7]
    @State private var capturedStartTime:       Date     = Calendar.current.date(bySettingHour: 8,  minute: 0, second: 0, of: Date())!
    @State private var capturedEndTime:         Date     = Calendar.current.date(bySettingHour: 9,  minute: 0, second: 0, of: Date())!
    @State private var capturedTarget:          Int      = 10
    @State private var capturedUnit:            String   = ""
    @State private var capturedDeadline:        Date?    = nil
    @State private var capturedBreakDays:       Int      = 0
    @State private var capturedPaceWeeks:       Int      = 1
    @State private var capturedScope:           Double   = 50
    @State private var capturedDailyMin:        Int      = 30
    @State private var capturedBaseline:        Int      = 0
    @State private var capturedIsReduceBy:      Bool     = true
    @State private var capturedIsStreakMode:    Bool     = false
    @State private var capturedIsMilestoneMode: Bool     = false

    let draftText: String
    let openSettingsDirectly: Bool
    let onFinished: ((GoalType, GoalSettings) -> Void)?
    let onBack:     (() -> Void)?

    init(
        selectedGoal: GoalType? = nil,
        draftText: String = "",
        openSettingsDirectly: Bool = false,
        showSettings: Bool = false,
        initialMilestoneMode: Bool = false,
        initialStreakMode: Bool = false,
        onFinished: ((GoalType, GoalSettings) -> Void)? = nil,
        onBack: (() -> Void)? = nil
    ) {
        self.draftText = draftText
        self.openSettingsDirectly = openSettingsDirectly
        self._selectedGoal = State(initialValue: selectedGoal)
        self._showSettings = State(initialValue: openSettingsDirectly || showSettings)
        self._capturedIsMilestoneMode = State(initialValue: initialMilestoneMode)
        self._capturedIsStreakMode = State(initialValue: initialStreakMode)
        if let selectedGoal {
            self._selectedOption = State(initialValue: GoalShapeOption.matching(
                type: selectedGoal,
                milestone: initialMilestoneMode,
                streak: initialStreakMode
            ) ?? GoalShapeOption.defaultFor(selectedGoal))
        }
        self.onFinished = onFinished
        self.onBack = onBack
    }

    var body: some View {
        GoalFlowScreen(
            background: { AppBackground() },
            topBar: {
                GoalFlowNavigationRow(
                    onBack: handleBack,
                    trailing: {
                        GoalFlowNextButton(action: {
                            if !showSettings {
                                if selectedOption != nil { withAnimation { showSettings = true } }
                            } else if let type = selectedGoal {
                                onFinished?(type, buildSettings())
                            }
                        })
                        .opacity((!showSettings && selectedOption == nil) ? 0.4 : 1)
                        .allowsHitTesting(showSettings || selectedOption != nil)
                    }
                )
                .frame(height: GoalFlowLayout.topBarHeight)
            },
            content: {
                VStack(spacing: 0) {
                    GoalCreationStepIndicator(current: flowStepNumber)
                        .padding(.horizontal, GoalFlowLayout.horizontalPadding)
                        .padding(.bottom, 12)

                    if !showSettings {
                        shapePickerContent
                    } else {
                        settingsContent
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        )
        .onAppear(perform: applyDraftIfNeeded)
    }

    private var flowStepNumber: Int {
        if openSettingsDirectly || !draftText.isEmpty { return 3 }
        return 2
    }

    private var shapePickerContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                Text(lang.t(.selectGoalShape))
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 18)

                GoalShapeGrid(selectedID: selectedOption?.id) { option in
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.78)) {
                        selectOption(option)
                    }
                }
                .padding(.horizontal, GoalFlowLayout.horizontalPadding)
            }
            .padding(.bottom, 24)
        }
    }

    private var settingsContent: some View {
        GeometryReader { geo in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    if !draftText.isEmpty {
                        GoalDraftBanner(goalText: draftText, goalType: selectedGoal)
                    } else {
                        Text(lang.t(.goalSetup))
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    switch selectedGoal {
                    case .reachTarget:
                        ReachTargetContent(
                            goalTitle:           draftText,
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
                            targetNumber:   $capturedTarget,
                            selectedDays:   $capturedDays,
                            startTime:      $capturedStartTime,
                            endTime:        $capturedEndTime
                        )
                    case .none:
                        EmptyView()
                    }
                }
                .frame(maxWidth: .infinity, minHeight: geo.size.height, alignment: .top)
                .padding(.horizontal, GoalFlowLayout.horizontalPadding)
                .padding(.bottom, 20)
            }
        }
    }

    private func selectOption(_ option: GoalShapeOption) {
        selectedOption = option
        selectedGoal = option.goalType
        capturedIsMilestoneMode = option.isMilestoneMode
        capturedIsStreakMode = option.isStreakMode
    }

    private var settingsScreenTitle: String {
        showSettings ? lang.t(.goalSetup) : lang.t(.selectGoalShape)
    }

    private func handleBack() {
        if showSettings, !openSettingsDirectly {
            withAnimation { showSettings = false }
        } else {
            onBack?()
        }
    }

    private func applyDraftIfNeeded() {
        guard !draftText.isEmpty else { return }
        let draft = GoalSuggestionData.parse(draftText)
        if let n = draft.targetNumber { capturedTarget = min(max(n, 1), 1000) }
        if let b = draft.baselineNumber { capturedBaseline = b }
        if let u = draft.unit, !u.isEmpty { capturedUnit = u }
        if draft.prefersMilestones {
            capturedIsMilestoneMode = true
            capturedIsStreakMode = false
        }
        if draft.prefersStreak {
            capturedIsStreakMode = true
            capturedIsMilestoneMode = false
        }
        if let type = selectedGoal {
            selectedOption = GoalShapeOption.matching(
                type: type,
                milestone: capturedIsMilestoneMode,
                streak: capturedIsStreakMode
            ) ?? GoalShapeOption.defaultFor(type)
        }
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
    @EnvironmentObject private var lang: LanguageManager
    let goalTitle: String
    @Binding var targetNumber:        Int
    @Binding var unit:                String
    @Binding var deadlineDate:        Date?
    @Binding var selectedDays:        Set<Int>
    @Binding var startTime:           Date
    @Binding var endTime:             Date
    @Binding var isMilestoneMode:     Bool
    @Binding var scopeSize:           Double
    @Binding var dailyTimePreference: Int
    @State private var showMore = false

    private var unitLabel: String { unit.isEmpty ? "units" : unit }

    var body: some View {
        GoalSetupPanel {
            VStack(alignment: .leading, spacing: GoalFormStyle.compactSpacing) {
                GoalFormField(title: lang.t(.daysOfWeek)) {
                    WeekDaysSelector(selectedDays: $selectedDays)
                }
                GoalFormField(title: lang.t(.preferredTime)) {
                    TimePickerRow(startTime: $startTime, endTime: $endTime)
                }
                GoalFormField(title: lang.t(.targetNumber)) {
                    NumberStepper(title: "", value: $targetNumber, range: 1...1000, suffix: unitLabel, allowsTyping: true, compact: true)
                }
                GoalFormField(title: lang.t(.deadline)) {
                    OptionalGoalDateField(date: $deadlineDate)
                }
                GoalFormField(title: lang.t(.howToTrack)) {
                    GlassToggle(option1: lang.t(.total), option2: lang.t(.milestones), isOption1: Binding(
                        get: { !isMilestoneMode },
                        set: { isMilestoneMode = !$0 }
                    ))
                }

                if isMilestoneMode {
                    GoalFormField(title: lang.t(.scopeSize)) {
                        GlassSlider(value: $scopeSize, range: 0...100)
                            .padding(.horizontal, 4)
                    }
                    GoalFormField(title: lang.t(.dailyTimePreference)) {
                        NumberStepper(title: "", value: $dailyTimePreference, range: 5...180, suffix: lang.language == .arabic ? "د" : "min", compact: true)
                    }
                }

                moreOptionsButton

                if showMore {
                    GoalFormField(title: lang.t(.unit)) {
                        CustomTextField(placeholder: lang.t(.phUnit), text: $unit)
                    }
                }
            }
        }
    }

    private var moreOptionsButton: some View {
        Button {
            withAnimation(.spring(response: 0.3)) { showMore.toggle() }
        } label: {
            HStack(spacing: 6) {
                Text(showMore ? lang.t(.lessOptions) : lang.t(.moreOptions))
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.55))
                Image(systemName: showMore ? "chevron.up" : "chevron.down")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.55))
            }
        }
        .buttonStyle(.plain)
    }

}

// MARK: - BuildHabitContent
struct BuildHabitContent: View {
    @EnvironmentObject private var lang: LanguageManager
    @Binding var selectedDays: Set<Int>
    @Binding var startTime:    Date
    @Binding var endTime:      Date
    @Binding var unit:         String
    @Binding var isStreakMode:  Bool
    @Binding var targetNumber: Int
    @Binding var breakDays:    Int
    @State private var showMore = false

    var body: some View {
        GoalSetupPanel {
            VStack(alignment: .leading, spacing: GoalFormStyle.compactSpacing) {
                if !isStreakMode {
                    GoalFormField(title: lang.t(.daysOfWeek)) {
                        WeekDaysSelector(selectedDays: $selectedDays)
                    }
                }
                GoalFormField(title: lang.t(.preferredTime)) {
                    TimePickerRow(startTime: $startTime, endTime: $endTime)
                }
                GoalFormField(title: lang.t(.habitType)) {
                    GlassToggle(option1: lang.t(.schedule), option2: lang.t(.streak), isOption1: Binding(
                        get: { !isStreakMode },
                        set: { isStreakMode = !$0 }
                    ))
                }
                if isStreakMode {
                    GoalFormField(title: lang.t(.targetDays)) {
                        NumberStepper(title: "", value: $targetNumber, range: 1...365, suffix: lang.language == .arabic ? "يوم" : "days", compact: true)
                    }
                }
                Button {
                    withAnimation(.spring(response: 0.3)) { showMore.toggle() }
                } label: {
                    HStack(spacing: 6) {
                        Text(showMore ? lang.t(.lessOptions) : lang.t(.moreOptions))
                            .font(.system(size: 14, weight: .medium)).foregroundColor(.white.opacity(0.5))
                        Image(systemName: showMore ? "chevron.up" : "chevron.down")
                            .font(.system(size: 11)).foregroundColor(.white.opacity(0.5))
                    }
                }
                .buttonStyle(.plain)
                if showMore {
                    GoalFormField(title: lang.t(.activity)) {
                        CustomTextField(placeholder: lang.t(.phActivity), text: $unit)
                    }
                    if isStreakMode {
                        GoalFormField(title: lang.t(.breakDaysAllowed)) {
                            NumberStepper(title: "", value: $breakDays, range: 0...7, suffix: "", compact: true)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - LevelUpContent
struct LevelUpContent: View {
    @EnvironmentObject private var lang: LanguageManager
    @Binding var activity:     String
    @Binding var targetLevel:  Int
    @Binding var selectedDays: Set<Int>
    @Binding var stepUpPace:   Int

    var body: some View {
        GoalSetupPanel {
            VStack(alignment: .leading, spacing: GoalFormStyle.compactSpacing) {
                GoalFormField(title: lang.t(.daysOfWeek)) {
                    WeekDaysSelector(selectedDays: $selectedDays)
                }
                GoalFormField(title: lang.t(.activity)) {
                    CustomTextField(placeholder: lang.t(.phActivity), text: $activity)
                }
                HStack(alignment: .top, spacing: 10) {
                    GoalFormField(title: lang.t(.targetLevel)) {
                        NumberStepper(title: "", value: $targetLevel, range: 1...100, suffix: "", allowsTyping: true, compact: true)
                    }
                    .frame(maxWidth: .infinity)
                    GoalFormField(title: lang.t(.stepUpEvery)) {
                        NumberStepper(title: "", value: $stepUpPace, range: 1...52, suffix: lang.t(.weeks), compact: true)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

// MARK: - ReduceContent
struct ReduceContent: View {
    @EnvironmentObject private var lang: LanguageManager
    @Binding var metricType:     String
    @Binding var isReduceBy:     Bool
    @Binding var baselineNumber: Int
    @Binding var targetNumber:   Int
    @Binding var selectedDays:   Set<Int>
    @Binding var startTime:      Date
    @Binding var endTime:        Date

    private var metricSuffix: String { metricType.isEmpty ? "" : metricType }

    var body: some View {
        GoalSetupPanel {
            VStack(alignment: .leading, spacing: GoalFormStyle.compactSpacing) {
                GoalFormField(title: lang.t(.daysOfWeek)) {
                    WeekDaysSelector(selectedDays: $selectedDays)
                }
                GoalFormField(title: lang.t(.preferredTime)) {
                    TimePickerRow(startTime: $startTime, endTime: $endTime)
                }
                HStack(alignment: .top, spacing: 10) {
                    GoalFormField(title: lang.t(.startingNumber)) {
                        NumberStepper(
                            title: "",
                            value: $baselineNumber,
                            range: 0...1000,
                            suffix: metricSuffix,
                            allowsTyping: true,
                            compact: true
                        )
                    }
                    .frame(maxWidth: .infinity)
                    GoalFormField(title: lang.t(.targetNumberLabel)) {
                        NumberStepper(
                            title: "",
                            value: $targetNumber,
                            range: 0...1000,
                            suffix: metricSuffix,
                            allowsTyping: true,
                            compact: true
                        )
                    }
                    .frame(maxWidth: .infinity)
                }
                GoalFormField(title: lang.t(.metricType)) {
                    CustomTextField(placeholder: lang.t(.phMetric), text: $metricType)
                }
                GoalFormField(title: lang.t(.trackingMode)) {
                    GlassToggle(option1: lang.t(.reduceBy), option2: lang.t(.stayUnder), isOption1: $isReduceBy)
                }
            }
        }
    }
}

#Preview {
    GoalShapeView(onFinished: { _, _ in }, onBack: {})
        .environmentObject(LanguageManager())
}
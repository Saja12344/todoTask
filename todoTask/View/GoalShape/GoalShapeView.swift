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
        onFinished: ((GoalType, GoalSettings) -> Void)? = nil,
        onBack: (() -> Void)? = nil
    ) {
        self.draftText = draftText
        self.openSettingsDirectly = openSettingsDirectly
        self._selectedGoal = State(initialValue: selectedGoal)
        self._showSettings = State(initialValue: openSettingsDirectly || showSettings)
        self.onFinished = onFinished
        self.onBack = onBack
    }

    var body: some View {
        GoalFlowScreen(
            background: {
                ZStack {
                    Rectangle()
                        .fill(LinearGradient(colors: [.darkBlu, .dark], startPoint: .bottom, endPoint: .top))
                    Image("Gliter")
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(1.9)
                        .contrast(1.8)
                        .saturation(1.8)
                }
            },
            topBar: {
                GoalFlowNavigationRow(
                    onBack: handleBack,
                    trailing: {
                        GoalFlowNextButton(action: {
                            if !showSettings {
                                if selectedGoal != nil { withAnimation { showSettings = true } }
                            } else if let type = selectedGoal {
                                onFinished?(type, buildSettings())
                            }
                        })
                    }
                )
                .frame(height: GoalFlowLayout.topBarHeight)
            },
            content: {
                GeometryReader { geo in
                    VStack(spacing: 0) {
                        GoalCreationStepIndicator(current: 3)
                            .padding(.horizontal, GoalFlowLayout.horizontalPadding)
                            .padding(.bottom, 12)

                        Text(settingsScreenTitle)
                            .font(.system(size: GoalFlowLayout.scaled(28, width: geo.size.width), weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 12)
                            .padding(.bottom, showSettings ? 8 : 16)

                        if !showSettings {
                            Spacer(minLength: 8)
                            LazyVGrid(
                                columns: [
                                    GridItem(.flexible(), spacing: 16),
                                    GridItem(.flexible(), spacing: 16)
                                ],
                                spacing: 16
                            ) {
                                GoalCard(
                                    icon: "scope",
                                    title: lang.goalTypeTitle(.reachTarget),
                                    description: lang.goalTypeDescription(.reachTarget),
                                    isSelected: selectedGoal == .reachTarget
                                ) { selectedGoal = .reachTarget }

                                GoalCard(
                                    icon: "flame.fill",
                                    title: lang.goalTypeTitle(.buildHabit),
                                    description: lang.goalTypeDescription(.buildHabit),
                                    isSelected: selectedGoal == .buildHabit
                                ) { selectedGoal = .buildHabit }

                                GoalCard(
                                    icon: "chart.line.uptrend.xyaxis",
                                    title: lang.goalTypeTitle(.levelUp),
                                    description: lang.goalTypeDescription(.levelUp),
                                    isSelected: selectedGoal == .levelUp
                                ) { selectedGoal = .levelUp }

                                GoalCard(
                                    icon: "arrow.down.circle",
                                    title: lang.goalTypeTitle(.reduce),
                                    description: lang.goalTypeDescription(.reduce),
                                    isSelected: selectedGoal == .reduce
                                ) { selectedGoal = .reduce }
                            }
                            .padding(.horizontal, GoalFlowLayout.horizontalPadding)
                            Spacer(minLength: 8)
                        } else {
                            ScrollView(showsIndicators: false) {
                                VStack(spacing: 16) {
                                    if !draftText.isEmpty {
                                        GoalDraftBanner(goalText: draftText, goalType: selectedGoal)
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
                                            targetNumber:   $capturedTarget
                                        )
                                    case .none:
                                        EmptyView()
                                    }
                                }
                                .padding(.horizontal, GoalFlowLayout.horizontalPadding)
                                .padding(.bottom, 32)
                            }
                        }
                    }
                }
            }
        )
        .onAppear(perform: applyDraftIfNeeded)
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
        if draft.prefersMilestones { capturedIsMilestoneMode = true }
        if draft.prefersStreak { capturedIsStreakMode = true }
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
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                GoalFormField(title: lang.t(.targetNumber)) {
                    NumberStepper(title: "", value: $targetNumber, range: 1...1000, suffix: unitLabel, allowsTyping: true)
                }

                GoalFormField(title: lang.t(.deadline)) {
                    OptionalGoalDateField(date: $deadlineDate)
                }
                Text(lang.t(.deadlineHint))
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.45))
                    .fixedSize(horizontal: false, vertical: true)

                GoalFormField(title: lang.t(.howToTrack)) {
                    GlassToggle(option1: lang.t(.total), option2: lang.t(.milestones), isOption1: Binding(
                        get: { !isMilestoneMode },
                        set: { isMilestoneMode = !$0 }
                    ))
                    trackingExplanation(
                        title: isMilestoneMode ? lang.t(.milestones) : lang.t(.total),
                        body: isMilestoneMode ? milestoneExplanation : totalExplanation
                    )
                }

                if isMilestoneMode {
                    GoalFormField(title: lang.t(.scopeSize)) {
                        GlassSlider(value: $scopeSize, range: 0...100)
                            .padding(.horizontal, 8)
                    }
                    GoalFormField(title: lang.t(.dailyTimePreference)) {
                        NumberStepper(title: "", value: $dailyTimePreference, range: 5...180, suffix: lang.language == .arabic ? "د" : "min")
                    }
                }

                moreOptionsButton

                if showMore {
                    GoalFormField(title: lang.t(.unit)) {
                        CustomTextField(placeholder: lang.t(.phUnit), text: $unit)
                    }
                    GoalFormField(title: lang.t(.daysOfWeek)) {
                        WeekDaysSelector(selectedDays: $selectedDays)
                    }
                    GoalFormField(title: lang.t(.preferredTime)) {
                        TimePickerRow(startTime: $startTime, endTime: $endTime)
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

    private var totalExplanation: String {
        if goalTitle.isEmpty { return lang.t(.totalExplainEmpty) }
        return String(format: lang.t(.totalExplainGoal), goalTitle, targetNumber, unitLabel)
    }

    private var milestoneExplanation: String {
        if goalTitle.isEmpty { return lang.t(.milestoneExplainEmpty) }
        return String(format: lang.t(.milestoneExplainGoal), goalTitle, targetNumber, unitLabel)
    }

    private func trackingExplanation(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white.opacity(0.85))
            Text(body)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.06)))
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
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                GoalFormField(title: lang.t(.habitType)) {
                    GlassToggle(option1: lang.t(.schedule), option2: lang.t(.streak), isOption1: Binding(
                        get: { !isStreakMode },
                        set: { isStreakMode = !$0 }
                    ))
                }
                if !isStreakMode {
                    GoalFormField(title: lang.t(.daysOfWeek)) {
                        WeekDaysSelector(selectedDays: $selectedDays)
                    }
                }
                GoalFormField(title: lang.t(.preferredTime)) {
                    TimePickerRow(startTime: $startTime, endTime: $endTime)
                }
                if isStreakMode {
                    GoalFormField(title: lang.t(.targetDays)) {
                        NumberStepper(title: "", value: $targetNumber, range: 1...365, suffix: lang.language == .arabic ? "يوم" : "days")
                    }
                }
                Button {
                    withAnimation(.spring(response: 0.3)) { showMore.toggle() }
                } label: {
                    HStack(spacing: 6) {
                        Text(showMore ? lang.t(.lessOptions) : lang.t(.moreOptions))
                            .font(.system(size: 15, weight: .medium)).foregroundColor(.white.opacity(0.55))
                        Image(systemName: showMore ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12)).foregroundColor(.white.opacity(0.55))
                    }
                }
                .buttonStyle(.plain)
                if showMore {
                    GoalFormField(title: lang.t(.activity)) {
                        CustomTextField(placeholder: lang.t(.phActivity), text: $unit)
                    }
                    if isStreakMode {
                        GoalFormField(title: lang.t(.breakDaysAllowed)) {
                            NumberStepper(title: "", value: $breakDays, range: 0...7, suffix: "")
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
        GlassCard {
            VStack(alignment: .leading, spacing: 20) {
                GoalFormField(title: lang.t(.activity)) {
                    CustomTextField(placeholder: lang.t(.phActivity), text: $activity)
                }
                GoalFormField(title: lang.t(.targetLevel)) {
                    NumberStepper(title: "", value: $targetLevel, range: 1...100, suffix: "", allowsTyping: true)
                }
                GoalFormField(title: lang.t(.daysOfWeek)) {
                    WeekDaysSelector(selectedDays: $selectedDays)
                }
                GoalFormField(title: lang.t(.stepUpEvery)) {
                    NumberStepper(title: "", value: $stepUpPace, range: 1...52, suffix: lang.t(.weeks))
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

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 20) {
                GoalFormField(title: lang.t(.metricType)) {
                    CustomTextField(placeholder: lang.t(.phMetric), text: $metricType)
                }
                GoalFormField(title: lang.t(.trackingMode)) {
                    GlassToggle(option1: lang.t(.reduceBy), option2: lang.t(.stayUnder), isOption1: $isReduceBy)
                    reduceModeExplanation
                }
                GoalFormField(title: lang.t(.startingNumber)) {
                    NumberStepper(title: "", value: $baselineNumber, range: 0...1000, suffix: metricType.isEmpty ? "" : metricType, allowsTyping: true)
                }
                GoalFormField(title: lang.t(.targetNumberLabel)) {
                    NumberStepper(title: "", value: $targetNumber, range: 0...1000, suffix: metricType.isEmpty ? "" : metricType, allowsTyping: true)
                }
            }
        }
    }

    private var reduceModeExplanation: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(isReduceBy ? lang.t(.reduceBy) : lang.t(.stayUnder))
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white.opacity(0.85))
            Text(isReduceBy ? lang.t(.reduceByExplain) : lang.t(.stayUnderExplain))
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.06)))
    }
}

#Preview {
    GoalShapeView(onFinished: { _, _ in }, onBack: {})
        .environmentObject(LanguageManager())
}
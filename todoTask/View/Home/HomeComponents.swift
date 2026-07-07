//
//  HomeComponents.swift
//  todoTask
//

import SwiftUI
import UserNotifications

// MARK: - CheckBoxItem
struct CheckBoxItem {
    var name: String
    var isChecked: Bool
}

struct CheckBoxView: View {
    @Binding var item: CheckBoxItem

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .foregroundColor(.clear)
                .glassEffect(.clear, in: .rect(cornerRadius: 20))
            HStack {
                Text(item.name)
                Spacer()
                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isChecked ? .blue : .gray)
                    .font(.system(size: 32))
                    .glassEffect(.clear.interactive())
                    .onTapGesture { item.isChecked.toggle() }
            }
            .padding(.horizontal, 30)
        }
        .padding(.horizontal, 20)
    }
}


// MARK: - today
struct today: View {
    @EnvironmentObject private var store: OrbGoalStore
    @EnvironmentObject private var lang: LanguageManager
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var calVM     = MiniCalendarViewModel()
    @StateObject private var energyVM  = DailyEnergyViewModel()
    @State private var draftTitle:     String        = ""
    @State private var chosenType:     GoalType?     = nil
    @State private var chosenSettings: GoalSettings? = nil
    @State private var path:           [GoalCreationStep] = []
    @State private var selectedEnergyID: String? = nil
    @State private var reflectionContext: TaskReflectionContext?

    private var selectedDate: Date { calVM.selectedDate }

    var todayItems: [TodayItem] {
        let energy = energyVM.energy(for: selectedDate)
        return store.todayTasks(for: selectedDate, energy: energy).map {
            TodayItem(goal: $0.goal, task: $0.task, isLate: $0.isLate)
        }
    }

    private var dailyQuote: String {
        let cal   = Calendar.current
        let start = cal.startOfDay(for: Date())
        let days  = Int(start.timeIntervalSince1970 / 86_400)
        let all   = Quotes.all
        guard !all.isEmpty else { return "" }
        return all[abs(days) % all.count]
    }

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Rectangle()
                    .fill(LinearGradient(colors: [.darkBlu, .dark], startPoint: .bottom, endPoint: .top))
                    .ignoresSafeArea()
                Image("Background 4")
                    .resizable()
                    .ignoresSafeArea()
                    .opacity(0.7)
                Image("Gliter")
                    .resizable()
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 8) {

                    Text(dailyQuote)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 7)
                        .font(.footnote.weight(.light))

                    ZStack(alignment: .center) {
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundColor(.clear)
                            .frame(height: 124)
                            .glassEffect(.clear, in: .rect(cornerRadius: 20))

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Menu {
                                    ForEach(calVM.availableMonths, id: \.self) { month in
                                        Button { calVM.changeMonth(to: month) } label: {
                                            Text(month, format: .dateTime.month(.wide))
                                        }
                                    }
                                } label: {
                                    HStack(spacing: 6) {
                                        Text(calVM.monthTitle).font(.headline).foregroundColor(.white).padding(.leading)
                                        Image(systemName: "chevron.up.chevron.down").font(.caption).foregroundColor(.white)
                                    }
                                }
                                Spacer()
                                Button {
                                    withAnimation(.easeInOut(duration: 0.25)) { calVM.goToToday() }
                                } label: {
                                    HStack {
                                        Image(systemName: "calendar")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white.opacity(0.9))
                                            .padding(.leading, 6)
                                        Text(lang.t(.todayShortcut))
                                            .font(.system(size: 17, weight: .medium))
                                    }
                                }
                                .frame(width: 100, height: 30)
                                .buttonStyle(.plain)
                                .glassEffect(.clear.interactive())
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 5)

                            CalendarWeekRow(calVM: calVM)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)

                    HStack {
                        Text(lang.t(.todaysTasks))
                            .foregroundColor(.primary).font(.title).bold().padding(.leading, 20)
                        Spacer()
                        let done  = todayItems.filter { $0.task.isDone }.count
                        let total = todayItems.count
                        if total > 0 {
                            Text("\(done)/\(total)")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.trailing, 30)
                        }
                    }

                    ZStack {
                        RoundedRectangle(cornerRadius: 20).foregroundColor(.clear)

                        if todayItems.isEmpty {
                            VStack(spacing: 10) {
                                Image(systemName: "moon.stars").font(.system(size: 36)).foregroundColor(.white.opacity(0.3))
                                Text(lang.t(.noTasksToday))
                                    .foregroundColor(.white.opacity(0.5)).font(.subheadline)
                                Text(lang.t(.addGoalHint))
                                    .foregroundColor(.white.opacity(0.3)).font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 300)
                        } else {
                            ScrollView {
                                VStack(alignment: .center, spacing: 8) {
                                    ForEach(todayItems) { item in
                                        let lines = item.goal.todayTaskLines(for: item.task, lang: lang)
                                        TodayTaskRow(
                                            task: item.task,
                                            goal: item.goal,
                                            primaryText: lines.primary,
                                            secondaryText: lines.secondary,
                                            isLate: item.isLate,
                                            onReflect: item.task.isFullyComplete ? {
                                                reflectionContext = store.reflectionContext(
                                                    goalID: item.goal.id,
                                                    taskID: item.task.id
                                                )
                                            } : nil
                                        ) { newAmount in
                                            let wasComplete = item.task.isFullyComplete
                                            if let newAmount {
                                                store.setTaskCompletedAmount(
                                                    goalID: item.goal.id,
                                                    taskID: item.task.id,
                                                    amount: newAmount
                                                )
                                            } else {
                                                store.toggleTodayTask(goalID: item.goal.id, taskID: item.task.id)
                                            }
                                            maybeOpenReflection(
                                                goalID: item.goal.id,
                                                taskID: item.task.id,
                                                wasComplete: wasComplete
                                            )
                                        }
                                    }
                                }
                                .padding(.horizontal, 13)
                                .padding(.vertical, 8)
                            }
                            .frame(maxHeight: .infinity)
                        }
                    }

                    Spacer()
                }

                if energyVM.showPromptForToday {
                    EnergyPromptOverlay(energyVM: energyVM, selectedEnergyID: $selectedEnergyID)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: startCreation) {
                        Image(systemName: "plus")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .colorScheme(.dark)
            .onAppear {
                LoginTracker.recordTodayOpened()
                energyVM.refreshToday()
                if let entry = energyVM.todayEntry {
                    selectedEnergyID = lang.energyLevels().first(where: { $0.value == entry.value })?.id.uuidString
                }
            }
            .navigationDestination(for: GoalCreationStep.self) { step in
                switch step {

                case .write:
                    WriteGoalView(
                        onDone: { title, suggestion in
                            draftTitle = title
                            path.append(.suggested(text: title, type: suggestion))
                        },
                        onSkipToManual: {
                            draftTitle = ""
                            path.append(.configure(
                                type: nil, draftText: "", openSettings: false,
                                milestoneMode: false, streakMode: false
                            ))
                        },
                        onCancel: { _ = path.popLast() }
                    )

                case let .suggested(text, type):
                    SuggestedGoalView(
                        goalText: text,
                        suggestedType: type,
                        onContinue: { option in
                            chosenType = option.goalType
                            path.append(.configure(
                                type: option.goalType,
                                draftText: draftTitle,
                                openSettings: true,
                                milestoneMode: option.isMilestoneMode,
                                streakMode: option.isStreakMode
                            ))
                        },
                        onBack: { _ = path.popLast() }
                    )

                case let .configure(type, draftText, openSettings, milestoneMode, streakMode):
                    GoalShapeView(
                        selectedGoal: type,
                        draftText: draftText,
                        openSettingsDirectly: openSettings,
                        initialMilestoneMode: milestoneMode,
                        initialStreakMode: streakMode,
                        onFinished: { type, settings in
                            chosenType = type
                            chosenSettings = settings
                            path.append(.design)
                        },
                        onBack: { _ = path.popLast() }
                    )
                    .navigationBarBackButtonHidden(true)

                case .design:
                    GoalDesign { design in
                        var newGoal = OrbGoal(
                            id: UUID(),
                            title: draftTitle.isEmpty ? "New Goal" : draftTitle,
                            design: design,
                            settings: chosenSettings
                        )
                        if let settings = chosenSettings {
                            newGoal.tasks = TaskGenerator.generate(
                                from: settings,
                                goalID: newGoal.id,
                                goalTitle: newGoal.title
                            )
                        }
                        store.add(newGoal)
                        path.removeAll()
                    }
                    .environmentObject(store)
                    .navigationBarBackButtonHidden(true)
//                case .loading(shape: let shape, text: let text):
                    
             
                    
                }
            }
            .sheet(item: $reflectionContext) { context in
                TaskReflectionSheet(context: context)
                    .environmentObject(store)
                    .environmentObject(lang)
            }
        }
    }

    private func startCreation() {
        draftTitle = ""; chosenType = nil; chosenSettings = nil
        path = [.write]
    }

    private func maybeOpenReflection(goalID: UUID, taskID: UUID, wasComplete: Bool) {
        guard let updated = store.goal(with: goalID)?.tasks.first(where: { $0.id == taskID }),
              updated.isFullyComplete else { return }
        guard !wasComplete else { return }
        // Present after the list finishes refreshing so the sheet isn't dismissed by state churn.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            reflectionContext = store.reflectionContext(goalID: goalID, taskID: taskID)
        }
    }
}

// MARK: - TodayTaskRow
struct TodayTaskRow: View {
    @EnvironmentObject private var lang: LanguageManager
    let task:            GoalTask
    let goal:            OrbGoal
    let primaryText:     String
    let secondaryText:   String
    var isLate:          Bool = false
    var onReflect:       (() -> Void)? = nil
    let onChange:        (Int?) -> Void

    private var accent: Color { goal.accentColor }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.clear)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 68)
                .glassEffect(.clear, in: .rect(cornerRadius: 20))
                .overlay(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [accent, accent.opacity(0.15)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 4)
                        .padding(.vertical, 10)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(accent.opacity(task.isFullyComplete ? 0.35 : 0.12), lineWidth: 1)
                }

            HStack(spacing: 12) {
                PlanetOrbView(
                    size: 28,
                    gradientColors: goal.design.gradientStops.map { $0.swiftUIColor },
                    glow: min(goal.design.glow, 0.12),
                    textureAssetName: goal.design.textureAssetName,
                    textureOpacity: goal.design.textureOpacity * 0.65
                )
                .frame(width: 32, height: 32)
                .opacity(task.isFullyComplete ? 0.45 : 1)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(primaryText)
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .medium))
                            .strikethrough(task.isFullyComplete, color: .white.opacity(0.5))
                            .opacity(task.isFullyComplete ? 0.5 : 1)
                            .lineLimit(2)
                        if isLate && !task.isFullyComplete {
                            Text(lang.t(.late))
                                .font(.caption.bold())
                                .foregroundColor(.red)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(.red.opacity(0.15)))
                        }
                    }
                    if !secondaryText.isEmpty {
                        Text(secondaryText)
                            .font(.caption)
                            .foregroundColor(accent.opacity(0.75))
                            .lineLimit(1)
                    }
                    if task.isFullyComplete, task.reflectionNote != nil {
                        Text(lang.t(.reflectionTitle))
                            .font(.caption2.weight(.medium))
                            .foregroundColor(accent.opacity(0.7))
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if task.isFullyComplete { onReflect?() }
                }
                Spacer(minLength: 8)
                TaskCompletionControl(task: task, accent: accent, onChange: onChange)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - EnergyPromptOverlay
struct EnergyPromptOverlay: View {
    @EnvironmentObject private var lang: LanguageManager
    @ObservedObject var energyVM: DailyEnergyViewModel
    @Binding var selectedEnergyID: String?

    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
            VStack(spacing: 10) {
                Text(lang.t(.energyPrompt)).bold().foregroundColor(.white)
                HStack {
                    ForEach(lang.energyLevels()) { level in
                        Button {
                            Task {
                                await energyVM.setEnergyForToday(level)
                                await MainActor.run { selectedEnergyID = level.id.uuidString }
                            }
                        } label: {
                            VStack(spacing: 12) {
                                Image(systemName: level.icon).font(.system(size: 35)).foregroundColor(.white)
                                Text(level.title).foregroundColor(.white).font(.system(size: 16, weight: .medium))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 120)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(selectedEnergyID == level.id.uuidString ? Color.accent : Color.clear, lineWidth: 2)
                            )
                        }
                        .glassEffect(.clear.interactive(), in: .rect(cornerRadius: 25))
                    }
                }
                .padding(.horizontal)
                if let sid = selectedEnergyID,
                   let sel = lang.energyLevels().first(where: { $0.id.uuidString == sid }) {
                    Text(String(format: lang.t(.energySelectedFormat), sel.title))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                } else {
                    Text(lang.t(.energyChangeLater))
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.top)
                }
            }
            .padding(30)
            .frame(maxWidth: 500)
            .glassEffect(.clear.tint(.darkBlu.opacity(0.5)), in: .rect(cornerRadius: 20))
        }
        .transition(.opacity)
        .animation(.easeInOut, value: energyVM.showPromptForToday)
    }
}

// MARK: - Settings
struct Settings: View {
    @EnvironmentObject private var userVM: UserViewModel
    @EnvironmentObject private var store: OrbGoalStore
    @EnvironmentObject private var lang: LanguageManager
    @State private var showLogoutAlert: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    @State private var showClearGoalsConfirm: Bool = false

    var body: some View {
        ZStack {
            Rectangle()
                .fill(LinearGradient(colors: [.darkBlu, .dark], startPoint: .bottom, endPoint: .top))
                .ignoresSafeArea()
            Image("Background")
                .resizable()
                .ignoresSafeArea()
                .opacity(0.7)
            Image("Gliter")
                .resizable()
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(lang.t(.settingsTitle))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                    // معلّق مؤقتاً — لا تحذف
                    // Text(displayName) ...
                    // Text("\(lang.t(.guestIDLabel)) \(displayID)") ...

                    Text(lang.t(.appManagement))
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.horizontal, 20)

                    settingsCard {
                        SettingsRow(icon: "globe", title: lang.t(.language), subtitle: lang.t(.languageHint)) {
                            Picker("", selection: $lang.language) {
                                ForEach(AppLanguage.allCases) { option in
                                    Text(option.displayName).tag(option)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(.cyan)
                        }

                        settingsDivider

                        SettingsRow(icon: "bell.badge", title: lang.t(.notification)) {
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.white.opacity(0.35))
                        }
                        .onTapGesture {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }

                        settingsDivider

                        NavigationLink(destination: AchievementsView().orbitForcedDark()) {
                            SettingsRow(icon: "trophy.fill", title: lang.t(.achievementsTitle)) {
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(.white.opacity(0.35))
                            }
                        }
                        .buttonStyle(.plain)

                        settingsDivider

                        NavigationLink(destination: Report().orbitForcedDark()) {
                            SettingsRow(icon: "chart.bar.fill", title: lang.t(.progressReport)) {
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(.white.opacity(0.35))
                            }
                        }
                        .buttonStyle(.plain)

                        settingsDivider

                        NavigationLink(destination: Energy().orbitForcedDark()) {
                            SettingsRow(icon: "bolt.heart.fill", title: lang.t(.energySettings)) {
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(.white.opacity(0.35))
                            }
                        }
                        .buttonStyle(.plain)
                    }

                    Text(lang.t(.accountManagement))
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.horizontal, 20)
                        .padding(.top, 4)

                    settingsCard {
                        SettingsRow(icon: "target", title: lang.t(.clearGoals), tint: Color(.lightRed)) {
                            EmptyView()
                        }
                        .onTapGesture { showClearGoalsConfirm = true }

                        settingsDivider

                        SettingsRow(icon: "rectangle.portrait.and.arrow.right", title: lang.t(.logOut), tint: Color(.lightRed)) {
                            EmptyView()
                        }
                        .onTapGesture { showLogoutAlert = true }

                        settingsDivider

                        SettingsRow(icon: "trash", title: lang.t(.deleteAccount), tint: Color(.lightRed)) {
                            EmptyView()
                        }
                        .onTapGesture { showDeleteConfirmation = true }
                    }
                }
                .padding(.bottom, 24)
            }
        }
        .confirmationDialog(lang.t(.deleteAccountQuestion), isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button(lang.t(.deletePermanently), role: .destructive) {
                store.clearAll()
                Task { await userVM.deleteAccount() }
            }
            Button(lang.t(.cancel), role: .cancel) {}
        } message: {
            Text(lang.t(.deleteAccountMessage))
        }
        .confirmationDialog(lang.t(.clearGoalsQuestion), isPresented: $showClearGoalsConfirm, titleVisibility: .visible) {
            Button(lang.t(.clearGoals), role: .destructive) { store.clearAll() }
            Button(lang.t(.cancel), role: .cancel) {}
        } message: {
            Text(lang.t(.clearGoalsMessage))
        }
        .alert(lang.t(.logOutQuestion), isPresented: $showLogoutAlert) {
            Button(lang.t(.cancel), role: .cancel) {}
            Button(lang.t(.logOut), role: .destructive) {
                store.clearAll()
                userVM.logOut()
            }
        } message: {
            Text(lang.t(.logOutMessage))
        }
        .orbitForcedDark()
    }

    private var settingsDivider: some View {
        Divider().background(Color.white.opacity(0.22))
    }

    @ViewBuilder
    private func settingsCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity)
        .glassEffect(.clear, in: .rect(cornerRadius: 24))
        .padding(.horizontal, 16)
    }
}

struct SettingsRow<Trailing: View>: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    var tint: Color = .white
    @ViewBuilder var trailing: () -> Trailing

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(tint.opacity(0.9))
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(tint)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.45))
                        .lineLimit(2)
                }
            }
            Spacer(minLength: 8)
            trailing()
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

// MARK: - Calendar week row (arrow direction fixed for RTL)

struct CalendarWeekRow: View {
    @ObservedObject var calVM: MiniCalendarViewModel
    @EnvironmentObject private var lang: LanguageManager

    var body: some View {
        HStack(spacing: 4) {
            Button { calVM.moveWeek(by: -1) } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
            }
            ForEach(calVM.visibleWeek, id: \.self) { date in
                DayView(date: date, selectedDate: calVM.selectedDate, today: calVM.today)
                    .frame(maxWidth: .infinity)
                    .onTapGesture { calVM.selectedDate = date }
            }
            Button { calVM.moveWeek(by: 1) } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .padding(.horizontal)
        .environment(\.layoutDirection, .leftToRight)
    }
}

// MARK: - DayView
struct DayView: View {
    let date: Date
    let selectedDate: Date
    let today: Date
    private let calendar = Calendar.current

    var isSelected: Bool { calendar.isDate(date, inSameDayAs: selectedDate) }
    var isToday:    Bool { calendar.isDate(date, inSameDayAs: today) }

    private var weekdayEN: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "EEE"
        return f.string(from: date)
    }

    var body: some View {
        VStack(spacing: 4) {
            Text(weekdayEN).font(.caption)
            Text(date, format: .dateTime.day()).font(.headline)
        }
        .frame(height: 56)
        .frame(maxWidth: .infinity)
        .background(
            isSelected ? Color.white.opacity(0.9) :
            isToday    ? Color.accent.opacity(0.35) :
            Color.darkBlu.opacity(0.8)
        )
        .foregroundColor(isSelected ? Color(.darkBlu) : .white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .glassEffect(.clear.interactive(), in: .rect(cornerRadius: 12))
    }
}

// MARK: - Notification helpers
func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
        DispatchQueue.main.async { print(granted ? "Notifications allowed" : "Notifications denied") }
    }
}

func notificationDenied(_ completion: @escaping (Bool) -> Void) {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
        completion(settings.authorizationStatus == .denied)
    }
}

#Preview {
    Home()
        .environmentObject(OrbGoalStore())
}
#Preview {
    Settings()
        .environmentObject(UserViewModel())
}
#Preview {
    FriendsV()
        .environmentObject(UserViewModel())
}
#Preview {
    GoalsPage()
        .environmentObject(UserViewModel())
}


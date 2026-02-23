//
//  HomeComponents.swift
//  todoTask
//
//  استبدل الملف الموجود بهذا كاملاً
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
                .frame(width: 330, height: 60)
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
            .padding(.all, 10)
            .padding(.leading, 30)
            .padding(.trailing, 30)
        }
        .padding(.trailing, 20)
    }
}

// MARK: - today (Main Home View)
struct today: View {
    @EnvironmentObject private var store: OrbGoalStore
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var calVM     = MiniCalendarViewModel()
    @StateObject private var energyVM  = DailyEnergyViewModel()

    @State private var selectedEnergyID: String? = nil

    // اليوم المحدد في الكالندر
    private var selectedDate: Date { calVM.selectedDate }

    // المهام المجدولة لليوم المحدد من كل الأهداف
    private var todayItems: [(goal: OrbGoal, task: GoalTask)] {
        store.todayTasks(for: selectedDate)
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
        ZStack {
            Rectangle()
                .fill(LinearGradient(colors: [.darkBlu, .dark], startPoint: .bottom, endPoint: .top))
                .ignoresSafeArea()
            Image("Background 4").resizable().ignoresSafeArea().opacity(0.4)
            Image("Gliter").resizable().ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {

                // ── Date + Quote ─────────────────────────────────
                Text(viewModel.formattedDate)
                    .foregroundColor(.primary)
                    .font(.system(size: 28, weight: .bold))
                    .padding(.leading, 20)

                Text(dailyQuote)
                    .padding(.leading, 20)
                    .padding(.bottom, 8)

                // ── Mini Calendar ─────────────────────────────────
                ZStack(alignment: .center) {
                    Rectangle()
                        .frame(width: 385, height: 134)
                        .foregroundColor(.clear)
                        .glassEffect(.regular, in: .rect(cornerRadius: 20))

                    VStack(alignment: .leading, spacing: 20) {
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

                        HStack(spacing: 5) {
                            Button { calVM.moveWeek(by: -1) } label: {
                                Image(systemName: "chevron.left").foregroundColor(.white)
                            }
                            ForEach(calVM.visibleWeek, id: \.self) { date in
                                DayView(date: date, selectedDate: calVM.selectedDate, today: calVM.today)
                                    .onTapGesture { calVM.selectedDate = date }
                            }
                            Button { calVM.moveWeek(by: 1) } label: {
                                Image(systemName: "chevron.right").foregroundColor(.white)
                            }
                        }
                    }
                }
                .padding(.leading, 7)
                .padding(.bottom, 12)

                // ── Today's Tasks Header ─────────────────────────
                HStack {
                    Text("Today's Tasks")
                        .foregroundColor(.primary).font(.largeTitle).bold().padding(.leading, 20)
                    Spacer()
                    // إجمالي المهام المكتملة اليوم
                    let done  = todayItems.filter { $0.task.isDone }.count
                    let total = todayItems.count
                    if total > 0 {
                        Text("\(done)/\(total)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.trailing, 20)
                    }
                }

                // ── Tasks List ────────────────────────────────────
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: 350, height: 300)
                        .foregroundColor(.clear)

                    if todayItems.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "moon.stars").font(.system(size: 36)).foregroundColor(.white.opacity(0.3))
                            Text("No tasks scheduled for this day")
                                .foregroundColor(.white.opacity(0.5)).font(.subheadline)
                            Text("Add a goal or pick another day")
                                .foregroundColor(.white.opacity(0.3)).font(.caption)
                        }
                        .frame(height: 300)
                    } else {
                        ScrollView {
                            VStack(alignment: .center, spacing: 8) {
                                ForEach(todayItems, id: \.task.id) { item in
                                    TodayTaskRow(
                                        task:     item.task,
                                        goalName: item.goal.title
                                    ) {
                                        store.toggleTodayTask(goalID: item.goal.id, taskID: item.task.id)
                                    }
                                }
                            }
                            .padding(.leading, 23)
                            .padding(.vertical, 8)
                        }
                        .frame(height: 300)
                    }
                }

                Spacer()
            }

            // ── Energy Prompt (مرة في اليوم) ─────────────────────
            if energyVM.showPromptForToday {
                EnergyPromptOverlay(
                    energyVM:        energyVM,
                    selectedEnergyID: $selectedEnergyID
                )
            }
        }
        .colorScheme(.dark)
        .onAppear {
            LoginTracker.recordTodayOpened()
            energyVM.refreshToday()
            if let entry = energyVM.todayEntry {
                selectedEnergyID = Energytoday.defaults.first(where: { $0.title == entry.title })?.id.uuidString
            }
        }
    }
}

// MARK: - TodayTaskRow
struct TodayTaskRow: View {
    let task:     GoalTask
    let goalName: String
    let onToggle: () -> Void

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .frame(width: 330, height: 68)
                .foregroundColor(.clear)
                .glassEffect(.clear, in: .rect(cornerRadius: 20))

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(task.title)
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .medium))
                        .strikethrough(task.isDone, color: .white.opacity(0.5))
                        .opacity(task.isDone ? 0.5 : 1)
                        .lineLimit(2)
                    Text(goalName)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }
                Spacer()
                Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isDone ? .blue : .gray)
                    .font(.system(size: 28))
                    .onTapGesture { onToggle() }
                    .animation(.easeInOut(duration: 0.2), value: task.isDone)
            }
            .padding(.horizontal, 20)
        }
        .padding(.trailing, 20)
    }
}

// MARK: - EnergyPromptOverlay
struct EnergyPromptOverlay: View {
    @ObservedObject var energyVM: DailyEnergyViewModel
    @Binding var selectedEnergyID: String?

    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
            RoundedRectangle(cornerRadius: 20)
                .frame(width: 350, height: 260)
                .glassEffect(.regular, in: .rect(cornerRadius: 20))
            VStack(spacing: 10) {
                Text("What's your energy level today?").bold()
                HStack {
                    ForEach(Energytoday.defaults) { level in
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
                            .frame(width: 105, height: 120)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(selectedEnergyID == level.id.uuidString ? Color.accent : Color.clear, lineWidth: 2)
                            )
                        }
                        .glassEffect(.clear.interactive(), in: .rect(cornerRadius: 25))
                    }
                }
                if let sid = selectedEnergyID,
                   let sel = Energytoday.defaults.first(where: { $0.id.uuidString == sid }) {
                    Text("Selected: \(sel.title)").font(.caption).foregroundColor(.white.opacity(0.9))
                } else {
                    Text("you can change it later in settings").font(.caption).padding(.top)
                }
            }
            .padding(.horizontal)
        }
        .transition(.opacity)
        .animation(.easeInOut, value: energyVM.showPromptForToday)
    }
}

// MARK: - Goals (placeholder tab)
struct Goals: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(LinearGradient(colors: [.darkBlu, .dark], startPoint: .bottom, endPoint: .top))
                .ignoresSafeArea()
            Image("Gliter").resizable().ignoresSafeArea()
        }
        .colorScheme(.dark)
    }
}

// MARK: - Settings
struct Settings: View {
    @EnvironmentObject private var userVM: UserViewModel
    @State private var showSettingsButton = false
    @State private var isEditingName: Bool = false
    @State private var draftName: String = ""
    @State private var showGuestLogoutAlert: Bool = false

    private var displayName: String {
        if let name = userVM.currentUser?.username, !name.isEmpty { return name }
        return "Guest"
    }
    private var displayID: String {
        if let id = userVM.currentUser?.id, !id.isEmpty { return String(id.prefix(8)) + "..." }
        return "N/A"
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(LinearGradient(colors: [.darkBlu, .dark], startPoint: .bottom, endPoint: .top))
                .ignoresSafeArea()
            Image("Background").resizable().ignoresSafeArea()
            Image("Gliter").resizable().ignoresSafeArea()

            VStack(alignment: .leading, spacing: 4) {
                Text(displayName).font(.system(size: 28, weight: .bold)).foregroundColor(.primary).padding(.horizontal, 20)
                Text("ID: \(displayID)").font(.caption).foregroundColor(.white.opacity(0.7)).padding(.horizontal, 20).padding(.bottom, 8)
                Text("App Management").padding(.leading, 20)

                ZStack {
                    RoundedRectangle(cornerRadius: 30).frame(width: 360, height: 220).foregroundColor(.clear).glassEffect(.clear, in: .rect(cornerRadius: 30))
                    VStack(alignment: .leading, spacing: 10) {
                        Button(action: {
                            if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) }
                        }) { HStack { Text("Notification").foregroundColor(.white) }.padding(.vertical, 12) }
                        Rectangle().frame(width: 320, height: 2).foregroundColor(.white.opacity(0.3)).glassEffect()
                        NavigationLink(destination: Report()) { HStack { Text("Progress Report").foregroundColor(.white) }.padding(.vertical, 12) }
                        Rectangle().frame(width: 320, height: 2).foregroundColor(.white.opacity(0.3)).glassEffect()
                        NavigationLink(destination: Energy()) { HStack { Text("Energy Settings").foregroundColor(.white) }.padding(.vertical, 12) }
                    }
                    .padding(.leading, 10)
                }

                Text("Account Management").padding(.leading, 20).padding(.top, 20)
                ZStack {
                    RoundedRectangle(cornerRadius: 30).frame(width: 360, height: 140).foregroundColor(.clear).glassEffect(.clear, in: .rect(cornerRadius: 30))
                    VStack(alignment: .leading, spacing: 10) {
                        Button(action: { print("Clear Goals") }) { HStack { Text("Clear Goals").foregroundColor(Color(.lightRed)) }.padding(.vertical, 12) }
                        Rectangle().frame(width: 320, height: 2).foregroundColor(.white.opacity(0.3)).glassEffect()
                        Button(action: {
                            if userVM.currentUser?.authMode == .guest { showGuestLogoutAlert = true }
                            else { userVM.clearLocalUser() }
                        }) { HStack { Text("Log Out").foregroundColor(Color(.lightRed)) }.padding(.vertical, 12) }
                    }
                    .colorScheme(.dark)
                }
            }
            .padding(.top, -90)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { draftName = userVM.currentUser?.username ?? ""; isEditingName = true }) {
                    Image(systemName: "pencil")
                }.foregroundStyle(.white)
            }
        }
        .alert("Log Out?", isPresented: $showGuestLogoutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Log Out", role: .destructive) { userVM.clearLocalUser() }
        } message: { Text("You are continuing as a guest. Logging out will erase all local data.") }
        .colorScheme(.dark)
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

    var body: some View {
        VStack(spacing: 4) {
            Text(date, format: .dateTime.weekday(.abbreviated)).font(.caption2)
            Text(date, format: .dateTime.day()).font(.headline)
        }
        .frame(width: 44, height: 56)
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
    let store = OrbGoalStore()
    if store.goals.isEmpty { store.add(.mock) }
    return today().environmentObject(store).environmentObject(UserViewModel())
}

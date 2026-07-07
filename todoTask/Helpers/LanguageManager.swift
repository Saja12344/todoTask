//
//  LanguageManager.swift
//  todoTask
//

import SwiftUI
import Combine

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case arabic  = "ar"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: return "English"
        case .arabic:  return "العربية"
        }
    }

    var layoutDirection: LayoutDirection {
        self == .arabic ? .rightToLeft : .leftToRight
    }

    var locale: Locale {
        self == .arabic ? Locale(identifier: "ar") : Locale(identifier: "en")
    }
}

enum L10nKey: String, CaseIterable {
    // Tabs & home
    case tabToday, tabOrbs, tabFriends, tabSettings
    case goalsOfTheDay, todaysTasks, noTasksToday, addGoalHint
    case linkedToGoal, addDailyStep, addTaskHint
    case action, amountPerDay, unit, enterAmount, save, cancel, next
    case noTasksYet, deleteTask, deleteTaskQuestion
    case goalTotal, challenge
    case settingsTitle, appManagement, language, languageHint
    case notification, progressReport, energySettings
    case enterCompletedAmount

    // Goal creation steps
    case stepWrite, stepSuggest, stepSetup, stepDesign
    case stepNOfM

    // Write goal
    case writeGoalTitle, writeGoalSubtitle, tryIncluding, whatLabel, howMuchLabel
    case writePlaceholder, examples, skipManual
    case hintLooksLike, hintNumberDetected, hintTip

    // Suggested goal
    case yourGoal, weSuggest, hideTypes, chooseDifferentType
    case suggestTypeScanning, suggestTypeMatched, suggestTypeLabel, suggestShapeIntro
    case suggestNextHint, noMatchTitle, noMatchBody, goalTypes

    // Goal shape / setup
    case selectGoalShape, goalSetup, yourGoalLabel, draftPrefillHint
    case reachTargetTitle, reachTargetDesc
    case buildHabitTitle, buildHabitDesc
    case levelUpTitle, levelUpDesc
    case reduceTitle, reduceDesc
    case shapeFinishTotalTitle, shapeFinishTotalDesc
    case shapeRepeatScheduleTitle, shapeRepeatScheduleDesc
    case shapeBuildStreakTitle, shapeBuildStreakDesc
    case shapeLevelUpGradualTitle, shapeLevelUpGradualDesc
    case shapeFinishMilestonesTitle, shapeFinishMilestonesDesc
    case shapeReduceTitle, shapeReduceDesc

    // Form fields
    case targetNumber, deadline, deadlineHint, chooseDeadline
    case howToTrack, total, milestones
    case scopeSize, dailyTimePreference
    case moreOptions, lessOptions
    case daysOfWeek, preferredTime
    case habitType, schedule, streak
    case targetDays, breakDaysAllowed, activity
    case targetLevel, stepUpEvery, weeks
    case metricType, trackingMode, reduceBy, stayUnder
    case startingNumber, targetNumberLabel
    case reduceByExplain, stayUnderExplain
    case totalExplainEmpty, totalExplainGoal
    case milestoneExplainEmpty, milestoneExplainGoal

    // Design orb
    case designYourOrb, planetColors, glow, effect, texture, intensity
    case colorPalettes, tapColorToEdit, quickHues, customColor, deleteColor
    case colorStudio, orbitHue, nebulaBlend

    // Orbs page
    case noOrbsYet, tapCreateFirst, deleteOrbQuestion, deleteOrbMessage
    case orbsGalaxySubtitle, orbsEmptyPoem, deleteOrbLabel

    // Friends & challenge arena
    case friendsHeroTitle, friendsHeroSubtitle, friendsCreate, friendsJoin
    case friendsHowItWorks, friendsStep1, friendsStep2, friendsStep3
    case challengeNew, challengeJoin, challengeJoinHint, challengeJoinNow
    case challengeCreateSend, challengeCompetingFor, challengeWaiting, challengeSendCode
    case challengeCopied, challengeBackHome, challengeKeepPlanet, challengeYouWon
    case challengeFriendWon, challengeTryAgain, challengePoints, raceYou, raceOpponent
    case challengeCodePlaceholder, challengeLoginRequired, challengeNeedGoal
    case challengeErrorGeneric, challengeInvalidCode, challengePlanetYours
    case friendsPrizeLabel, friendsRacePreview
    case racePrizeLabel, raceMissionsTitle, raceTapLaunch, raceDoneYou, raceDoneFriend
    case raceBannerAhead, raceBannerBehind, raceBannerTied, raceVS
    case challengeTasksProgress, challengeNextMission, challengeCompletedCount
    case challengeOrbAdded
    case challengeCopyCode, challengeCreatedTitle, challengeCreatedHint, challengeGoToOrbs, challengeShareActive, challengeRoomCode

    // Weekdays
    case daySun, dayMon, dayTue, dayWed, dayThu, dayFri, daySat

    // Placeholders
    case phActivity, phUnit, phMetric, phRead

    // Task labels
    case tasksWord, milestoneWord, sessionWord, dayWord, weekWord
    case milestoneLine, sessionLine, dayLine, weekLine
    case stayAtOrLess

    // Settings & account
    case accountManagement, clearGoals, clearGoalsQuestion, clearGoalsMessage
    case logOut, logOutQuestion, logOutMessage, guestLogoutMessage
    case continueAsGuest, invalidCredentials
    case deleteAccount, deleteAccountQuestion, deleteAccountMessage, deletePermanently
    case guest, guestIDLabel, guestIDNA

    // Energy
    case energyPrompt, energyTakeBreak, energyAverage, energyHardcore
    case energySelectedFormat, energyChangeLater

    // Today & tasks
    case todayShortcut, late

    // Reflection & achievements
    case reflectionTitle, reflectionPlaceholder, reflectionHint
    case reflectionPromptWhat, reflectionPromptLearned, reflectionPromptNext
    case reflectionPromptCloser, reflectionPromptFeel
    case achievementsTitle, achievementsWonPlanets, achievementsCompleted
    case achievementsReflections, achievementsNoTasks, achievementsNoReflections
    case achievementsStatOrbs, achievementsStatDone, achievementsStatWon

    // Progress report
    case reportTitle, reportTotalGoals, reportGoalsCompleted, reportAvgProgress, reportOverdue
    case reportConsistency, reportOpened, reportMissed, reportEnergyOverTime, reportConsistencyEmpty
    case readMore, showLess
}

final class LanguageManager: ObservableObject {
    static let storageKey = "app_language"

    @Published var language: AppLanguage {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: Self.storageKey)
        }
    }

    init() {
        if let raw = UserDefaults.standard.string(forKey: Self.storageKey),
           let saved = AppLanguage(rawValue: raw) {
            language = saved
        } else {
            language = .english
        }
    }

    func t(_ key: L10nKey) -> String {
        switch language {
        case .english: return en[key] ?? key.rawValue
        case .arabic:  return ar[key] ?? en[key] ?? key.rawValue
        }
    }

    func orbsWorldsCount(_ count: Int) -> String {
        switch language {
        case .english: return count == 1 ? "1 world" : "\(count) worlds"
        case .arabic:  return count == 1 ? "عالم واحد" : "\(count) عوالم"
        }
    }

    func challengeFriendWon(_ name: String) -> String {
        String(format: t(.challengeFriendWon), name)
    }

    func challengePoints(_ points: Int) -> String {
        String(format: t(.challengePoints), points)
    }

    func raceHype(myProgress: Double, opponentProgress: Double) -> String {
        let diff = myProgress - opponentProgress
        if abs(diff) < 0.04 { return t(.raceBannerTied) }
        return diff > 0 ? t(.raceBannerAhead) : t(.raceBannerBehind)
    }

    func challengeTasksProgress(done: Int, total: Int) -> String {
        String(format: t(.challengeTasksProgress), done, total)
    }

    func challengeCompletedCount(_ count: Int) -> String {
        String(format: t(.challengeCompletedCount), count)
    }

    func stepLabel(_ step: Int) -> String {
        let keys: [L10nKey] = [.stepWrite, .stepSuggest, .stepSetup, .stepDesign]
        guard step >= 1, step <= keys.count else { return "" }
        return t(keys[step - 1])
    }

    func stepCounter(current: Int, total: Int = 4) -> String {
        switch language {
        case .english: return "Step \(current) of \(total)"
        case .arabic:  return "الخطوة \(current) من \(total)"
        }
    }

    func goalTypeTitle(_ type: GoalType) -> String {
        switch type {
        case .reachTarget: return t(.reachTargetTitle)
        case .buildHabit:  return t(.buildHabitTitle)
        case .levelUp:     return t(.levelUpTitle)
        case .reduce:      return t(.reduceTitle)
        }
    }

    func goalTypeDescription(_ type: GoalType) -> String {
        switch type {
        case .reachTarget: return t(.reachTargetDesc)
        case .buildHabit:  return t(.buildHabitDesc)
        case .levelUp:     return t(.levelUpDesc)
        case .reduce:      return t(.reduceDesc)
        }
    }

    /// Weekday chips always English (per product request).
    func weekdayShort(calendarIndex: Int) -> String {
        let en = ["", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        guard calendarIndex >= 1, calendarIndex <= 7 else { return "" }
        return en[calendarIndex]
    }

    func tasksProgressSummary(done: Int, total: Int) -> String {
        switch language {
        case .english: return "\(done) / \(total) \(t(.tasksWord))"
        case .arabic:  return "\(done) / \(total) \(t(.tasksWord))"
        }
    }

    func achievementsCompletedCount(_ count: Int) -> String {
        switch language {
        case .english: return count == 1 ? "1 task completed" : "\(count) tasks completed"
        case .arabic:  return count == 1 ? "مهمة واحدة مكتملة" : "\(count) مهام مكتملة"
        }
    }

    func achievementsWonOn(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        fmt.timeStyle = .none
        fmt.locale = language.locale
        switch language {
        case .english: return "Won on \(fmt.string(from: date))"
        case .arabic:  return "فوز في \(fmt.string(from: date))"
        }
    }

    func milestoneLabel(index: Int, total: Int) -> String {
        switch language {
        case .english: return String(format: t(.milestoneLine), index, total)
        case .arabic:  return String(format: t(.milestoneLine), index, total)
        }
    }

    func sessionLabel(index: Int, total: Int) -> String {
        switch language {
        case .english: return String(format: t(.sessionLine), index, total)
        case .arabic:  return String(format: t(.sessionLine), index, total)
        }
    }

    func dayLabel(index: Int, total: Int) -> String {
        switch language {
        case .english: return String(format: t(.dayLine), index, total)
        case .arabic:  return String(format: t(.dayLine), index, total)
        }
    }

    func weekLabel(index: Int, total: Int, unit: String) -> String {
        let u = unit.isEmpty ? "" : (language == .arabic ? " · \(unit)" : " · \(unit)")
        switch language {
        case .english: return String(format: t(.weekLine), index, total) + u
        case .arabic:  return String(format: t(.weekLine), index, total) + u
        }
    }

    func stayAtOrLess(level: Int, unitSuffix: String) -> String {
        switch language {
        case .english: return String(format: t(.stayAtOrLess), level, unitSuffix)
        case .arabic:  return String(format: t(.stayAtOrLess), level, unitSuffix)
        }
    }

    func energyLevels() -> [Energytoday] {
        [
            Energytoday(title: t(.energyTakeBreak), value: "1", icon: "figure.mind.and.body"),
            Energytoday(title: t(.energyAverage), value: "2", icon: "figure.mixed.cardio"),
            Energytoday(title: t(.energyHardcore), value: "3", icon: "figure.strengthtraining.traditional")
        ]
    }

    func localizedEnergyTitle(value: String, fallback: String) -> String {
        switch value {
        case "1": return t(.energyTakeBreak)
        case "2": return t(.energyAverage)
        case "3": return t(.energyHardcore)
        default: return fallback
        }
    }

    func liveHint(for text: String, suggested: GoalType?) -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 3 else { return nil }
        if let type = suggested {
            switch language {
            case .english:
                return "Looks like \(goalTypeTitle(type)) — \(goalTypeDescription(type))"
            case .arabic:
                return "يبدو أنه \(goalTypeTitle(type)) — \(goalTypeDescription(type))"
            }
        }
        if trimmed.range(of: #"\d+"#, options: .regularExpression) != nil {
            return t(.hintNumberDetected)
        }
        return t(.hintTip)
    }

    private let en: [L10nKey: String] = [
        .tabToday: "Today", .tabOrbs: "Orbs", .tabFriends: "Friends", .tabSettings: "Settings",
        .goalsOfTheDay: "Goals Of The Day", .todaysTasks: "Today's Tasks",
        .noTasksToday: "No tasks scheduled for this day", .addGoalHint: "Add a goal or pick another day",
        .linkedToGoal: "Linked to goal", .addDailyStep: "Add a daily step",
        .addTaskHint: "This task is added to the goal above and appears on Today when scheduled.",
        .action: "Action", .amountPerDay: "Amount per day", .unit: "Unit",
        .enterAmount: "Enter amount", .save: "Save", .cancel: "Cancel", .next: "Next",
        .noTasksYet: "No tasks yet — tap + to add", .deleteTask: "Delete",
        .deleteTaskQuestion: "Delete this task?", .goalTotal: "Goal: %d %@ total", .challenge: "Challenge",
        .settingsTitle: "Settings", .appManagement: "App Management", .language: "Language",
        .languageHint: "Switch the whole app between English and Arabic.",
        .notification: "Notification", .progressReport: "Progress Report",
        .energySettings: "Energy Settings", .enterCompletedAmount: "How many did you complete today?",
        .stepWrite: "Write", .stepSuggest: "Suggest", .stepSetup: "Setup", .stepDesign: "Design",
        .stepNOfM: "Step %d of %d",
        .writeGoalTitle: "Write a Goal",
        .writeGoalSubtitle: "One sentence is enough.",
        .tryIncluding: "Try including:", .whatLabel: "What", .howMuchLabel: "How much / how often",
        .writePlaceholder: "Write Goal Title Here",
        .examples: "Ideas", .skipManual: "Set up manually",
        .hintLooksLike: "Looks like %@ — %@",
        .hintNumberDetected: "A number detected — try Reach a Target (e.g. 10 books, 30 kg).",
        .hintTip: "Tip: mention what you want + how much or how often (e.g. gym 3× per week).",
        .yourGoal: "Your goal", .weSuggest: "Best fit",
        .suggestTypeScanning: "Reading your goal…",
        .suggestTypeMatched: "Your goal type",
        .suggestTypeLabel: "We matched it to this shape",
        .suggestShapeIntro: "Your suggested goal shape is to",
        .hideTypes: "Back", .chooseDifferentType: "Change",
        .suggestNextHint: "Next → setup",
        .noMatchTitle: "Pick a type",
        .noMatchBody: "Choose below.",
        .goalTypes: "Goal types",
        .selectGoalShape: "Select Your Goal Shape", .goalSetup: "Goal setup",
        .yourGoalLabel: "Your goal", .draftPrefillHint: "Fields below are pre-filled from your sentence—you can edit them.",
        .reachTargetTitle: "Reach a Target", .reachTargetDesc: "Hit a number or finish step by step",
        .buildHabitTitle: "Build a Habit", .buildHabitDesc: "Repeat on schedule or build a streak",
        .levelUpTitle: "Level Up", .levelUpDesc: "Start small and slowly do more",
        .reduceTitle: "Reduce", .reduceDesc: "Do less or stay under a limit",
        .shapeFinishTotalTitle: "Finish a Total", .shapeFinishTotalDesc: "Reach a set number.",
        .shapeRepeatScheduleTitle: "Repeat on Schedule", .shapeRepeatScheduleDesc: "Do something on certain days each week.",
        .shapeBuildStreakTitle: "Build a Streak", .shapeBuildStreakDesc: "Do it every day without stopping.",
        .shapeLevelUpGradualTitle: "Level Up Gradually", .shapeLevelUpGradualDesc: "Increase difficulty over time.",
        .shapeFinishMilestonesTitle: "Finish by Milestones", .shapeFinishMilestonesDesc: "Complete a goal step by step.",
        .shapeReduceTitle: "Reduce Something", .shapeReduceDesc: "Do less of something or stay under a limit.",
        .targetNumber: "Target number", .deadline: "Deadline",
        .deadlineHint: "Optional. Tasks spread until this date; leave unset to keep calendar tasks without an end cap.",
        .chooseDeadline: "Choose deadline",
        .howToTrack: "How to track it", .total: "Total", .milestones: "Milestones",
        .scopeSize: "Scope Size", .dailyTimePreference: "Daily Time Preference",
        .moreOptions: "More options", .lessOptions: "Less options",
        .daysOfWeek: "Days of the Week", .preferredTime: "Preferred Time",
        .habitType: "Habit type", .schedule: "Schedule", .streak: "Streak",
        .targetDays: "Target Days", .breakDaysAllowed: "Break Days Allowed", .activity: "Activity",
        .targetLevel: "Target Level", .stepUpEvery: "Step-up Every", .weeks: "Weeks",
        .metricType: "Metric type", .trackingMode: "Tracking mode",
        .reduceBy: "Reduce by", .stayUnder: "Stay Under",
        .startingNumber: "Starting Number", .targetNumberLabel: "Target Number",
        .reduceByExplain: "Start at your current level and step down over time until you reach the target (e.g. 3 hours → 2 → 1 screen time).",
        .stayUnderExplain: "Keep each day at or below the target number—a daily cap, not a gradual countdown (e.g. stay under 2 hours screen time).",
        .totalExplainEmpty: "One number to hit by the deadline (e.g. 30 kg). Each day you get a slice of that total.",
        .totalExplainGoal: "For “%@”: reach %d %@ total by the deadline. Daily tasks add up to that number.",
        .milestoneExplainEmpty: "Check-points toward finishing something big (project, course, launch)—not one daily number.",
        .milestoneExplainGoal: "For “%@”: progress in stages (milestones), good for projects—not “%d %@ every day.”",
        .designYourOrb: "Design Your Orb", .planetColors: "Planet Colors",
        .colorPalettes: "Palette Studio", .tapColorToEdit: "Tap a stop to edit its hue",
        .quickHues: "Quick Hues", .customColor: "Custom Color", .deleteColor: "Delete Color",
        .colorStudio: "Color Studio",
        .orbitHue: "Orbit Hue", .nebulaBlend: "Nebula Blend",
        .glow: "Glow", .effect: "Effect", .texture: "Texture", .intensity: "Intensity",
        .noOrbsYet: "No Orbs Yet", .tapCreateFirst: "Tap + to create your first goal",
        .orbsGalaxySubtitle: "Your goals orbit here as living worlds",
        .orbsEmptyPoem: "Every great journey starts with a single orb waiting to be born.",
        .deleteOrbLabel: "Delete Orb",
        .friendsHeroTitle: "Challenge a Friend",
        .friendsHeroSubtitle: "Race to complete tasks — whoever finishes more wins the orb.",
        .friendsCreate: "Create Challenge", .friendsJoin: "Join with Code",
        .friendsHowItWorks: "How it works", .friendsStep1: "Pick an orb to compete for",
        .friendsStep2: "Share the room code with your friend",
        .friendsStep3: "Complete missions — rockets orbit the planet on Orbs",
        .challengeNew: "New Challenge", .challengeJoin: "Join Challenge",
        .challengeJoinHint: "Enter the code your friend sent you",
        .challengeJoinNow: "Join Now", .challengeCreateSend: "Create & Share Code",
        .challengeCompetingFor: "Competing for this orb", .challengeWaiting: "Waiting for your friend…",
        .challengeSendCode: "Send them this code:", .challengeCopied: "Copied!",
        .challengeBackHome: "Back to Home", .challengeKeepPlanet: "Keep the Planet",
        .challengeYouWon: "You won the planet!", .challengeFriendWon: "%@ won the planet",
        .challengeTryAgain: "Better luck next time", .challengePoints: "%d pts",
        .raceYou: "You", .raceOpponent: "Friend",
        .challengeCodePlaceholder: "Room code", .challengeLoginRequired: "Please sign in first",
        .challengeNeedGoal: "Create at least one orb first", .challengeErrorGeneric: "Something went wrong — try again",
        .challengeInvalidCode: "Invalid or expired code", .challengePlanetYours: "The planet is yours now",
        .racePrizeLabel: "Prize orb", .raceMissionsTitle: "Tasks",
        .raceTapLaunch: "Complete", .raceDoneYou: "Completed", .raceDoneFriend: "Friend completed",
        .raceBannerAhead: "You're ahead — keep going", .raceBannerBehind: "Close the gap",
        .raceBannerTied: "Neck and neck", .raceVS: "VS",
        .challengeTasksProgress: "%d / %d done", .challengeNextMission: "Next up",
        .challengeCompletedCount: "%d completed",
        .challengeOrbAdded: "Challenge planet added to Orbs — watch the rockets race!",
        .challengeCopyCode: "Copy code",
        .challengeCreatedTitle: "Challenge created!",
        .challengeCreatedHint: "Send this code to your friend. They join from Friends → Join with Code.",
        .challengeGoToOrbs: "See it on Orbs",
        .challengeShareActive: "Your challenge code — share with friend",
        .challengeRoomCode: "Room code",
        .friendsPrizeLabel: "Prize Planet", .friendsRacePreview: "Rocket Race",
        .deleteOrbQuestion: "Delete this orb?", .deleteOrbMessage: "This will remove the orb and its progress.",
        .daySun: "Sun", .dayMon: "Mon", .dayTue: "Tue", .dayWed: "Wed",
        .dayThu: "Thu", .dayFri: "Fri", .daySat: "Sat",
        .phActivity: "e.g. running, reading", .phUnit: "e.g. Pages, Km, Bottles",
        .phMetric: "e.g. screen time, sugar", .phRead: "e.g. read",
        .tasksWord: "tasks", .milestoneWord: "Milestone", .sessionWord: "Session",
        .dayWord: "Day", .weekWord: "Week",
        .milestoneLine: "Milestone %d of %d", .sessionLine: "Session %d of %d",
        .dayLine: "Day %d of %d", .weekLine: "Week %d of %d",
        .stayAtOrLess: "Stay at %d%@ or less",
        .accountManagement: "Account Management",
        .clearGoals: "Clear Goals", .clearGoalsQuestion: "Clear all goals?",
        .clearGoalsMessage: "This removes every orb and task on this device.",
        .logOut: "Log Out", .logOutQuestion: "Log Out?",
        .logOutMessage: "You will return to the login screen. Local goals on this device will be cleared.",
        .guestLogoutMessage: "You are continuing as a guest. Logging out will erase all local data.",
        .continueAsGuest: "Continue as Guest",
        .invalidCredentials: "Invalid username or password.",
        .deleteAccount: "Delete Account", .deleteAccountQuestion: "Delete Account?",
        .deleteAccountMessage: "This will permanently delete your account and all your goals. This cannot be undone.",
        .deletePermanently: "Delete Permanently",
        .guest: "Guest", .guestIDLabel: "ID:", .guestIDNA: "N/A",
        .energyPrompt: "What's your energy level today?",
        .energyTakeBreak: "Take Break", .energyAverage: "Average", .energyHardcore: "Hardcore",
        .energySelectedFormat: "Selected: %@", .energyChangeLater: "You can change it later in Settings.",
        .todayShortcut: "Today", .late: "Late",
        .reflectionTitle: "Quick reflection",
        .reflectionPlaceholder: "Write a few words…",
        .reflectionHint: "Short notes help you learn from each win.",
        .reflectionPromptWhat: "What did you actually do to finish this?",
        .reflectionPromptLearned: "What did you notice or learn?",
        .reflectionPromptNext: "What will you do differently next time?",
        .reflectionPromptCloser: "What moved you closer to your goal?",
        .reflectionPromptFeel: "How did completing this feel?",
        .achievementsTitle: "Achievements",
        .achievementsWonPlanets: "Won planets",
        .achievementsCompleted: "Completed tasks",
        .achievementsReflections: "Reflections",
        .achievementsNoTasks: "Complete tasks to fill this gallery.",
        .achievementsNoReflections: "Tap a finished task to write a reflection.",
        .achievementsStatOrbs: "Orbs", .achievementsStatDone: "Done", .achievementsStatWon: "Won",
        .reportTitle: "Progress Report",
        .reportTotalGoals: "Total Goals", .reportGoalsCompleted: "Goals Completed",
        .reportAvgProgress: "Average Progress", .reportOverdue: "Past Deadline",
        .reportConsistency: "Consistency", .reportOpened: "Opened", .reportMissed: "Missed",
        .reportEnergyOverTime: "Energy Over Time"
    ]

    private let ar: [L10nKey: String] = [
        .tabToday: "اليوم", .tabOrbs: "الأوربت", .tabFriends: "الأصدقاء", .tabSettings: "الإعدادات",
        .goalsOfTheDay: "أهداف اليوم", .todaysTasks: "مهام اليوم",
        .noTasksToday: "لا مهام مجدولة لهذا اليوم", .addGoalHint: "أضف هدفاً أو اختر يوماً آخر",
        .linkedToGoal: "مرتبط بالهدف", .addDailyStep: "أضف خطوة يومية",
        .addTaskHint: "تُضاف هذه المهمة للهدف أعلاه وتظهر في «اليوم» حسب الجدول.",
        .action: "الفعل", .amountPerDay: "الكمية في اليوم", .unit: "الوحدة",
        .enterAmount: "أدخل الرقم", .save: "حفظ", .cancel: "إلغاء", .next: "التالي",
        .noTasksYet: "لا مهام بعد — اضغط +", .deleteTask: "حذف",
        .deleteTaskQuestion: "حذف هذه المهمة؟", .goalTotal: "الهدف: %d %@ إجمالي", .challenge: "تحدي",
        .settingsTitle: "الإعدادات", .appManagement: "إدارة التطبيق", .language: "اللغة",
        .languageHint: "حوّل التطبيق بالكامل بين الإنجليزية والعربية.",
        .notification: "الإشعارات", .progressReport: "تقرير التقدم",
        .energySettings: "إعدادات الطاقة", .enterCompletedAmount: "كم أنجزت اليوم؟",
        .stepWrite: "اكتب", .stepSuggest: "اقتراح", .stepSetup: "إعداد", .stepDesign: "تصميم",
        .stepNOfM: "الخطوة %d من %d",
        .writeGoalTitle: "اكتب هدفك",
        .writeGoalSubtitle: "جملة واحدة تكفي.",
        .tryIncluding: "حاول أن تذكر:", .whatLabel: "ماذا", .howMuchLabel: "كم / كم مرة",
        .writePlaceholder: "اكتب عنوان الهدف هنا",
        .examples: "أفكار", .skipManual: "إعداد يدوي",
        .hintLooksLike: "يبدو أنه %@ — %@",
        .hintNumberDetected: "رقم ظاهر في النص — جرّب «وصول لهدف» (مثال: 10 كتب، 30 كجم).",
        .hintTip: "نصيحة: اذكر ماذا تريد + الكمية أو التكرار (مثال: نادي 3 مرات بالأسبوع).",
        .yourGoal: "هدفك", .weSuggest: "الأنسب",
        .suggestTypeScanning: "جاري قراءة هدفك…",
        .suggestTypeMatched: "نوع هدفك",
        .suggestTypeLabel: "طابقناه مع هذا الشكل",
        .suggestShapeIntro: "شكل هدفك المقترح هو",
        .hideTypes: "رجوع", .chooseDifferentType: "تغيير",
        .suggestNextHint: "التالي ← الإعداد",
        .noMatchTitle: "اختر النوع",
        .noMatchBody: "من القائمة تحت.",
        .goalTypes: "أنواع الأهداف",
        .selectGoalShape: "اختر شكل الهدف", .goalSetup: "إعداد الهدف",
        .yourGoalLabel: "هدفك", .draftPrefillHint: "الحقول مملوءة من جملتك — يمكنك تعديلها.",
        .reachTargetTitle: "وصول لهدف", .reachTargetDesc: "رقم تصل له أو خطوات متتابعة",
        .buildHabitTitle: "بناء عادة", .buildHabitDesc: "جدول متكرر أو سلسلة أيام",
        .levelUpTitle: "تطوير مستوى", .levelUpDesc: "ابدأ صغيراً وزد تدريجياً",
        .reduceTitle: "تقليل", .reduceDesc: "قل شيئاً أو التزم بحد أقصى",
        .shapeFinishTotalTitle: "إنجاز إجمالي", .shapeFinishTotalDesc: "وصولي لرقم محدد.",
        .shapeRepeatScheduleTitle: "تكرار بجدول", .shapeRepeatScheduleDesc: "شيء معيّن في أيام محددة كل أسبوع.",
        .shapeBuildStreakTitle: "بناء سلسلة", .shapeBuildStreakDesc: "كل يوم بدون انقطاع.",
        .shapeLevelUpGradualTitle: "ترقية تدريجية", .shapeLevelUpGradualDesc: "تبدأين صغير وتزيدين شوي شوي.",
        .shapeFinishMilestonesTitle: "إنجاز بمراحل", .shapeFinishMilestonesDesc: "هدف كبير خطوة خطوة.",
        .shapeReduceTitle: "تقليل شيء", .shapeReduceDesc: "تقليل شيء أو البقاء تحت حد.",
        .targetNumber: "الرقم المستهدف", .deadline: "الموعد النهائي",
        .deadlineHint: "اختياري. نوزّع المهام حتى هذا التاريخ؛ بدون موعد يبقى التقويم يعرض المهام.",
        .chooseDeadline: "اختر الموعد النهائي",
        .howToTrack: "طريقة التتبع", .total: "إجمالي", .milestones: "مراحل",
        .scopeSize: "حجم المرحلة", .dailyTimePreference: "الوقت اليومي المفضل",
        .moreOptions: "خيارات أكثر", .lessOptions: "خيارات أقل",
        .daysOfWeek: "أيام الأسبوع", .preferredTime: "الوقت المفضل",
        .habitType: "نوع العادة", .schedule: "جدول", .streak: "سلسلة",
        .targetDays: "أيام الهدف", .breakDaysAllowed: "أيام استراحة مسموحة", .activity: "النشاط",
        .targetLevel: "المستوى المستهدف", .stepUpEvery: "زيادة كل", .weeks: "أسابيع",
        .metricType: "نوع المقياس", .trackingMode: "وضع التتبع",
        .reduceBy: "تقليل تدريجي", .stayUnder: "حد أقصى",
        .startingNumber: "الرقم الابتدائي", .targetNumberLabel: "الرقم المستهدف",
        .reduceByExplain: "تبدأ من مستواك الحالي وتنزل تدريجياً حتى الهدف (مثال: 3 ساعات → 2 → 1 جوال).",
        .stayUnderExplain: "كل يوم عند أو تحت الرقم — سقف يومي وليس عدّاً تنازلياً (مثال: أقل من ساعتين شاشة).",
        .totalExplainEmpty: "رقم واحد تصل له قبل الموعد (مثال: 30 كجم). كل يوم جزء من الإجمالي.",
        .totalExplainGoal: "لـ «%@»: الوصول إلى %d %@ قبل الموعد. مهام اليوم تجمع لهذا الرقم.",
        .milestoneExplainEmpty: "محطات لمشروع كبير (مشروع، دورة، إطلاق) — ليس رقماً يومياً واحداً.",
        .milestoneExplainGoal: "لـ «%@»: تقدم على مراحل — مناسب للمشاريع وليس «%d %@ كل يوم».",
        .designYourOrb: "صمّم كوكبك", .planetColors: "ألوان الكوكب",
        .colorPalettes: "استوديو الألوان", .tapColorToEdit: "اضغطي على لون لتعديله",
        .quickHues: "درجات سريعة", .customColor: "لون مخصص", .deleteColor: "حذف اللون",
        .colorStudio: "استوديو اللون",
        .orbitHue: "حلقة اللون", .nebulaBlend: "مزيج السديم",
        .glow: "التوهج", .effect: "التأثير", .texture: "الملمس", .intensity: "الشدة",
        .noOrbsYet: "لا أوربت بعد", .tapCreateFirst: "اضغط + لإنشاء أول هدف",
        .orbsGalaxySubtitle: "أهدافك تدور هنا كعوالم حيّة",
        .orbsEmptyPoem: "كل رحلة عظيمة تبدأ بأوربت واحد ينتظر أن يولد.",
        .deleteOrbLabel: "حذف الأوربت",
        .friendsHeroTitle: "تحدّ صديقك",
        .friendsHeroSubtitle: "تنافسا على إكمال المهام — من يُنجز أكثر يفوز بالكوكب.",
        .friendsCreate: "إنشاء تحدي", .friendsJoin: "الانضمام برمز",
        .friendsHowItWorks: "كيف يعمل", .friendsStep1: "اختر أوربت للتنافس عليه",
        .friendsStep2: "شاركي رمز الغرفة مع صديقك",
        .friendsStep3: "أكمل المهمات — الصواريخ تدور حول الكوكب في Orbs",
        .challengeNew: "تحدي جديد", .challengeJoin: "انضم لتحدي",
        .challengeJoinHint: "أدخلي الرمز اللي أرسله لك صديقك",
        .challengeJoinNow: "انضم الآن", .challengeCreateSend: "إنشاء ومشاركة الرمز",
        .challengeCompetingFor: "التنافس على هذا الأوربت", .challengeWaiting: "في انتظار صديقك…",
        .challengeSendCode: "أرسلي له هذا الرمز:", .challengeCopied: "تم النسخ!",
        .challengeBackHome: "العودة للرئيسية", .challengeKeepPlanet: "احتفظي بالكوكب",
        .challengeYouWon: "فزتِ بالكوكب!", .challengeFriendWon: "%@ فاز بالكوكب",
        .challengeTryAgain: "حظ أوفر المرة القادمة", .challengePoints: "%d نقطة",
        .raceYou: "أنت", .raceOpponent: "صديق",
        .challengeCodePlaceholder: "رمز الغرفة", .challengeLoginRequired: "سجّلي الدخول أولاً",
        .challengeNeedGoal: "أنشئي أوربت واحد على الأقل", .challengeErrorGeneric: "حدث خطأ — حاولي مجدداً",
        .challengeInvalidCode: "الرمز غير صحيح أو منتهي", .challengePlanetYours: "الكوكب ملكك الآن",
        .friendsPrizeLabel: "كوكب الجائزة", .friendsRacePreview: "سباق الصواريخ",
        .racePrizeLabel: "كوكب الجائزة", .raceMissionsTitle: "المهام",
        .raceTapLaunch: "إكمال", .raceDoneYou: "تم الإنجاز", .raceDoneFriend: "صديقك أنجزها",
        .raceBannerAhead: "قدّام — كمّلي", .raceBannerBehind: "قربي الفجوة",
        .raceBannerTied: "تعادل", .raceVS: "ضد",
        .challengeTasksProgress: "%d / %d منجزة", .challengeNextMission: "التالي",
        .challengeCompletedCount: "%d مكتملة",
        .challengeOrbAdded: "انضاف كوكب التحدي في Orbs — شوف الصواريخ تتسابق!",
        .challengeCopyCode: "نسخ الرمز",
        .challengeCreatedTitle: "تم إنشاء التحدي!",
        .challengeCreatedHint: "أرسلي هذا الرمز لصديقك. ينضم من الأصدقاء ← الانضمام برمز.",
        .challengeGoToOrbs: "شوفه في Orbs",
        .challengeShareActive: "رمز تحديك — شاركيه مع صديقك",
        .challengeRoomCode: "رمز الغرفة",
        .deleteOrbQuestion: "حذف هذا الأوربت؟", .deleteOrbMessage: "سيُحذف الأوربت وكل التقدم.",
        .daySun: "أحد", .dayMon: "إثن", .dayTue: "ثلا", .dayWed: "أرب",
        .dayThu: "خمي", .dayFri: "جمع", .daySat: "سبت",
        .phActivity: "مثال: جري، قراءة", .phUnit: "مثال: صفحات، كم، زجاجات",
        .phMetric: "مثال: وقت شاشة، سكر", .phRead: "مثال: قراءة",
        .tasksWord: "مهام", .milestoneWord: "مرحلة", .sessionWord: "جلسة",
        .dayWord: "يوم", .weekWord: "أسبوع",
        .milestoneLine: "مرحلة %d من %d", .sessionLine: "جلسة %d من %d",
        .dayLine: "يوم %d من %d", .weekLine: "أسبوع %d من %d",
        .stayAtOrLess: "التزم بـ %d%@ أو أقل",
        .accountManagement: "إدارة الحساب",
        .clearGoals: "مسح الأهداف", .clearGoalsQuestion: "مسح كل الأهداف؟",
        .clearGoalsMessage: "سيُحذف كل الأوربت والمهام من هذا الجهاز.",
        .logOut: "تسجيل الخروج", .logOutQuestion: "تسجيل الخروج؟",
        .logOutMessage: "ستعودين لشاشة تسجيل الدخول وستُمسح الأهداف المحلية على هذا الجهاز.",
        .guestLogoutMessage: "أنت ضيف. الخروج يمسح كل البيانات المحلية.",
        .continueAsGuest: "المتابعة كضيف",
        .invalidCredentials: "اسم المستخدم أو كلمة المرور غير صحيحة.",
        .deleteAccount: "حذف الحساب", .deleteAccountQuestion: "حذف الحساب؟",
        .deleteAccountMessage: "سيُحذف حسابك وجميع أهدافك نهائياً ولا يمكن التراجع.",
        .deletePermanently: "حذف نهائي",
        .guest: "ضيف", .guestIDLabel: "المعرّف:", .guestIDNA: "غير متوفر",
        .energyPrompt: "ما مستوى طاقتك اليوم؟",
        .energyTakeBreak: "استراحة", .energyAverage: "متوسط", .energyHardcore: "مكثّف",
        .energySelectedFormat: "المختار: %@", .energyChangeLater: "يمكنك تغييره لاحقاً من الإعدادات.",
        .todayShortcut: "اليوم", .late: "متأخر",
        .reflectionTitle: "تأمل سريع",
        .reflectionPlaceholder: "اكتب كلمات قليلة…",
        .reflectionHint: "ملاحظات قصيرة تساعدك تتعلم من كل إنجاز.",
        .reflectionPromptWhat: "وش سويت فعلاً عشان تخلص المهمة؟",
        .reflectionPromptLearned: "وش لاحظت أو تعلّمت؟",
        .reflectionPromptNext: "وش بتسوي مختلف المرة الجاية؟",
        .reflectionPromptCloser: "وش قربك من هدفك؟",
        .reflectionPromptFeel: "كيف كان شعورك بعد ما خلصت؟",
        .achievementsTitle: "الإنجازات",
        .achievementsWonPlanets: "كواكب فزت فيها",
        .achievementsCompleted: "مهام مكتملة",
        .achievementsReflections: "تأملات",
        .achievementsNoTasks: "أكمل مهام عشان تملأ هالمعرض.",
        .achievementsNoReflections: "اضغط على مهمة منتهية عشان تكتب تأمل.",
        .achievementsStatOrbs: "أوربت", .achievementsStatDone: "منجز", .achievementsStatWon: "فوز",
        .reportTitle: "تقرير التقدم",
        .reportTotalGoals: "إجمالي الأهداف", .reportGoalsCompleted: "أهداف مكتملة",
        .reportAvgProgress: "متوسط التقدم", .reportOverdue: "تجاوز الموعد",
        .reportConsistency: "الانتظام", .reportOpened: "فتح", .reportMissed: "فات",
        .reportEnergyOverTime: "الطاقة عبر الوقت",
        .reportConsistencyEmpty: "أضف هدفاً لبدء تتبع الانتظام.",
        .readMore: "اقرأ المزيد", .showLess: "عرض أقل"
    ]
}

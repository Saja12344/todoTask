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
    case suggestNextHint, noMatchTitle, noMatchBody, goalTypes

    // Goal shape / setup
    case selectGoalShape, goalSetup, yourGoalLabel, draftPrefillHint
    case reachTargetTitle, reachTargetDesc
    case buildHabitTitle, buildHabitDesc
    case levelUpTitle, levelUpDesc
    case reduceTitle, reduceDesc

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
    case designYourOrb, planetColors, glow, effect, intensity

    // Orbs page
    case noOrbsYet, tapCreateFirst, deleteOrbQuestion, deleteOrbMessage

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
    case logOut, logOutQuestion, guestLogoutMessage
    case deleteAccount, deleteAccountQuestion, deleteAccountMessage, deletePermanently
    case guest, guestIDLabel, guestIDNA

    // Energy
    case energyPrompt, energyTakeBreak, energyAverage, energyHardcore
    case energySelectedFormat, energyChangeLater

    // Today & tasks
    case todayShortcut, late

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
        .writeGoalTitle: "Write a goal",
        .writeGoalSubtitle: "One sentence is enough. We'll suggest a goal type—you can change it next.",
        .tryIncluding: "Try including:", .whatLabel: "What", .howMuchLabel: "How much / how often",
        .writePlaceholder: "e.g. Learn Spanish or read 20 books",
        .examples: "Examples", .skipManual: "Skip — choose goal type manually",
        .hintLooksLike: "Looks like %@ — %@",
        .hintNumberDetected: "A number detected — try Reach a Target (e.g. 10 books, 30 kg).",
        .hintTip: "Tip: mention what you want + how much or how often (e.g. gym 3× per week).",
        .yourGoal: "Your goal", .weSuggest: "We suggest",
        .hideTypes: "Hide types", .chooseDifferentType: "Choose a different type",
        .suggestNextHint: "Tap Next to open goal setup (dates, target, total vs milestones).",
        .noMatchTitle: "We couldn't match a type yet",
        .noMatchBody: "Choose one of the four goal types below.",
        .goalTypes: "Goal types",
        .selectGoalShape: "Select Your Goal Shape", .goalSetup: "Goal setup",
        .yourGoalLabel: "Your goal", .draftPrefillHint: "Fields below are pre-filled from your sentence—you can edit them.",
        .reachTargetTitle: "Reach a Target", .reachTargetDesc: "Hit a number or finish step by step",
        .buildHabitTitle: "Build a Habit", .buildHabitDesc: "Repeat on schedule or build a streak",
        .levelUpTitle: "Level Up", .levelUpDesc: "Start small and slowly do more",
        .reduceTitle: "Reduce", .reduceDesc: "Do less or stay under a limit",
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
        .glow: "Glow", .effect: "Effect", .intensity: "Intensity",
        .noOrbsYet: "No Orbs Yet", .tapCreateFirst: "Tap + to create your first goal",
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
        .guestLogoutMessage: "You are continuing as a guest. Logging out will erase all local data.",
        .deleteAccount: "Delete Account", .deleteAccountQuestion: "Delete Account?",
        .deleteAccountMessage: "This will permanently delete your account and all your goals. This cannot be undone.",
        .deletePermanently: "Delete Permanently",
        .guest: "Guest", .guestIDLabel: "ID:", .guestIDNA: "N/A",
        .energyPrompt: "What's your energy level today?",
        .energyTakeBreak: "Take Break", .energyAverage: "Average", .energyHardcore: "Hardcore",
        .energySelectedFormat: "Selected: %@", .energyChangeLater: "You can change it later in Settings.",
        .todayShortcut: "Today", .late: "Late",
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
        .writeGoalSubtitle: "جملة واحدة تكفي. سنقترح نوع الهدف ويمكنك تغييره في الخطوة التالية.",
        .tryIncluding: "حاول أن تذكر:", .whatLabel: "ماذا", .howMuchLabel: "كم / كم مرة",
        .writePlaceholder: "مثال: أتعلم الإسبانية أو أقرأ 20 كتاباً",
        .examples: "أمثلة", .skipManual: "تخطي — اختر نوع الهدف يدوياً",
        .hintLooksLike: "يبدو أنه %@ — %@",
        .hintNumberDetected: "رقم ظاهر في النص — جرّب «وصول لهدف» (مثال: 10 كتب، 30 كجم).",
        .hintTip: "نصيحة: اذكر ماذا تريد + الكمية أو التكرار (مثال: نادي 3 مرات بالأسبوع).",
        .yourGoal: "هدفك", .weSuggest: "نقترح",
        .hideTypes: "إخفاء الأنواع", .chooseDifferentType: "اختر نوعاً آخر",
        .suggestNextHint: "اضغط التالي لفتح إعداد الهدف (الموعد، الرقم، إجمالي أو مراحل).",
        .noMatchTitle: "لم نحدد النوع بعد",
        .noMatchBody: "اختر أحد أنواع الأهداف الأربعة أدناه.",
        .goalTypes: "أنواع الأهداف",
        .selectGoalShape: "اختر شكل الهدف", .goalSetup: "إعداد الهدف",
        .yourGoalLabel: "هدفك", .draftPrefillHint: "الحقول مملوءة من جملتك — يمكنك تعديلها.",
        .reachTargetTitle: "وصول لهدف", .reachTargetDesc: "رقم تصل له أو خطوات متتابعة",
        .buildHabitTitle: "بناء عادة", .buildHabitDesc: "جدول متكرر أو سلسلة أيام",
        .levelUpTitle: "تطوير مستوى", .levelUpDesc: "ابدأ صغيراً وزد تدريجياً",
        .reduceTitle: "تقليل", .reduceDesc: "قل شيئاً أو التزم بحد أقصى",
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
        .glow: "التوهج", .effect: "التأثير", .intensity: "الشدة",
        .noOrbsYet: "لا أوربت بعد", .tapCreateFirst: "اضغط + لإنشاء أول هدف",
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
        .guestLogoutMessage: "أنت ضيف. الخروج يمسح كل البيانات المحلية.",
        .deleteAccount: "حذف الحساب", .deleteAccountQuestion: "حذف الحساب؟",
        .deleteAccountMessage: "سيُحذف حسابك وجميع أهدافك نهائياً ولا يمكن التراجع.",
        .deletePermanently: "حذف نهائي",
        .guest: "ضيف", .guestIDLabel: "المعرّف:", .guestIDNA: "غير متوفر",
        .energyPrompt: "ما مستوى طاقتك اليوم؟",
        .energyTakeBreak: "استراحة", .energyAverage: "متوسط", .energyHardcore: "مكثّف",
        .energySelectedFormat: "المختار: %@", .energyChangeLater: "يمكنك تغييره لاحقاً من الإعدادات.",
        .todayShortcut: "اليوم", .late: "متأخر",
        .reportTitle: "تقرير التقدم",
        .reportTotalGoals: "إجمالي الأهداف", .reportGoalsCompleted: "أهداف مكتملة",
        .reportAvgProgress: "متوسط التقدم", .reportOverdue: "تجاوز الموعد",
        .reportConsistency: "الانتظام", .reportOpened: "فتح", .reportMissed: "فات",
        .reportEnergyOverTime: "الطاقة عبر الوقت",
        .reportConsistencyEmpty: "أضف هدفاً لبدء تتبع الانتظام.",
        .readMore: "اقرأ المزيد", .showLess: "عرض أقل"
    ]
}

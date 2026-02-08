import Foundation
import SwiftUI
import Combine

// MARK: - GoalSettingsViewModel (بدون أخطاء)

class GoalSettingsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var goalSettings = GoalSettings()
    @Published var selectedCategory: GoalCategory = .habit
    @Published var categoryRules: CategoryRules?
    @Published var isValid: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Initialization
    init() {
        selectCategory(.habit)
    }
    
    // MARK: - 1. تحديد نوع الهدف
    
    func selectCategory(_ category: GoalCategory) {
        selectedCategory = category
        let rules = getCategoryRules(for: category)
        self.categoryRules = rules
        applyDefaultSettings(for: category)
    }
    
    // MARK: - 2. تطبيق الإعدادات الافتراضية
    
    private func applyDefaultSettings(for category: GoalCategory) {
        var settings = GoalSettings()
        
        switch category {
        case .habit:
            settings.targetNumber = 1
            settings.unit = "times"
            settings.daysAWeek = [.monday, .tuesday, .wednesday, .thursday, .friday]
            settings.dailyEffort = 50.0
            settings.makeupAllowed = false
            settings.breakDays = 0
            
        case .project:
            settings.targetNumber = nil
            settings.unit = nil
            settings.deadlineDate = Calendar.current.date(byAdding: .month, value: 1, to: Date())
            settings.daysAWeek = []
            settings.dailyEffort = 60.0
            
        case .learning:
            settings.targetNumber = 5
            settings.unit = "lessons"
            settings.daysAWeek = [.saturday, .sunday, .monday, .tuesday, .wednesday]
            settings.dailyEffort = 60.0
            settings.makeupAllowed = true
            settings.breakDays = 2
            
        case .fitness:
            settings.targetNumber = 30
            settings.unit = "minutes"
            settings.daysAWeek = [.saturday, .monday, .wednesday, .friday]
            settings.dailyEffort = 70.0
            settings.makeupAllowed = false
            settings.breakDays = 1
            settings.recoveryWeek = false
            
        case .finance:
            settings.targetNumber = 1000
            settings.unit = "SAR"
            settings.deadlineDate = Calendar.current.date(byAdding: .month, value: 3, to: Date())
            settings.daysAWeek = []
            settings.dailyEffort = 50.0
            
        case .custom:
            settings.targetNumber = 1
            settings.daysAWeek = []
            settings.dailyEffort = 50.0
        }
        
        goalSettings = settings
        validateSettings()
    }
    
    // MARK: - 3. تحديث Target Number
    
    func updateTargetNumber(_ number: Int) {
        var settings = goalSettings
        settings.targetNumber = number
        goalSettings = settings
        validateSettings()
    }
    
    func incrementTargetNumber() {
        guard let current = goalSettings.targetNumber else {
            updateTargetNumber(1)
            return
        }
        updateTargetNumber(current + 1)
    }
    
    func decrementTargetNumber() {
        guard let current = goalSettings.targetNumber, current > 1 else {
            return
        }
        updateTargetNumber(current - 1)
    }
    
    // MARK: - 4. تحديث Unit
    
    func updateUnit(_ unit: String) {
        var settings = goalSettings
        settings.unit = unit
        goalSettings = settings
    }
    
    // MARK: - 5. تحديث Deadline
    
    func updateDeadline(_ date: Date) {
        var settings = goalSettings
        settings.deadlineDate = date
        goalSettings = settings
        validateSettings()
    }
    
    // MARK: - 6. تحديث أيام الأسبوع
    
    func toggleWeekday(_ day: Weekday) {
        var settings = goalSettings
        
        if let index = settings.daysAWeek.firstIndex(of: day) {
            settings.daysAWeek.remove(at: index)
        } else {
            settings.daysAWeek.append(day)
        }
        
        goalSettings = settings
        validateSettings()
    }
    
    func selectAllWeekdays() {
        var settings = goalSettings
        settings.daysAWeek = Weekday.allCases
        goalSettings = settings
        validateSettings()
    }
    
    func clearAllWeekdays() {
        var settings = goalSettings
        settings.daysAWeek = []
        goalSettings = settings
        validateSettings()
    }
    
    // MARK: - 7. تحديث Time Window
    
    func updateTimeWindow(start: Date, end: Date) {
        var settings = goalSettings
        let timeWindow = TimeWindow(
            startTime: start,
            endTime: end,
            daysOfWeek: settings.daysAWeek
        )
        settings.timeWindow = timeWindow
        goalSettings = settings
    }
    
    // MARK: - 8. تحديث Daily Effort
    
    func updateDailyEffort(_ value: Double) {
        var settings = goalSettings
        settings.dailyEffort = value
        goalSettings = settings
    }
    
    // MARK: - 9. تحديث Make-up Allowed
    
    func toggleMakeupAllowed() {
        var settings = goalSettings
        settings.makeupAllowed.toggle()
        goalSettings = settings
    }
    
    // MARK: - 10. تحديث Break Days
    
    func updateBreakDays(_ count: Int) {
        guard count >= 0, count <= 7 else { return }
        
        var settings = goalSettings
        settings.breakDays = count
        goalSettings = settings
        validateSettings()
    }
    
    func incrementBreakDays() {
        let current = goalSettings.breakDays
        if current < 7 {
            updateBreakDays(current + 1)
        }
    }
    
    func decrementBreakDays() {
        let current = goalSettings.breakDays
        if current > 0 {
            updateBreakDays(current - 1)
        }
    }
    
    // MARK: - 11. تحديث Activity
    
    func updateActivity(_ activity: String) {
        var settings = goalSettings
        settings.activity = activity
        goalSettings = settings
    }
    
    // MARK: - 12. تحديث Target Level
    
    func updateTargetLevel(_ level: String) {
        var settings = goalSettings
        settings.targetLevel = level
        goalSettings = settings
    }
    
    // MARK: - 13. تحديث Step-up Pace
    
    func updateStepUpPace(_ pace: String) {
        var settings = goalSettings
        settings.stepUpPace = pace
        goalSettings = settings
    }
    
    // MARK: - 14. تحديث Recovery Week
    
    func toggleRecoveryWeek() {
        var settings = goalSettings
        settings.recoveryWeek.toggle()
        goalSettings = settings
    }
    
    // MARK: - 15. تحديث Scope Size
    
    func updateScopeSize(_ size: String) {
        var settings = goalSettings
        settings.scopeSize = size
        goalSettings = settings
    }
    
    // MARK: - 16. تحديث Daily Time Preference
    
    func updateDailyTimePreference(_ minutes: Int) {
        var settings = goalSettings
        settings.dailyTimePreference = minutes
        goalSettings = settings
    }
    
    // MARK: - 17. التحقق من صحة الإعدادات
    
    func validateSettings() {
        guard let rules = categoryRules else {
            isValid = false
            errorMessage = "لم يتم تحديد نوع الهدف"
            return
        }
        
        var errors: [String] = []
        
        // التحقق من المدة
        if let deadline = goalSettings.deadlineDate {
            let duration = Calendar.current.dateComponents(
                [.day],
                from: Date(),
                to: deadline
            ).day ?? 0
            
            if duration < rules.minDuration {
                errors.append("⚠️ المدة قصيرة جداً (الحد الأدنى: \(rules.minDuration) يوم)")
            }
            
            if duration > rules.maxDuration {
                errors.append("⚠️ المدة طويلة جداً (الحد الأقصى: \(rules.maxDuration) يوم)")
            }
            
            if duration < 0 {
                errors.append("⚠️ تاريخ الانتهاء يجب أن يكون في المستقبل")
            }
        } else {
            if selectedCategory == .project || selectedCategory == .finance {
                errors.append("⚠️ يجب تحديد تاريخ الانتهاء")
            }
        }
        
        // التحقق من أيام الأسبوع
        if rules.requiresDailyCheckin {
            if goalSettings.daysAWeek.isEmpty {
                errors.append("⚠️ يجب اختيار يوم واحد على الأقل")
            }
        }
        
        // التحقق من Target Number
        if let target = goalSettings.targetNumber {
            if target < 1 {
                errors.append("⚠️ الرقم المستهدف يجب أن يكون 1 على الأقل")
            }
        }
        
        // التحقق من Break Days
        if goalSettings.breakDays > goalSettings.daysAWeek.count {
            errors.append("⚠️ أيام الراحة لا يمكن أن تكون أكثر من أيام النشاط")
        }
        
        // التحقق من Time Window
        if let timeWindow = goalSettings.timeWindow {
            if timeWindow.startTime >= timeWindow.endTime {
                errors.append("⚠️ وقت البداية يجب أن يكون قبل وقت النهاية")
            }
        }
        
        // النتيجة
        if errors.isEmpty {
            isValid = true
            errorMessage = nil
        } else {
            isValid = false
            errorMessage = errors.joined(separator: "\n")
        }
    }
    
    // MARK: - 18. الحصول على قواعد الفئة
    
    private func getCategoryRules(for category: GoalCategory) -> CategoryRules {
        switch category {
        case .habit:
            return CategoryRules(
                minDuration: 15,
                maxDuration: 365,
                requiresDailyCheckin: true,
                allowsSubTasks: true,
                recommendedSubTaskCount: 1...3
            )
        case .project:
            return CategoryRules(
                minDuration: 1,
                maxDuration: 180,
                requiresDailyCheckin: false,
                allowsSubTasks: true,
                recommendedSubTaskCount: 3...10
            )
        case .learning:
            return CategoryRules(
                minDuration: 7,
                maxDuration: 90,
                requiresDailyCheckin: false,
                allowsSubTasks: true,
                recommendedSubTaskCount: 5...15
            )
        case .fitness:
            return CategoryRules(
                minDuration: 7,
                maxDuration: 90,
                requiresDailyCheckin: true,
                allowsSubTasks: true,
                recommendedSubTaskCount: 1...5
            )
        case .finance:
            return CategoryRules(
                minDuration: 30,
                maxDuration: 365,
                requiresDailyCheckin: false,
                allowsSubTasks: true,
                recommendedSubTaskCount: 3...8
            )
        case .custom:
            return CategoryRules(
                minDuration: 1,
                maxDuration: 365,
                requiresDailyCheckin: false,
                allowsSubTasks: true,
                recommendedSubTaskCount: 1...20
            )
        }
    }
    
    // MARK: - 19. Helpers
    
    func getDurationInDays() -> Int? {
        guard let deadline = goalSettings.deadlineDate else { return nil }
        
        let duration = Calendar.current.dateComponents(
            [.day],
            from: Date(),
            to: deadline
        ).day ?? 0
        
        return duration
    }
    
    func requiresDeadline() -> Bool {
        return selectedCategory == .project || selectedCategory == .finance
    }
    
    func requiresDailyCheckin() -> Bool {
        return categoryRules?.requiresDailyCheckin ?? false
    }
    
    func allowsSubTasks() -> Bool {
        return categoryRules?.allowsSubTasks ?? true
    }
    
    func resetSettings() {
        selectCategory(selectedCategory)
    }
}

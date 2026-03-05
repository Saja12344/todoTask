//
//  TaskGenerator.swift
//  todoTask
//
//  Created by شهد عبدالله القحطاني on 05/09/1447 AH.
//


//
//  TaskGenerator.swift
//  todoTask
//
//  ملف جديد — منطق توليد المهام من الإعدادات مع دعم مستوى الطاقة
//

import Foundation

// MARK: - TaskGenerator
struct TaskGenerator {
    
    // energyFactor: 1.0 = Hardcore, 0.7 = Average, 0.5 = Take Break
    static func generate(
        from settings: GoalSettings,
        goalID: UUID,
        goalTitle: String,
        energyFactor: Double = 1.0
    ) -> [GoalTask] {
        
        let factor = max(0.3, min(1.0, energyFactor))
        
        switch settings.goalType {
        case .finishTotal:
            return generateFinishTotal(settings: settings, goalID: goalID, title: goalTitle, factor: factor)
            
        case .repeatSchedule:
            return generateRepeatSchedule(settings: settings, goalID: goalID, title: goalTitle, factor: factor)
            
        case .buildStreak:
            return generateBuildStreak(settings: settings,  goalID: goalID,title: goalTitle, factor: factor)
            
        case .levelUp:
            return generateLevelUp(settings: settings,  goalID: goalID,title: goalTitle, factor: factor)
            
        case .milestones:
            return generateMilestones(settings: settings, goalID: goalID, title: goalTitle, factor: factor)
            
        case .reduce:
            return generateReduce(settings: settings, goalID: goalID, title: goalTitle, factor: factor)
        }
    }
    
    // MARK: - Finish Total
    private static func generateFinishTotal(
        settings: GoalSettings,
        goalID: UUID,
        title: String,
        factor: Double
    ) -> [GoalTask] {

        let target = Double(settings.targetNumber)
        let unit = settings.unit.isEmpty ? "units" : settings.unit

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let deadline = calendar.startOfDay(for: settings.deadline)

        let selectedDays = settings.selectedDays

        var validExecutionDates: [Date] = []

        var currentDate = today

        // جمع كل الأيام الصالحة داخل المدة حسب اختيار المستخدم
        while currentDate <= deadline {

            let weekday = calendar.component(.weekday, from: currentDate) - 1

            if selectedDays.contains(weekday) {
                validExecutionDates.append(currentDate)
            }

            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        let executionDaysCount = max(1, validExecutionDates.count)

        let amountPerTask = max(1, Int((target / Double(executionDaysCount)) * factor))

        var tasks: [GoalTask] = []

        for (index, date) in validExecutionDates.enumerated() {

        let progress = min(
                target,
                target * Double(index + 1) / Double(executionDaysCount)
            )
            tasks.append(
                GoalTask(
                    goalID: goalID,
                    title: "\(title) | \(Int(progress))/\(Int(target)) \(unit)",
                    scheduledDate: date
                )
            )
        }

        return tasks
    }

    // MARK: - Repeat on Schedule
    private static func generateRepeatSchedule(
        settings: GoalSettings,
        goalID: UUID,
        title: String,
        factor: Double
    ) -> [GoalTask] {

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let deadline = settings.deadline
        let selectedDays = settings.selectedDays

        var tasks: [GoalTask] = []

        var currentDate = today

        while currentDate <= deadline {

            let weekday = calendar.component(.weekday, from: currentDate) - 1

            if selectedDays.contains(weekday) {

                let fmt = DateFormatter()
                fmt.dateFormat = "EEE d MMM"

                let unit = settings.unit.isEmpty ? "session" : settings.unit

                tasks.append(
                    GoalTask(
                        goalID: goalID,
                        title: "\(title) — \(unit) on \(fmt.string(from: currentDate))",
                        scheduledDate: currentDate
                    )
                )
            }

            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        return tasks
    }
    
    // MARK: - Build Streak
    // مهمة يومية بسيطة × عدد الأيام المستهدفة
    private static func generateBuildStreak(settings: GoalSettings,goalID: UUID, title: String, factor: Double) -> [GoalTask] {
        let target    = settings.targetNumber
        let unit      = settings.unit.isEmpty ? "day" : settings.unit
        let adjTarget = max(3, Int(Double(target) * factor))
        let cal       = Calendar.current
        let today     = cal.startOfDay(for: Date())
        
        var tasks: [GoalTask] = []
        for i in 0..<adjTarget {
            guard let date = cal.date(byAdding: .day, value: i, to: today) else { continue }
            tasks.append(GoalTask( goalID: goalID,title: "\(title) — \(unit) \(i+1)", scheduledDate: date))
        }
        return tasks
    }
    
    // MARK: - Level Up
    private static func generateLevelUp(
        settings: GoalSettings,
        goalID: UUID,
        title: String,
        factor: Double
    ) -> [GoalTask] {

        let target = settings.targetNumber
        let paceWeeks = max(1, settings.stepUpPaceWeeks)
        let unit = settings.unit.isEmpty ? "min" : settings.unit

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let deadline = settings.deadline

        // عدد الخطوات
        let steps =
        max(
            1,
            calendar.dateComponents([.weekOfYear],
            from: today,
            to: deadline).weekOfYear ?? 1
        )

        let startAmount =
        min(steps / paceWeeks, 10)

        var tasks: [GoalTask] = []

        for i in 0..<steps {

            let progressRatio = Double(i) / Double(max(1, steps - 1))
            let amount = startAmount + Int(Double(target - startAmount) * progressRatio)

            let weekOffset = i * paceWeeks

            guard let date = calendar.date(
                byAdding: .weekOfYear,
                value: weekOffset,
                to: today
            ) else { continue }

            tasks.append(
                GoalTask(
                    goalID: goalID,
                    title: "\(title): \(unit)— Week \(weekOffset + 1)",
                    scheduledDate: date
                )
            )
        }

        return tasks
    }
    
    // MARK: - Milestones
    private static func generateMilestones(
        settings: GoalSettings,
        goalID: UUID,
        title: String,
        factor: Double
    ) -> [GoalTask] {

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let deadline = settings.deadline

        // كم يوم بين اليوم والديدلاين
        let totalDays = max(
            1,
            calendar.dateComponents([.day], from: today, to: deadline).day ?? 30
        )

        let activeDays = settings.selectedDays
        let activeDaysPerWeek = max(1, activeDays.count)

        // كم يوم فعلي نستخدمه للحساب
        let effectiveDays = max(1, Int(Double(totalDays) / 7.0 * Double(activeDaysPerWeek)))

        // عدد المراحل
        let rawCount = max(3, Int(Double(effectiveDays) * 0.3 * factor))
        let count = min(rawCount, 10)

        var tasks: [GoalTask] = []

        for i in 0..<count {

            // توزيع ذكي على الزمن
            let progressRatio = Double(i) / Double(max(1, count - 1))
            let dayOffset = Int(Double(totalDays) * progressRatio)

            guard let date = calendar.date(
                byAdding: .day,
                value: dayOffset,
                to: today
            ) else { continue }

            // تأكد أن اليوم ضمن الأيام المحددة
            let weekday = calendar.component(.weekday, from: date) - 1

            if !activeDays.contains(weekday) {
                continue
            }

            tasks.append(
                GoalTask(
                    goalID: goalID,
                    title: "\(title) — Milestone \(i+1)/\(count)",
                    scheduledDate: date
                )
            )
        }

        return tasks
    }
    // MARK: - Reduce
    private static func generateReduce(
        settings: GoalSettings,
        goalID: UUID,
        title: String,
        factor: Double
    ) -> [GoalTask] {
        
        let baseline = settings.baselineNumber
        let target = settings.targetNumber
        let diff = max(1, baseline - target)
        
        let steps = min(max(3, diff), 10)
        let stepSize = max(1, diff / steps)
        
        let unit = settings.unit.isEmpty ? "units" : settings.unit
        let today = Calendar.current.startOfDay(for: Date())
        
        var tasks: [GoalTask] = []
        
        for i in 0..<steps {
            
            let current = baseline - (stepSize * i)
            
            let date = Calendar.current.date(
                byAdding: .day,
                value: i,
                to: today
            )!
            
            tasks.append(
                GoalTask(
                    goalID: goalID,
                    title: "Reduce \(title) to \(max(target, current))",
                    scheduledDate: date
                )
            )
        }
        
        return tasks
    }
}
// MARK: - Energy helpers
extension Energytoday {
    var taskFactor: Double {
        switch value {
        case "3": return 1.0   // Hardcore
        case "2": return 0.7   // Average
        case "1": return 0.5   // Take Break
        default:  return 0.7
        }
    }
}


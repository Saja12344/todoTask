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
        goalTitle: String,
        energyFactor: Double = 1.0
    ) -> [GoalTask] {

        let factor = max(0.3, min(1.0, energyFactor))

        switch settings.goalType {
        case .finishTotal:
            return generateFinishTotal(settings: settings, title: goalTitle, factor: factor)

        case .repeatSchedule:
            return generateRepeatSchedule(settings: settings, title: goalTitle, factor: factor)

        case .buildStreak:
            return generateBuildStreak(settings: settings, title: goalTitle, factor: factor)

        case .levelUp:
            return generateLevelUp(settings: settings, title: goalTitle, factor: factor)

        case .milestones:
            return generateMilestones(settings: settings, title: goalTitle, factor: factor)

        case .reduce:
            return generateReduce(settings: settings, title: goalTitle, factor: factor)
        }
    }

    // MARK: - Finish Total
    // يقسم الرقم الكلي على الأيام المتاحة حتى الديدلاين
    private static func generateFinishTotal(settings: GoalSettings, title: String, factor: Double) -> [GoalTask] {
        let target    = settings.targetNumber
        let unit      = settings.unit.isEmpty ? "units" : settings.unit
        let deadline  = settings.deadline
        let today     = Calendar.current.startOfDay(for: Date())
        let days      = max(1, Calendar.current.dateComponents([.day], from: today, to: deadline).day ?? 30)
        let activeDaysPerWeek = max(1, settings.selectedDays.count)

        // الأسابيع المتبقية × أيام الأسبوع النشطة
        let totalActiveDays = max(1, Int(Double(days) / 7.0 * Double(activeDaysPerWeek)))

        // الكمية اليومية المعدّلة بالطاقة
        let rawPerDay  = Double(target) / Double(totalActiveDays)
        let adjPerDay  = max(1, Int(rawPerDay * factor))

        // عدد المهام = الأيام النشطة أو 10 كحد أقصى للعرض
        let taskCount  = min(totalActiveDays, max(5, Int(10.0 * factor)))

        var tasks: [GoalTask] = []
        for i in 0..<taskCount {
            tasks.append(GoalTask(title: "\(title): \(adjPerDay) \(unit) — Day \(i+1)"))
        }
        return tasks
    }

    // MARK: - Repeat on Schedule
    // مهمة واحدة لكل يوم نشط في الأسبوع القادم
    private static func generateRepeatSchedule(settings: GoalSettings, title: String, factor: Double) -> [GoalTask] {
        let unit      = settings.unit.isEmpty ? "session" : settings.unit
        let cal       = Calendar.current
        let today     = cal.startOfDay(for: Date())
        let activeDays = settings.selectedDays

        var tasks: [GoalTask] = []
        // توليد مهام للأسابيع الأربعة القادمة
        for weekOffset in 0..<4 {
            for dayIndex in 0..<7 {
                let dayNum = (dayIndex) % 7 // 0=Sun
                guard activeDays.contains(dayNum) else { continue }
                guard let date = cal.date(byAdding: .day, value: weekOffset * 7 + dayIndex, to: today) else { continue }
                // تعديل الطاقة: قلل المهام لو الطاقة منخفضة
                if factor < 0.7 && weekOffset > 1 { continue }
                let fmt = DateFormatter()
                fmt.dateFormat = "EEE d MMM"
                tasks.append(GoalTask(title: "\(title) — \(unit) on \(fmt.string(from: date))", scheduledDate: date))
            }
        }
        return tasks
    }

    // MARK: - Build Streak
    // مهمة يومية بسيطة × عدد الأيام المستهدفة
    private static func generateBuildStreak(settings: GoalSettings, title: String, factor: Double) -> [GoalTask] {
        let target    = settings.targetNumber
        let unit      = settings.unit.isEmpty ? "day" : settings.unit
        let adjTarget = max(3, Int(Double(target) * factor))
        let cal       = Calendar.current
        let today     = cal.startOfDay(for: Date())

        var tasks: [GoalTask] = []
        for i in 0..<adjTarget {
            guard let date = cal.date(byAdding: .day, value: i, to: today) else { continue }
            tasks.append(GoalTask(title: "\(title) — \(unit) \(i+1)", scheduledDate: date))
        }
        return tasks
    }

    // MARK: - Level Up
    // مهام تدريجية تزيد كل فترة
    private static func generateLevelUp(settings: GoalSettings, title: String, factor: Double) -> [GoalTask] {
        let target   = settings.targetNumber
        let pace     = max(1, settings.stepUpPaceWeeks)
        let unit     = settings.unit.isEmpty ? "min" : settings.unit
        let steps    = max(3, Int(Double(target / 10) * factor))

        var tasks: [GoalTask] = []
        let startAmount = max(1, Int(Double(target / (steps * 2)) * factor))

        for i in 0..<steps {
            let amount = startAmount + (startAmount * i / max(1, steps))
            let week   = i * pace + 1
            tasks.append(GoalTask(title: "\(title): \(amount) \(unit)/day — Week \(week)"))
        }
        return tasks
    }

    // MARK: - Milestones
    // مراحل مقسّمة على المدة
    private static func generateMilestones(settings: GoalSettings, title: String, factor: Double) -> [GoalTask] {
        let deadline  = settings.deadline
        let today     = Calendar.current.startOfDay(for: Date())
        let days      = max(7, Calendar.current.dateComponents([.day], from: today, to: deadline).day ?? 30)
        let rawCount  = max(3, Int(Double(days / 7) * factor))
        let count     = min(rawCount, 10)

        var tasks: [GoalTask] = []
        for i in 0..<count {
            tasks.append(GoalTask(title: "\(title) — Milestone \(i+1) of \(count)"))
        }
        return tasks
    }

    // MARK: - Reduce
    // خطوات تخفيض تدريجية
    private static func generateReduce(settings: GoalSettings, title: String, factor: Double) -> [GoalTask] {
        let baseline  = settings.baselineNumber
        let target    = settings.targetNumber
        let diff      = max(1, baseline - target)
        let rawSteps  = max(3, Int(Double(diff / max(1, diff/5)) * factor))
        let steps     = min(rawSteps, 10)
        let stepSize  = max(1, diff / steps)
        let unit      = settings.unit.isEmpty ? "units" : settings.unit

        var tasks: [GoalTask] = []
        for i in 0..<steps {
            let current = baseline - (stepSize * i)
            tasks.append(GoalTask(title: "Reduce \(title) to \(max(target, current)) \(unit)"))
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


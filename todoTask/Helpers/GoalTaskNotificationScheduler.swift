//
//  GoalTaskNotificationScheduler.swift
//  todoTask
//

import Foundation
import UserNotifications

enum GoalTaskNotificationScheduler {
    private static let idPrefix = "orbit.task."

    static func reschedule(goals: [OrbGoal]) {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let ours = requests.map(\.identifier).filter { $0.hasPrefix(idPrefix) }
            center.removePendingNotificationRequests(withIdentifiers: ours)
            center.getNotificationSettings { settings in
                guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else { return }
                for goal in goals {
                    for task in goal.tasks where !task.isFullyComplete {
                        schedule(task: task, goal: goal)
                    }
                }
            }
        }
    }

    private static func schedule(task: GoalTask, goal: OrbGoal) {
        let cal = Calendar.current
        var components = cal.dateComponents([.year, .month, .day], from: task.scheduledDate)

        if let settings = goal.settings {
            components.hour = cal.component(.hour, from: settings.startTime)
            components.minute = cal.component(.minute, from: settings.startTime)
        } else {
            components.hour = 9
            components.minute = 0
        }

        guard let fireDate = cal.date(from: components), fireDate > Date() else { return }

        let copy = motivationalCopy(for: task, goal: goal)
        let content = UNMutableNotificationContent()
        content.title = copy.title
        content.body = copy.body
        content.sound = .default

        let triggerComponents = cal.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        let request = UNNotificationRequest(
            identifier: "\(idPrefix)\(goal.id.uuidString).\(task.id.uuidString)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    private static var isArabic: Bool {
        UserDefaults.standard.string(forKey: "app_language") == "ar"
    }

    private struct MotivationalCopy {
        let title: String
        let body: String
    }

    private static func motivationalCopy(for task: GoalTask, goal: OrbGoal) -> MotivationalCopy {
        let index = abs(task.id.hashValue) % 5
        if isArabic {
            let titles = [
                "كوكبك ينتظرك ✨",
                "خطوة صغيرة، أوربت أكبر 🪐",
                "أنت قريبة!",
                "وقت إنجازك",
                "يلا نكملها ⚡"
            ]
            let bodies = [
                "«\(task.title)» على \(goal.title)",
                "خلّص «\(task.title)» وشوف كوكبك ينمو",
                "مهمة اليوم: \(task.title)",
                "خطوة وحدة تقربك — \(task.title)",
                "\(task.title) · \(goal.title)"
            ]
            return MotivationalCopy(title: titles[index], body: bodies[index])
        }
        let titles = [
            "Your orb is waiting ✨",
            "Small step, bigger orbit 🪐",
            "You're closer than you think",
            "Time to shine",
            "Let's finish this ⚡"
        ]
        let bodies = [
            "«\(task.title)» on \(goal.title)",
            "Complete «\(task.title)» and grow your planet",
            "Today's move: \(task.title)",
            "One step closer — \(task.title)",
            "\(task.title) · \(goal.title)"
        ]
        return MotivationalCopy(title: titles[index], body: bodies[index])
    }
}

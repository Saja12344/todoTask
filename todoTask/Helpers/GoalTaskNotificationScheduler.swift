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

        let content = UNMutableNotificationContent()
        content.title = notificationTitle()
        content.body = notificationBody(goalTitle: goal.title, taskTitle: task.title)
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

    private static func notificationTitle() -> String {
        isArabic ? "لديك مهمة" : "You have a task"
    }

    private static func notificationBody(goalTitle: String, taskTitle: String) -> String {
        if isArabic {
            return "على كوكب «\(goalTitle)»: \(taskTitle)"
        }
        return "On planet «\(goalTitle)»: \(taskTitle)"
    }
}

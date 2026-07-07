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
        let index = abs(task.id.hashValue) % 6
        if isArabic {
            let titles = [
                "كوكبك زعلان منك 🥺🪐",
                "طق طق… مين بالباب؟ مهمتك 👀",
                "لا تخليني أناديك مرتين 😤✨",
                "الكسل ما بيبني كواكب 🚀",
                "يا نجمة، وينك؟ 🌟",
                "تعال بسرعة قبل ما أزعل 😂"
            ]
            let bodies = [
                "«\(task.title)» في \(goal.title) قاعد ينطرك من الصبح 😅",
                "لو خلّصت «\(task.title)» بكبّر كوكبك… وعد 🪐",
                "مهمة اليوم: \(task.title) — يلا ولا تتمسكن 💪",
                "خطوة وحدة صغيرة و\(goal.title) يلمع أكثر ✨",
                "«\(task.title)»… التلفون شغّال، وين أنت؟ 📱😂",
                "دقيقتين بس وتخلّص \(task.title)، تكفى 🙏"
            ]
            return MotivationalCopy(title: titles[index], body: bodies[index])
        }
        let titles = [
            "Your orb misses you 🥺🪐",
            "Knock knock… it's your task 👀",
            "Don't make me ping you twice 😤✨",
            "Laziness builds zero planets 🚀",
            "Hey superstar, where you at? 🌟",
            "Come quick before I sulk 😂"
        ]
        let bodies = [
            "«\(task.title)» on \(goal.title) has been waiting all day 😅",
            "Finish «\(task.title)» and I'll grow your planet… promise 🪐",
            "Today's move: \(task.title) — let's gooo 💪",
            "One tiny step and \(goal.title) shines brighter ✨",
            "«\(task.title)»… phone's ringing, where are you? 📱😂",
            "Two minutes tops to finish \(task.title), pretty please 🙏"
        ]
        return MotivationalCopy(title: titles[index], body: bodies[index])
    }
}

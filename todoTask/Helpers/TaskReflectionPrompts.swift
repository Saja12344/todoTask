//
//  TaskReflectionPrompts.swift
//  todoTask
//

import Foundation

/// Short post-task prompts inspired by Gibbs reflective cycle (What / So what / Now what).
enum TaskReflectionPrompt: String, CaseIterable, Identifiable {
    case whatHappened
    case whatLearned
    case nextTime
    case closerToGoal
    case howItFelt

    var id: String { rawValue }

    func text(lang: LanguageManager) -> String {
        switch self {
        case .whatHappened:   return lang.t(.reflectionPromptWhat)
        case .whatLearned:    return lang.t(.reflectionPromptLearned)
        case .nextTime:       return lang.t(.reflectionPromptNext)
        case .closerToGoal:   return lang.t(.reflectionPromptCloser)
        case .howItFelt:      return lang.t(.reflectionPromptFeel)
        }
    }

    static func forTask(_ task: GoalTask) -> TaskReflectionPrompt {
        if let key = task.reflectionPromptKey,
           let saved = TaskReflectionPrompt(rawValue: key) {
            return saved
        }
        let index = abs(task.id.hashValue) % TaskReflectionPrompt.allCases.count
        return TaskReflectionPrompt.allCases[index]
    }
}

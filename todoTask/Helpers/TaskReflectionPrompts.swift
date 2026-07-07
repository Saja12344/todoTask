//
//  TaskReflectionPrompts.swift
//  todoTask
//

import Foundation

/// Short post-task prompts grounded in the "What / So what / Now what" reflective
/// framework, plus motivation-oriented questions (a proud win, how it felt, obstacles).
enum TaskReflectionPrompt: String, CaseIterable, Identifiable {
    case proudWin
    case whatHappened
    case whatLearned
    case gotStuck
    case nextTime
    case closerToGoal
    case howItFelt

    var id: String { rawValue }

    func text(lang: LanguageManager) -> String {
        switch self {
        case .proudWin:       return lang.t(.reflectionPromptProud)
        case .whatHappened:   return lang.t(.reflectionPromptWhat)
        case .whatLearned:    return lang.t(.reflectionPromptLearned)
        case .gotStuck:       return lang.t(.reflectionPromptStuck)
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

import Foundation

struct GoalSuggestionData {
    
    static let database: [GoalShape: [String]] = [
        
        .finishTotal: [
            "read", "books", "pages", "chapters", "save", "money", "SAR", "dollars",
            "riyal", "budget", "lose", "weight", "kg", "pounds", "lbs", "workout",
            "reps", "sets", "exercise", "count", "total", "number", "reach", "achieve"
        ],
        
        .repeatOnSchedule: [
            "gym", "times", "week", "weekly", "meditate", "meditation", "yoga",
            "mindfulness", "pray", "prayer", "salah", "study", "class", "lesson",
            "practice", "session", "schedule", "routine", "certain days"
        ],
        
        .buildStreak: [
            "streak", "consecutive", "everyday", "daily", "every day", "journal",
            "journaling", "diary", "write", "habit", "routine", "consistent",
            "without stopping", "continuous", "chain"
        ],
        
        .levelUpGradually: [
            "run", "running", "5K", "10K", "marathon", "jog", "learn", "learning",
            "study", "skill", "master", "improve", "increase", "gradually", "progress",
            "grow", "coding", "programming", "code", "developer", "language", "Spanish",
            "French", "Arabic", "English", "Korean", "Japanese", "German", "level up",
            "difficulty", "harder", "better", "faster", "stronger"
        ],
        
        .finishByMilestones: [
            "project", "complete", "finish", "build", "create", "develop", "launch",
            "release", "publish", "ship", "app", "application", "software", "website",
            "site", "course", "curriculum", "program", "training", "book", "thesis",
            "paper", "document", "presentation", "slides", "deck", "milestones",
            "steps", "phases", "stages"
        ],
        
        .reduceSomething: [
            "reduce", "decrease", "less", "lower", "cut", "minimize", "screen time",
            "phone", "mobile", "social media", "instagram", "twitter", "tiktok",
            "facebook", "smoking", "cigarettes", "vape", "quit", "stop", "sugar",
            "sweets", "candy", "junk food", "spending", "expenses", "waste", "calories"
        ]
    ]
    
    static func suggest(for text: String) -> GoalShape? {
        let lowercased = text.lowercased()
        var scores: [GoalShape: Int] = [:]
        
        for (shape, keywords) in database {
            let matches = keywords.filter { lowercased.contains($0) }.count
            if matches > 0 {
                scores[shape] = matches
            }
        }
        
        return scores.max(by: { $0.value < $1.value })?.key
    }
    
    static func getDescription(_ shape: GoalShape) -> String {
        switch shape {
        case .finishTotal: return "reach a set number"
        case .repeatOnSchedule: return "do on certain days each week"
        case .buildStreak: return "do every day without stopping"
        case .levelUpGradually: return "increase difficulty over time"
        case .finishByMilestones: return "complete step by step"
        case .reduceSomething: return "decrease over time"
        }
    }
}

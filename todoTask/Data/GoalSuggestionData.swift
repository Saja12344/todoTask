import Foundation

struct GoalSuggestionData {

    struct ExampleChip: Identifiable {
        let id = UUID()
        let text: String
        let label: String
    }

    static let examples: [ExampleChip] = [
        ExampleChip(text: "Read 20 books", label: "Read 20 books"),
        ExampleChip(text: "Gym 3 times per week", label: "Gym 3× / week"),
        ExampleChip(text: "Cut screen time to 2 hours", label: "Less screen time"),
        ExampleChip(text: "Learn coding gradually", label: "Level up coding"),
        ExampleChip(text: "Lose 30 kg", label: "Lose 30 kg"),
        ExampleChip(text: "Meditate every day", label: "Daily meditation")
    ]

    static let englishExamples: [ExampleChip] = examples

    static let arabicExamples: [ExampleChip] = [
        ExampleChip(text: "أقرأ 20 كتاباً", label: "20 كتاب"),
        ExampleChip(text: "نادي 3 مرات بالأسبوع", label: "نادي 3×"),
        ExampleChip(text: "أقلل وقت الجوال لساعتين", label: "وقت شاشة"),
        ExampleChip(text: "أتعلم البرمجة تدريجياً", label: "تطوير مستوى"),
        ExampleChip(text: "أنزل 30 كيلو", label: "30 كجم"),
        ExampleChip(text: "تأمل كل يوم", label: "تأمل يومي")
    ]

    static let database: [GoalType: [String]] = [

        .reachTarget: [
            "read", "books", "pages", "chapters", "save", "money", "sar", "dollars",
            "riyal", "budget", "lose", "weight", "kg", "pounds", "lbs", "workout",
            "reps", "sets", "exercise", "count", "total", "number", "reach", "achieve",
            "target", "goal", "finish", "complete", "project", "build", "create", "develop",
            "launch", "release", "publish", "ship", "app", "application", "software",
            "website", "course", "training", "thesis", "presentation", "milestones",
            "steps", "phases", "stages", "lessons", "units",
            "أقرأ", "كتاب", "كتب", "صفحة", "فلوس", "ريال", "ادخار", "وزن", "كيلو", "كجم",
            "تمرين", "رقم", "هدف", "انجاز", "انهاء", "مشروع", "درس", "وحدة"
        ],

        .buildHabit: [
            "gym", "times", "week", "weekly", "meditate", "meditation", "yoga",
            "mindfulness", "pray", "prayer", "salah", "study", "class", "lesson",
            "practice", "session", "schedule", "routine", "certain days", "streak",
            "consecutive", "everyday", "daily", "every day", "journal", "journaling",
            "diary", "habit", "consistent", "without stopping", "continuous", "chain",
            "repeat", "regular", "often",
            "نادي", "مرة", "اسبوع", "أسبوع", "يومي", "كل يوم", "عادة", "مداومة",
            "صلاة", "ذكر", "قراءة", "دراسة", "تمرين", "روتين", "ستريك", "متتابع"
        ],

        .levelUp: [
            "run", "running", "5k", "10k", "marathon", "jog", "learn", "learning",
            "skill", "master", "improve", "increase", "gradually", "progress",
            "grow", "coding", "programming", "code", "developer", "language", "spanish",
            "french", "arabic", "english", "korean", "japanese", "german", "level up",
            "difficulty", "harder", "better", "faster", "stronger", "pace", "step up",
            "تعلم", "تدريج", "تدريجيا", "برمجة", "لغة", "مستوى", "تطوير", "تحسين",
            "جري", "ماراثون", "مهارة"
        ],

        .reduce: [
            "reduce", "decrease", "less", "lower", "cut", "minimize", "screen time",
            "phone", "mobile", "social media", "instagram", "twitter", "tiktok",
            "facebook", "smoking", "cigarettes", "vape", "quit", "stop", "sugar",
            "sweets", "candy", "junk food", "spending", "expenses", "waste", "calories",
            "limit", "under", "avoid", "cut back",
            "أقلل", "تقليل", "نقص", "جوال", "سكر", "تدخين", "اوقف", "وقف", "صرف",
            "سوشال", "انستا", "تيك", "سناك", "وجبات", "سعرات"
        ]
    ]

    static func suggest(for text: String) -> GoalType? {
        let lowercased = text.lowercased()
        var scores: [GoalType: Int] = [:]

        for (type, keywords) in database {
            let matches = keywords.filter { lowercased.contains($0.lowercased()) }.count
            if matches > 0 {
                scores[type] = matches
            }
        }

        if let top = scores.max(by: { $0.value < $1.value })?.key {
            return top
        }

        if lowercased.range(of: #"\d+"#, options: .regularExpression) != nil {
            return .reachTarget
        }

        return nil
    }

    static func getDescription(_ type: GoalType) -> String {
        LanguageManager().goalTypeDescription(type)
    }

    // MARK: - Parse written goal → pre-fill settings

    struct ParsedGoalDraft {
        var targetNumber: Int?
        var baselineNumber: Int?
        var unit: String?
        var prefersMilestones: Bool = false
        var prefersStreak: Bool = false
    }

    private static let unitTokens: [(pattern: String, unit: String)] = [
        ("كيلو", "kg"), ("كجم", "kg"), ("kg", "kg"), ("kilogram", "kg"),
        ("book", "books"), ("books", "books"), ("كتاب", "books"), ("كتب", "books"),
        ("page", "pages"), ("pages", "pages"), ("صفحة", "pages"),
        ("km", "km"), ("كلم", "km"),
        ("lesson", "lessons"), ("lessons", "lessons"), ("درس", "lessons"),
        ("minute", "min"), ("min", "min"), ("دقيقة", "min"),
        ("sar", "SAR"), ("riyal", "SAR"), ("ريال", "SAR"),
        ("session", "sessions"), ("مرة", "times"), ("times", "times")
    ]

    private static let milestoneHints = [
        "milestone", "milestones", "project", "phase", "phases", "step by step",
        "launch", "thesis", "course", "app", "website", "مرحلة", "مراحل", "مشروع", "خطوات"
    ]

    static func parse(_ text: String) -> ParsedGoalDraft {
        let lower = text.lowercased()
        var draft = ParsedGoalDraft()

        draft.prefersMilestones = milestoneHints.contains { lower.contains($0) }
        draft.prefersStreak = lower.contains("every day") || lower.contains("everyday")
            || lower.contains("daily") || lower.contains("يومي") || lower.contains("كل يوم")
            || lower.contains("streak")

        let numbers = extractNumbers(from: text)
        if numbers.count >= 2, suggest(for: text) == .reduce || lower.contains("reduce")
            || lower.contains("أقلل") || lower.contains("to ") {
            draft.baselineNumber = numbers[0]
            draft.targetNumber = numbers[1]
        } else if let first = numbers.first {
            draft.targetNumber = first
        }

        for token in unitTokens {
            if lower.contains(token.pattern) {
                draft.unit = token.unit
                break
            }
        }

        return draft
    }

    private static func extractNumbers(from text: String) -> [Int] {
        guard let regex = try? NSRegularExpression(pattern: #"\d+"#) else { return [] }
        let range = NSRange(text.startIndex..., in: text)
        return regex.matches(in: text, range: range).compactMap {
            guard let r = Range($0.range, in: text) else { return nil }
            return Int(text[r])
        }
    }
}

import SwiftUI

// MARK: - Shape catalog (matches Figma: 6 glass cards)

struct GoalShapeOption: Identifiable, Hashable {
    let id: String
    let goalType: GoalType
    let isMilestoneMode: Bool
    let isStreakMode: Bool
    let icon: String
    let titleKey: L10nKey
    let descKey: L10nKey

    static let catalog: [GoalShapeOption] = [
        GoalShapeOption(
            id: "finish-total",
            goalType: .reachTarget,
            isMilestoneMode: false,
            isStreakMode: false,
            icon: "scope",
            titleKey: .shapeFinishTotalTitle,
            descKey: .shapeFinishTotalDesc
        ),
        GoalShapeOption(
            id: "repeat-schedule",
            goalType: .buildHabit,
            isMilestoneMode: false,
            isStreakMode: false,
            icon: "calendar.badge.clock",
            titleKey: .shapeRepeatScheduleTitle,
            descKey: .shapeRepeatScheduleDesc
        ),
        GoalShapeOption(
            id: "build-streak",
            goalType: .buildHabit,
            isMilestoneMode: false,
            isStreakMode: true,
            icon: "flame.fill",
            titleKey: .shapeBuildStreakTitle,
            descKey: .shapeBuildStreakDesc
        ),
        GoalShapeOption(
            id: "level-up",
            goalType: .levelUp,
            isMilestoneMode: false,
            isStreakMode: false,
            icon: "chart.line.uptrend.xyaxis",
            titleKey: .shapeLevelUpGradualTitle,
            descKey: .shapeLevelUpGradualDesc
        ),
        GoalShapeOption(
            id: "finish-milestones",
            goalType: .reachTarget,
            isMilestoneMode: true,
            isStreakMode: false,
            icon: "flag.checkered",
            titleKey: .shapeFinishMilestonesTitle,
            descKey: .shapeFinishMilestonesDesc
        ),
        GoalShapeOption(
            id: "reduce",
            goalType: .reduce,
            isMilestoneMode: false,
            isStreakMode: false,
            icon: "arrow.down.circle",
            titleKey: .shapeReduceTitle,
            descKey: .shapeReduceDesc
        )
    ]

    func title(_ lang: LanguageManager) -> String { lang.t(titleKey) }
    func description(_ lang: LanguageManager) -> String { lang.t(descKey) }

    static func defaultFor(_ type: GoalType) -> GoalShapeOption {
        if let match = catalog.first(where: {
            $0.goalType == type && !$0.isMilestoneMode && !$0.isStreakMode
        }) {
            return match
        }
        return catalog.first { $0.goalType == type } ?? catalog[0]
    }

    static func matching(type: GoalType, milestone: Bool, streak: Bool) -> GoalShapeOption? {
        catalog.first {
            $0.goalType == type
                && $0.isMilestoneMode == milestone
                && $0.isStreakMode == streak
        }
    }
}

struct GoalShapeGrid: View {
    @EnvironmentObject private var lang: LanguageManager
    let selectedID: String?
    let onSelect: (GoalShapeOption) -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 14) {
            ForEach(GoalShapeOption.catalog) { option in
                GoalCard(
                    icon: option.icon,
                    title: option.title(lang),
                    description: option.description(lang),
                    isSelected: selectedID == option.id
                ) {
                    onSelect(option)
                }
            }
        }
    }
}

struct GoalCard: View {
    let icon: String
    let title: String
    let description: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 34, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(height: 40)

                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)

                Text(description)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(.white.opacity(0.55))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.85)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 132)
            .background {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(.clear)
                    .glassEffect(
                        .clear.tint(Color.black.opacity(isSelected ? 0.44 : 0.34)),
                        in: .rect(cornerRadius: 22)
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(
                        isSelected ? Color("accent").opacity(0.9) : Color.white.opacity(0.22),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            }
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

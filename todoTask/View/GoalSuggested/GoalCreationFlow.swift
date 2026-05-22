//
//  GoalCreationFlow.swift
//  todoTask
//

import SwiftUI

enum GoalCreationStep: Hashable {
    case write
    case suggested(text: String, type: GoalType?)
    case configure(type: GoalType?, draftText: String, openSettings: Bool)
    case design
}

// MARK: - Draft banner on settings screens

struct GoalDraftBanner: View {
    let goalText: String
    let goalType: GoalType?

    @EnvironmentObject private var lang: LanguageManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(lang.t(.yourGoalLabel))
                .font(.caption.weight(.semibold))
                .foregroundColor(.white.opacity(0.5))
            Text(goalText)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            if let goalType {
                HStack(spacing: 6) {
                    Image(systemName: goalType.creationIcon)
                        .font(.caption)
                    Text(lang.goalTypeTitle(goalType))
                        .font(.caption.weight(.medium))
                }
                .foregroundColor(.cyan.opacity(0.9))
            }
            Text(lang.t(.draftPrefillHint))
                .font(.caption2)
                .foregroundColor(.white.opacity(0.45))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .glassEffect(.clear.tint(Color.black.opacity(0.35)), in: .rect(cornerRadius: 18))
    }
}

// MARK: - Step indicator

struct GoalCreationStepIndicator: View {
    let current: Int
    let total: Int = 4

    @EnvironmentObject private var lang: LanguageManager

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 6) {
                ForEach(1...total, id: \.self) { step in
                    Capsule()
                        .fill(step <= current ? Color.white.opacity(0.9) : Color.white.opacity(0.2))
                        .frame(height: 4)
                }
            }
            .flipsForRightToLeftLayoutDirection(true)

            HStack {
                Text(lang.stepCounter(current: current, total: total))
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white.opacity(0.55))
                Spacer()
                Text(lang.stepLabel(current))
                    .font(.caption.weight(.medium))
                    .foregroundColor(.white.opacity(0.75))
            }
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - Goal type presentation

extension GoalType {
    var creationIcon: String {
        switch self {
        case .reachTarget: return "scope"
        case .buildHabit:  return "flame.fill"
        case .levelUp:     return "chart.line.uptrend.xyaxis"
        case .reduce:      return "arrow.down.circle"
        }
    }

    func localizedTitle(_ lang: LanguageManager) -> String {
        lang.goalTypeTitle(self)
    }
}

struct GoalTypeChip: View {
    let type: GoalType
    let isSelected: Bool
    let action: () -> Void

    @EnvironmentObject private var lang: LanguageManager

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: type.creationIcon)
                    .font(.system(size: 26))
                    .foregroundColor(.white)
                Text(lang.goalTypeTitle(type))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 96)
            .glassEffect(
                .clear.tint(Color.black.opacity(isSelected ? 0.5 : 0.35)),
                in: .rect(cornerRadius: 18)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(isSelected ? Color.white.opacity(0.85) : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

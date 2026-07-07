//
//  GoalCreationFlow.swift
//  todoTask
//

import SwiftUI

enum GoalCreationStep: Hashable {
    case write
    case suggested(text: String, type: GoalType?)
    case configure(type: GoalType?, draftText: String, openSettings: Bool, milestoneMode: Bool, streakMode: Bool)
    case design
}

// MARK: - Draft banner on settings screens

struct GoalDraftBanner: View {
    let goalText: String
    let goalType: GoalType?

    @EnvironmentObject private var lang: LanguageManager

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(lang.t(.yourGoalLabel))
                .font(.caption2.weight(.semibold))
                .foregroundColor(.white.opacity(0.45))
            Text(goalText)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(2)
            if let goalType {
                HStack(spacing: 5) {
                    Image(systemName: goalType.creationIcon)
                        .font(.caption2)
                    Text(lang.goalTypeTitle(goalType))
                        .font(.caption2.weight(.medium))
                }
                .foregroundColor(.white.opacity(0.5))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .glassEffect(.clear.tint(Color.black.opacity(0.32)), in: .rect(cornerRadius: 16))
    }
}

// MARK: - Step indicator

/// Soft teal/purple blobs behind suggest screen (Figma).
struct GoalFlowFluidBackdrop: View {
    var body: some View {
        ZStack {
            Ellipse()
                .fill(Color("accent").opacity(0.28))
                .frame(width: 260, height: 190)
                .blur(radius: 48)
                .offset(x: -50, y: -10)
            Ellipse()
                .fill(Color.purple.opacity(0.22))
                .frame(width: 200, height: 160)
                .blur(radius: 44)
                .offset(x: 70, y: 30)
            Ellipse()
                .fill(Color("accent").opacity(0.12))
                .frame(width: 180, height: 140)
                .blur(radius: 36)
                .offset(x: -20, y: 50)
        }
        .allowsHitTesting(false)
    }
}

struct GoalCreationStepIndicator: View {
    let current: Int
    let total: Int = 4

    @EnvironmentObject private var lang: LanguageManager

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text(lang.stepCounter(current: current, total: total))
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white.opacity(0.55))
                Spacer()
                Text(lang.stepLabel(current))
                    .font(.caption.weight(.medium))
                    .foregroundColor(.white.opacity(0.75))
            }

            HStack(spacing: 6) {
                ForEach(1...total, id: \.self) { step in
                    Capsule()
                        .fill(step <= current ? Color.white.opacity(0.9) : Color.white.opacity(0.2))
                        .frame(height: 4)
                }
            }
            .flipsForRightToLeftLayoutDirection(true)
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
                    .foregroundColor(isSelected ? Color("accent") : .white)
                    .symbolEffect(.bounce, value: isSelected)
                Text(lang.goalTypeTitle(type))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 96)
            .scaleEffect(isSelected ? 1.04 : 1)
            .glassEffect(
                .clear.tint(Color.black.opacity(isSelected ? 0.55 : 0.35)),
                in: .rect(cornerRadius: 18)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(isSelected ? Color("accent").opacity(0.9) : Color.clear, lineWidth: 2)
            )
            .shadow(color: isSelected ? Color("accent").opacity(0.35) : .clear, radius: 10, y: 4)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.32, dampingFraction: 0.72), value: isSelected)
    }
}

//
//  AchievementsView.swift
//  todoTask
//

import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject private var store: OrbGoalStore
    @EnvironmentObject private var achievements: OrbAchievementStore
    @EnvironmentObject private var lang: LanguageManager

    private var completedTasks: [(goal: OrbGoal, task: GoalTask)] {
        store.goals.flatMap { goal in
            goal.tasks
                .filter(\.isFullyComplete)
                .sorted { ($0.completedAt ?? $0.scheduledDate) > ($1.completedAt ?? $1.scheduledDate) }
                .map { (goal, $0) }
        }
    }

    private var reflections: [(goal: OrbGoal, task: GoalTask)] {
        completedTasks.filter { !($0.task.reflectionNote ?? "").isEmpty }
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: [.darkBlu, .black], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            StarsBackgroundView().opacity(0.5)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    statsRow

                    if !achievements.wonPlanets.isEmpty {
                        sectionHeader(lang.t(.achievementsWonPlanets))
                        ForEach(achievements.wonPlanets) { planet in
                            wonPlanetRow(planet)
                        }
                    }

                    sectionHeader(lang.t(.achievementsCompleted))
                    if completedTasks.isEmpty {
                        emptyCard(lang.t(.achievementsNoTasks))
                    } else {
                        Text(lang.achievementsCompletedCount(completedTasks.count))
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.55))
                            .padding(.horizontal, 4)

                        ForEach(completedTasks.prefix(12), id: \.task.id) { item in
                            completedTaskRow(goal: item.goal, task: item.task)
                        }
                    }

                    sectionHeader(lang.t(.achievementsReflections))
                    if reflections.isEmpty {
                        emptyCard(lang.t(.achievementsNoReflections))
                    } else {
                        ForEach(reflections.prefix(8), id: \.task.id) { item in
                            reflectionRow(goal: item.goal, task: item.task)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle(lang.t(.achievementsTitle))
        .navigationBarTitleDisplayMode(.large)
        .orbitForcedDark()
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            statPill(value: "\(store.goals.count)", label: lang.t(.achievementsStatOrbs), color: Color("accent"))
            statPill(value: "\(completedTasks.count)", label: lang.t(.achievementsStatDone), color: .purple)
            statPill(value: "\(achievements.wonPlanets.count)", label: lang.t(.achievementsStatWon), color: .yellow)
        }
    }

    private func statPill(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(.white.opacity(0.55))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white.opacity(0.06))
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline.weight(.bold))
            .foregroundStyle(.white)
            .padding(.top, 4)
    }

    private func emptyCard(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(.white.opacity(0.45))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.white.opacity(0.04))
            }
    }

    private func wonPlanetRow(_ planet: WonPlanetRecord) -> some View {
        HStack(spacing: 14) {
            PlanetOrbView(
                size: 52,
                gradientColors: planet.planetGradient.map { Color(hex: $0) ?? .purple },
                glow: planet.planetGlow,
                textureAssetName: planet.planetTextureAsset,
                textureOpacity: planet.planetTextureOpacity
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(planet.planetName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Text(lang.achievementsWonOn(planet.wonAt))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.45))
            }
            Spacer()
            Text("🏆")
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.white.opacity(0.06))
        }
    }

    private func completedTaskRow(goal: OrbGoal, task: GoalTask) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(goal.accentColor.opacity(0.2))
                .frame(width: 36, height: 36)
                .overlay {
                    Image(systemName: "checkmark")
                        .font(.caption.bold())
                        .foregroundStyle(goal.accentColor)
                }

            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.85))
                    .lineLimit(1)
                Text(goal.title)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
            }
            Spacer()
            if task.reflectionNote != nil {
                Image(systemName: "text.quote")
                    .foregroundStyle(goal.accentColor.opacity(0.8))
            }
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.white.opacity(0.04))
        }
    }

    private func reflectionRow(goal: OrbGoal, task: GoalTask) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(task.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Spacer()
                Text(goal.title)
                    .font(.caption2)
                    .foregroundStyle(goal.accentColor.opacity(0.8))
            }

            if let key = task.reflectionPromptKey,
               let prompt = TaskReflectionPrompt(rawValue: key) {
                Text(prompt.text(lang: lang))
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.5))
            }

            Text(task.reflectionNote ?? "")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
                .lineLimit(4)
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white.opacity(0.06))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(goal.accentColor.opacity(0.2), lineWidth: 1)
                }
        }
    }
}

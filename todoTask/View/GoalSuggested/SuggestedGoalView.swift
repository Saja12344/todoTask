//
//  SuggestedGoalView.swift
//  todoTask
//

import SwiftUI

struct SuggestedGoalView: View {
    let goalText: String
    let suggestedType: GoalType?
    let onContinue: (GoalType) -> Void
    let onBack: () -> Void

    @EnvironmentObject private var lang: LanguageManager
    @State private var selectedType: GoalType?
    @State private var showPicker = false

    private var resolvedType: GoalType? {
        selectedType ?? suggestedType
    }

    var body: some View {
        GoalFlowScreen(
            background: { AppBackground() },
            topBar: {
                GoalFlowNavigationRow(
                    onBack: onBack,
                    trailing: {
                        Group {
                            if resolvedType != nil {
                                GoalFlowNextButton(action: continueTapped)
                            } else {
                                GoalFlowNextButton(action: {})
                                    .opacity(0.4)
                                    .allowsHitTesting(false)
                            }
                        }
                    }
                )
                .frame(height: GoalFlowLayout.topBarHeight)
            },
            content: {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        GoalCreationStepIndicator(current: 2)

                        Text(lang.t(.yourGoal))
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.white.opacity(0.55))

                        Text(goalText)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)

                        if showPicker {
                            pickerSection
                        } else if let type = suggestedType {
                            suggestionCardView(for: type)
                        } else {
                            noSuggestionCard
                        }

                        Button {
                            withAnimation(.spring(response: 0.35)) {
                                showPicker.toggle()
                            }
                        } label: {
                            Text(showPicker ? lang.t(.hideTypes) : lang.t(.chooseDifferentType))
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .glassEffect(.clear.tint(Color.black.opacity(0.4)), in: .rect(cornerRadius: 22))
                        }
                        .padding(.horizontal, 8)

                        if !showPicker, suggestedType != nil {
                            Text(lang.t(.suggestNextHint))
                                .font(.footnote)
                                .foregroundColor(.white.opacity(0.45))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 16)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
        )
        .onAppear {
            selectedType = suggestedType
        }
    }

    private func suggestionCardView(for type: GoalType) -> some View {
        VStack(spacing: 14) {
            Text(lang.t(.weSuggest))
                .font(.subheadline.weight(.medium))
                .foregroundColor(.white.opacity(0.6))

            HStack(spacing: 12) {
                Image(systemName: type.creationIcon)
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                VStack(alignment: .leading, spacing: 4) {
                    Text(lang.goalTypeTitle(type))
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    Text(lang.goalTypeDescription(type))
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                Spacer(minLength: 0)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassEffect(.clear.tint(Color.black.opacity(0.45)), in: .rect(cornerRadius: 22))
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(Color.cyan.opacity(0.35), lineWidth: 1)
            )
        }
    }

    private var noSuggestionCard: some View {
        VStack(spacing: 10) {
            Image(systemName: "sparkles")
                .font(.system(size: 36))
                .foregroundColor(.white.opacity(0.5))
            Text(lang.t(.noMatchTitle))
                .font(.headline)
                .foregroundColor(.white)
            Text(lang.t(.noMatchBody))
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.65))
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .glassEffect(.clear.tint(Color.black.opacity(0.35)), in: .rect(cornerRadius: 22))
        .onAppear {
            showPicker = true
        }
    }

    private var pickerSection: some View {
        VStack(spacing: 12) {
            Text(lang.t(.goalTypes))
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(GoalType.allCases, id: \.self) { type in
                    GoalTypeChip(
                        type: type,
                        isSelected: (selectedType ?? suggestedType) == type
                    ) {
                        selectedType = type
                    }
                }
            }
        }
    }

    private func continueTapped() {
        guard let type = resolvedType else { return }
        onContinue(type)
    }
}

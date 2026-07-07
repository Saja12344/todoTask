//
//  WriteGoalView.swift
//  todoTask
//

import SwiftUI

struct WriteGoalView: View {
    let onDone: (String, GoalType?) -> Void
    let onSkipToManual: () -> Void
    let onCancel: (() -> Void)?

    @EnvironmentObject private var lang: LanguageManager
    @State private var goalText: String = ""
    @FocusState private var fieldFocused: Bool

    private var canSubmit: Bool {
        !goalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(
        onDone: @escaping (String, GoalType?) -> Void,
        onSkipToManual: @escaping () -> Void,
        onCancel: (() -> Void)? = nil
    ) {
        self.onDone = onDone
        self.onSkipToManual = onSkipToManual
        self.onCancel = onCancel
    }

    var body: some View {
        GoalFlowScreen(
            background: { AppBackground() },
            topBar: {
                HStack {
                    GoalFlowBackButton(action: { onCancel?() })
                    Spacer()
                    GoalFlowCheckButton(isEnabled: canSubmit, action: submit)
                }
            },
            content: {
                GeometryReader { geo in
                    VStack(spacing: 0) {
                        Spacer(minLength: geo.size.height * 0.14)

                        VStack(spacing: 20) {
                            Text(lang.t(.writeGoalTitle))
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)

                            TextField(
                                "",
                                text: $goalText,
                                prompt: Text(lang.t(.writePlaceholder))
                                    .foregroundStyle(.white.opacity(0.35))
                            )
                            .focused($fieldFocused)
                            .foregroundStyle(.white)
                            .font(.system(size: 17, weight: .medium))
                            .padding(.horizontal, 22)
                            .padding(.vertical, 20)
                            .background {
                                Capsule()
                                    .fill(Color.black.opacity(0.38))
                            }
                            .overlay {
                                Capsule()
                                    .stroke(
                                        fieldFocused ? Color("accent").opacity(0.5) : .white.opacity(0.12),
                                        lineWidth: 1
                                    )
                            }
                            .submitLabel(.continue)
                            .onSubmit { if canSubmit { submit() } }

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(exampleChips) { chip in
                                        Button { goalText = chip.text } label: {
                                            Text(chip.label)
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundStyle(.white.opacity(0.75))
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 8)
                                                .background(Capsule().fill(.white.opacity(0.08)))
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal, 2)
                            }
                        }
                        .padding(.horizontal, 28)

                        Spacer(minLength: 0)

                        Button(action: onSkipToManual) {
                            Text(lang.t(.skipManual))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.white.opacity(0.38))
                        }
                        .buttonStyle(.plain)
                        .padding(.bottom, 16)
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                }
            }
        )
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                fieldFocused = true
            }
        }
    }

    private var exampleChips: [GoalSuggestionData.ExampleChip] {
        lang.language == .arabic ? GoalSuggestionData.arabicExamples : GoalSuggestionData.englishExamples
    }

    private func submit() {
        let trimmed = goalText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        onDone(trimmed, GoalSuggestionData.suggest(for: trimmed))
    }
}

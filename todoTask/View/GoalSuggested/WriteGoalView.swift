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

    private var canSubmit: Bool {
        !goalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var liveHint: String? {
        lang.liveHint(for: goalText, suggested: GoalSuggestionData.suggest(for: goalText))
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
            background: {
                ZStack {
                    Rectangle()
                        .fill(LinearGradient(colors: [.darkBlu, .dark], startPoint: .bottom, endPoint: .top))
                    Image("Star")
                        .resizable()
                        .scaledToFill()
                        .opacity(0.85)
                    Image("Gliter")
                        .resizable()
                }
            },
            topBar: {
                GoalFlowNavigationRow(
                    onBack: { onCancel?() },
                    trailing: {
                        GoalFlowCheckButton(isEnabled: canSubmit, action: submit)
                    }
                )
                .frame(height: GoalFlowLayout.topBarHeight)
            },
            content: {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        GoalCreationStepIndicator(current: 1)

                        VStack(alignment: .leading, spacing: 8) {
                            Text(lang.t(.writeGoalTitle))
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)

                            Text(lang.t(.writeGoalSubtitle))
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.65))
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text(lang.t(.tryIncluding))
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.white.opacity(0.5))
                            VStack(alignment: .leading, spacing: 4) {
                                templateRow(lang.t(.whatLabel), lang.language == .arabic ? "مثال: قراءة، نادي، ادخار" : "e.g. read, gym, save money")
                                templateRow(lang.t(.howMuchLabel), lang.language == .arabic ? "مثال: 20 كتاب، 3 مرات بالأسبوع" : "e.g. 20 books, 3× per week")
                            }
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color.black.opacity(0.25)))

                        TextField(
                            "",
                            text: $goalText,
                            prompt: Text(lang.t(.writePlaceholder))
                                .foregroundColor(.white.opacity(0.35))
                        )
                        .foregroundColor(.white)
                        .font(.system(size: 17))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 16)
                        .background(RoundedRectangle(cornerRadius: 20).fill(Color.black.opacity(0.35)))
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.2), lineWidth: 1))
                        .multilineTextAlignment(lang.language == .arabic ? .trailing : .leading)

                        if let liveHint {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.yellow.opacity(0.9))
                                    .font(.system(size: 14))
                                Text(liveHint)
                                    .font(.footnote)
                                    .foregroundColor(.white.opacity(0.75))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.08)))
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text(lang.t(.examples))
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.white.opacity(0.5))

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(exampleChips) { chip in
                                        Button { goalText = chip.text } label: {
                                            Text(chip.label)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 14)
                                                .padding(.vertical, 10)
                                                .background(Capsule().fill(Color.white.opacity(0.12)))
                                                .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }

                        Button(action: onSkipToManual) {
                            Text(lang.t(.skipManual))
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.75))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)
                }
            }
        )
    }

    private var exampleChips: [GoalSuggestionData.ExampleChip] {
        lang.language == .arabic ? GoalSuggestionData.arabicExamples : GoalSuggestionData.englishExamples
    }

    private func templateRow(_ title: String, _ example: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Text("•").foregroundColor(.white.opacity(0.4))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white.opacity(0.7))
                Text(example)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.45))
            }
        }
    }

    private func submit() {
        let trimmed = goalText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        onDone(trimmed, GoalSuggestionData.suggest(for: trimmed))
    }
}

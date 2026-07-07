//
//  TaskReflectionSheet.swift
//  todoTask
//

import SwiftUI

struct TaskReflectionContext: Identifiable {
    let id = UUID()
    let goalID: UUID
    let taskID: UUID
    let taskTitle: String
    let goalTitle: String
    let accent: Color
}

struct TaskReflectionSheet: View {
    @EnvironmentObject private var store: OrbGoalStore
    @EnvironmentObject private var lang: LanguageManager
    @Environment(\.dismiss) private var dismiss

    let context: TaskReflectionContext

    @State private var note: String = ""
    @State private var prompt: TaskReflectionPrompt = .whatHappened

    private var task: GoalTask? {
        store.goal(with: context.goalID)?.tasks.first { $0.id == context.taskID }
    }

    var body: some View {
        ZStack {
            ClassicOrbitBackground(includeBackgroundImage: false)

            VStack(spacing: 0) {
                Capsule()
                    .fill(.white.opacity(0.25))
                    .frame(width: 40, height: 4)
                    .padding(.top, 10)
                    .padding(.bottom, 18)

                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(lang.t(.reflectionTitle))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.45))

                        Text(context.goalTitle)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.85))
                            .lineLimit(2)
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        Text(prompt.text(lang: lang))
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .fixedSize(horizontal: false, vertical: true)

                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $note)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 120)
                                .foregroundStyle(.white)
                                .padding(10)

                            if note.isEmpty {
                                Text(lang.t(.reflectionPlaceholder))
                                    .foregroundStyle(.white.opacity(0.32))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 18)
                                    .allowsHitTesting(false)
                            }
                        }
                        .background {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(.black.opacity(0.28))
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(.white.opacity(0.10), lineWidth: 1)
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(.white.opacity(0.05))
                            .glassEffect(.clear, in: .rect(cornerRadius: 24))
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(.white.opacity(0.10), lineWidth: 1)
                    }

                    HStack(spacing: 12) {
                        Button(lang.t(.cancel)) { dismiss() }
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white.opacity(0.55))
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(.white.opacity(0.06))
                            }

                        Button(lang.t(.save)) { save() }
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color("accent").opacity(note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.35 : 0.85))
                            }
                            .disabled(note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)

                Spacer(minLength: 0)
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
        .orbitForcedDark()
        .onAppear {
            if let task {
                note = task.reflectionNote ?? ""
                prompt = TaskReflectionPrompt.forTask(task)
            } else {
                prompt = .whatHappened
            }
        }
    }

    private func save() {
        let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        store.saveTaskReflection(
            goalID: context.goalID,
            taskID: context.taskID,
            note: trimmed,
            promptKey: prompt.rawValue
        )
        dismiss()
    }
}

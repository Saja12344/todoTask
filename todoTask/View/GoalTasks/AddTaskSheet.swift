//
//  AddTaskSheet.swift
//  todoTask
//

import SwiftUI

struct AddTaskSheet: View {
    let goalTitle: String
    let defaultUnit: String
    let onAdd: (String, Int) -> Void

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var lang: LanguageManager

    @State private var action:   String = ""
    @State private var quantity: Int    = 1
    @State private var unit:     String = ""

    private var canSave: Bool {
        !action.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !unit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        quantity > 0
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    linkedGoalBanner

                    VStack(alignment: .leading, spacing: 14) {
                        Text(lang.t(.addTaskHint))
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.55))
                            .fixedSize(horizontal: false, vertical: true)

                        GoalFormField(title: lang.t(.action)) {
                            CustomTextField(placeholder: lang.t(.phRead), text: $action)
                        }

                        GoalFormField(title: lang.t(.amountPerDay)) {
                            NumberStepper(
                                title: "",
                                value: $quantity,
                                range: 1...999,
                                suffix: unit.isEmpty ? "units" : unit,
                                allowsTyping: true
                            )
                        }

                        GoalFormField(title: lang.t(.unit)) {
                            CustomTextField(placeholder: lang.t(.phUnit), text: $unit)
                        }
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .glassEffect(.clear.tint(Color.black.opacity(0.4)), in: .rect(cornerRadius: 20))
                }
                .padding(.horizontal, GoalFlowLayout.horizontalPadding)
                .padding(.bottom, 16)
            }
            .background(Color.darkBlu.ignoresSafeArea())
            .navigationTitle(lang.t(.addDailyStep))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(lang.t(.cancel)) { dismiss() }
                        .foregroundColor(.white.opacity(0.8))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: save) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(canSave ? .cyan : .gray.opacity(0.4))
                    }
                    .disabled(!canSave)
                }
            }
            .toolbarBackground(Color.darkBlu, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .orbitForcedDark()
        .presentationSizing(.fitted)
        .presentationDragIndicator(.visible)
        .presentationBackground(Color.darkBlu)
        .onAppear {
            if unit.isEmpty, !defaultUnit.isEmpty {
                unit = defaultUnit
            }
        }
    }

    private var linkedGoalBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "link.circle.fill")
                .font(.title2)
                .foregroundColor(.cyan)
            VStack(alignment: .leading, spacing: 4) {
                Text(lang.t(.linkedToGoal))
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white.opacity(0.5))
                Text(goalTitle)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
            }
            Spacer()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.clear.tint(Color.black.opacity(0.35)), in: .rect(cornerRadius: 16))
    }

    private func save() {
        guard canSave else { return }
        onAdd(formattedTaskLabel(), quantity)
        dismiss()
    }

    private func formattedTaskLabel() -> String {
        let u = unit.trimmingCharacters(in: .whitespacesAndNewlines)
        let q = max(1, quantity)
        return u.isEmpty ? "+\(q)" : "+\(q) \(u)"
    }
}

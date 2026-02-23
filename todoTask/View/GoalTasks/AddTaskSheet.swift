//
//  AddTaskSheet.swift
//  todoTask
//

import SwiftUI

struct AddTaskSheet: View {
    let goalTitle: String
    let onAdd: (String) -> Void  // يمرر العنوان مباشرة

    @Environment(\.dismiss) private var dismiss

    @State private var action:       String = ""
    @State private var quantityText: String = ""
    @State private var unit:         String = ""

    private var quantity: Int? { Int(quantityText) }

    private var canSave: Bool {
        !action.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !unit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        (quantity ?? 0) > 0
    }

    private var taskTitle: String {
        "\(action.trimmingCharacters(in: .whitespacesAndNewlines)) \(quantityText) \(unit.trimmingCharacters(in: .whitespacesAndNewlines))"
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            LinearGradient(colors: [Color.black.opacity(0.70), Color.black.opacity(0.95)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Capsule().fill(.white.opacity(0.25)).frame(width: 48, height: 5).padding(.top, 10)

                Text(goalTitle).font(.title3.weight(.semibold)).foregroundStyle(.white)
                Text("Add an Action Required To Finish This Goal").font(.subheadline).foregroundStyle(.white.opacity(0.75))

                VStack(spacing: 14) {
                    inputRow(title: "Action",         placeholder: "e.g. read, write, run",        text: $action)
                    inputRow(title: "Total Quantity",  placeholder: "number",                       text: $quantityText)
                        .keyboardType(.numbersAndPunctuation)
                    inputRow(title: "Action Unit",    placeholder: "e.g. pages, miles, chapters",  text: $unit)
                }
                .padding(18)
                .background(.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .padding(.horizontal, 18)

                Spacer()
            }

            Button {
                guard canSave else { return }
                onAdd(taskTitle)
                dismiss()
            } label: {
                Image(systemName: "checkmark")
                    .font(.title3.weight(.semibold)).foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Circle().fill(.white.opacity(0.14)))
            }
            .padding(18)
            .disabled(!canSave)
            .opacity(canSave ? 1 : 0.4)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
    }

    private func inputRow(title: String, placeholder: String, text: Binding<String>) -> some View {
        HStack(spacing: 12) {
            Text(title).foregroundStyle(.white).frame(width: 120, alignment: .leading)
            TextField(placeholder, text: text)
                .textInputAutocapitalization(.never).autocorrectionDisabled()
                .foregroundStyle(.white).padding(.vertical, 10).padding(.horizontal, 12)
                .background(.white.opacity(0.10)).clipShape(Capsule())
        }
    }
}

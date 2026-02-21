import SwiftUI

struct WriteGoalView: View {
    // Output to parent: typed text and optional suggestion
    let onDone: (String, GoalShape?) -> Void
    let onCancel: (() -> Void)?

    @State private var goalText: String = ""

    init(
        onDone: @escaping (String, GoalShape?) -> Void,
        onCancel: (() -> Void)? = nil
    ) {
        self.onDone = onDone
        self.onCancel = onCancel
    }

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Button(action: { onCancel?() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .glassEffect(.clear.tint(Color.black.opacity(0.4)), in: Circle())
                    }

                    Spacer()

                    Button(action: submit) {
                        Image(systemName: "checkmark")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .glassEffect(.clear.tint(Color.black.opacity(0.4)), in: Circle())
                    }
                    .disabled(goalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(goalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
                }
                .padding()

                Spacer()

                VStack(spacing: 40) {
                    Text("Write a goal")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)

                    TextField(
                        "",
                        text: $goalText,
                        prompt: Text("e.g. Learn Spanish by September")
                            .foregroundColor(.white.opacity(0.4))
                    )
                    .foregroundColor(.white)
                    .font(.system(size: 17))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.3))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal, 30)
                }

                Spacer()
            }
        }
        .toolbar(.hidden, for: .tabBar)
    }

    private func submit() {
        let trimmed = goalText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let suggestion = GoalSuggestionData.suggest(for: trimmed)
        onDone(trimmed, suggestion)
    }
}

//  JoinChallengeSheet.swift
//  todoTask

import SwiftUI

struct JoinChallengeSheet: View {
    @EnvironmentObject private var userVM: UserViewModel
    let onJoined: (String) -> Void

    @State private var code = ""
    @State private var isLoading = false
    @State private var error: String?
    @Environment(\.dismiss) private var dismiss

    private let service = ChallengeService()

    var body: some View {
        ZStack {
            Color(.darkBlu).ignoresSafeArea()
            Image("Gliter").resizable().ignoresSafeArea()

            VStack(spacing: 28) {
                Capsule().fill(Color.white.opacity(0.2))
                    .frame(width: 44, height: 4).padding(.top, 16)

                Text("انضم لتحدي")
                    .font(.title2.bold()).foregroundColor(.white)

                Text("أدخل الرمز اللي أرسله لك صديقك")
                    .font(.subheadline).foregroundColor(.white.opacity(0.55))

                TextField("رمز التحدي", text: $code)
                    .textFieldStyle(.plain)
                    .font(.system(size: 20, weight: .semibold, design: .monospaced))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding()
                    .glassEffect(.clear, in: .rect(cornerRadius: 16))
                    .padding(.horizontal, 28)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.characters)

                if let error {
                    Text(error).foregroundColor(.red).font(.caption)
                }

                Button {
                    Task { await join() }
                } label: {
                    if isLoading {
                        ProgressView().tint(.white)
                            .frame(maxWidth: .infinity).frame(height: 54)
                    } else {
                        Text("انضم الآن")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity).frame(height: 54)
                    }
                }
                .background(Color.accent)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .disabled(code.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
                .padding(.horizontal, 28)

                Button("إلغاء") { dismiss() }
                    .foregroundColor(.white.opacity(0.5))

                Spacer()
            }
        }
        .colorScheme(.dark)
    }

    private func join() async {
        guard let user = userVM.currentUser else { return }
        isLoading = true
        do {
            try await service.joinRoom(
                roomId: code.trimmingCharacters(in: .whitespaces),
                userId: user.id,
                userName: user.username
            )
            onJoined(code.trimmingCharacters(in: .whitespaces))
        } catch {
            self.error = "الرمز غير صحيح أو منتهي"
        }
        isLoading = false
    }
}

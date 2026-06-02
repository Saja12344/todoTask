//  CreateChallengeSheet.swift
//  todoTask

import SwiftUI

struct CreateChallengeSheet: View {
    @EnvironmentObject private var userVM: UserViewModel
    @ObservedObject var store: OrbGoalStore
    let onCreated: (String) -> Void

    @State private var isLoading = false
    @State private var error: String?
    @Environment(\.dismiss) private var dismiss

    private let service = ChallengeService()

    private var bestGoal: OrbGoal? {
        store.goals.first
    }

    var body: some View {
        ZStack {
            Color(.darkBlu).ignoresSafeArea()
            Image("Gliter").resizable().ignoresSafeArea()

            VStack(spacing: 28) {
                Capsule().fill(Color.white.opacity(0.2))
                    .frame(width: 44, height: 4).padding(.top, 16)

                Text("تحدي جديد")
                    .font(.title2.bold()).foregroundColor(.white)

                if let goal = bestGoal {
                    PlanetOrbView(
                        size: 140,
                        gradientColors: goal.design.gradientStops.map {
                            Color(red: Double($0.r), green: Double($0.g), blue: Double($0.b))
                        },
                        glow: goal.design.glow,
                        textureAssetName: goal.design.textureAssetName ?? "",
                        textureOpacity: goal.design.textureOpacity
                    )
                    Text("سيُتنافَس على هذا الكوكب")
                        .font(.caption).foregroundColor(.white.opacity(0.5))
                }

                if let error {
                    Text(error).foregroundColor(.red).font(.caption)
                }

                VStack(spacing: 14) {
                    Button {
                        Task { await create() }
                    } label: {
                        if isLoading {
                            ProgressView().tint(.white)
                                .frame(maxWidth: .infinity).frame(height: 54)
                        } else {
                            Text("إنشاء وإرسال رمز لصديقك")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity).frame(height: 54)
                        }
                    }
                    .background(Color.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .disabled(isLoading)

                    Button("إلغاء") { dismiss() }
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.horizontal, 28)

                Spacer()
            }
        }
        .colorScheme(.dark)
    }

    private func create() async {
        guard let user = userVM.currentUser else {
            error = "يجب تسجيل الدخول أولاً"
            return
        }

        guard let goal = bestGoal else {
            error = "لازم يكون عندك هدف واحد على الأقل"
            return
        }

        isLoading = true
        error = nil

        do {
            let roomId = try await service.createRoom(
                userId: user.id,
                userName: user.username,
                orbDesign: goal.design,
                orbTasks: store.goals
            )
            onCreated(roomId)
        } catch {
            self.error = "حدث خطأ، حاول مجدداً"
        }
        isLoading = false
    }
}

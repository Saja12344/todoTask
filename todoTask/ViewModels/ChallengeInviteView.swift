//
//  ChallengeInviteView.swift
//  todoTask
//
//  Created by شهد عبدالله القحطاني on 12/09/1447 AH.
//


//
//  ChallengeInviteView.swift
//  todoTask
//

import SwiftUI

// MARK: - شاشة القبول لما تفتح صديقتك الرابط
struct ChallengeInviteView: View {
    let challengeID: String
    let fromUsername: String

    @EnvironmentObject private var store: OrbGoalStore
    @StateObject private var challengeVM = ChallengeViewModel()
    @Environment(\.dismiss) private var dismiss

    @State private var isLoading = false
    @State private var accepted  = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [.darkBlu, .dark], startPoint: .bottom, endPoint: .top)
                .ignoresSafeArea()
            Image("Gliter").resizable().ignoresSafeArea()

            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 100, height: 100)
                    Image(systemName: "bolt.fill").font(.largeTitle).foregroundColor(.white)
                }

                Text("\(fromUsername) is challenging you! ⚡️")
                    .font(.title2.bold()).foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text("Accept the challenge and compete to complete the goal first. Winner takes the planet! 🪐")
                    .font(.subheadline).foregroundColor(.gray)
                    .multilineTextAlignment(.center).padding(.horizontal, 20)

                if accepted {
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.largeTitle).foregroundColor(.green)
                        Text("Challenge Accepted!")
                            .font(.headline.bold()).foregroundColor(.white)
                        Text("The goal has been added to your Goals page.")
                            .font(.caption).foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        Button {
                            dismiss()
                        } label: {
                            Text("Let's Go! 🚀").bold().foregroundColor(.white)
                                .frame(maxWidth: .infinity).padding(.vertical, 14)
                                .glassEffect(.regular.tint(.green.opacity(0.3)), in: .capsule)
                        }
                        .buttonStyle(.plain).padding(.horizontal, 20)
                    }
                } else {
                    HStack(spacing: 16) {
                        Button {
                            dismiss()
                        } label: {
                            Text("Decline")
                                .foregroundColor(.gray).frame(maxWidth: .infinity).padding(.vertical, 14)
                                .glassEffect(.regular.tint(.white.opacity(0.05)), in: .capsule)
                        }
                        .buttonStyle(.plain)

                        Button {
                            Task { await acceptChallenge() }
                        } label: {
                            HStack {
                                if isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Image(systemName: "bolt.fill")
                                    Text("Accept!").bold()
                                }
                            }
                            .foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 14)
                            .glassEffect(.regular.tint(.purple.opacity(0.4)), in: .capsule)
                        }
                        .buttonStyle(.plain)
                        .disabled(isLoading)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(30)
        }
        .colorScheme(.dark)
    }

    private func acceptChallenge() async {
        isLoading = true

        let newGoal = OrbGoal(
            id: UUID(),
            title: "Challenge from \(fromUsername)",
            design: OrbDesign(
                glow: 0.12,
                textureOpacity: 0.85,
                textureAssetName: "effect1",
                gradientStops: [
                    RGBAColor(r: 0.6, g: 0.2, b: 0.9, a: 1),
                    RGBAColor(r: 0.3, g: 0.1, b: 0.8, a: 1)
                ]
            ),
            challengeInfo: ChallengeInfo(
                challengeID: challengeID,
                opponentID: "opponent",
                opponentName: fromUsername,
                friendProgress: 0,
                isWinner: false,
                winnerID: nil
            )
        )

        store.add(newGoal)

        await MainActor.run {
            isLoading = false
            accepted  = true
        }
    }
}
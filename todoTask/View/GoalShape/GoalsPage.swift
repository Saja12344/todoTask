//
//  GoalsPage.swift
//  todoTask
//
//  Created by Ruba Alghamdi on 27/08/1447 AH.
//

import SwiftUI

struct GoalsPage: View {
    @EnvironmentObject private var store: OrbGoalStore
    @State private var showCreateGoal = false

    @State private var showDeleteConfirm = false
    @State private var goalPendingDelete: OrbGoal?

    private let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 170), spacing: 16)
    ]

    var body: some View {
        ZStack {
            // Background (نفس جوّك)
            Rectangle()
                .fill(LinearGradient(colors: [.color, .dark], startPoint: .bottom, endPoint: .top))
                .ignoresSafeArea()

            Image("Background 4")
                .resizable()
                .ignoresSafeArea()
                .opacity(0.35)

            Image("Gliter")
                .resizable()
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {

                    Text("Your Orbs")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(store.goals) { goal in
                            NavigationLink {
                                // Pass the tapped planet's id to the tasks view
                                GoalTasksView(goalID: goal.id)
                            } label: {
                                GoalGridCard(goal: goal)
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button(role: .destructive) {
                                    goalPendingDelete = goal
                                    showDeleteConfirm = true
                                } label: {
                                    Label("Delete Orb", systemImage: "trash")
                                }
                            }
                            .onLongPressGesture(minimumDuration: 0.6) {
                                goalPendingDelete = goal
                                showDeleteConfirm = true
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    Spacer().frame(height: 30)
                }
            }

        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showCreateGoal = true } label: { Image(systemName: "plus") }
                    .foregroundStyle(.white)
            }
        }
        .sheet(isPresented: $showCreateGoal) {
            GoalDesign()
                .environmentObject(store)
                .preferredColorScheme(.dark)
        }
        .confirmationDialog(
            "Delete this orb?",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let g = goalPendingDelete {
                    store.delete(goalID: g.id)
                }
                goalPendingDelete = nil
            }
            Button("Cancel", role: .cancel) {
                goalPendingDelete = nil
            }
        } message: {
            Text("This will remove the orb and its progress.")
        }
        .colorScheme(.dark)
    }
}

private struct GoalGridCard: View {
    let goal: OrbGoal
    @State private var anim: Double = 0

    private var progressPercentText: String {
        let p = Int(round(goal.progress * 100))
        return "\(p)%"
    }

    var body: some View {
        // Keep float gentle so overlap doesn’t feel jumpy
        let float = CGFloat(sin(anim) * 1.4)

        VStack(spacing: 4) {
            // Orb area (no background panel here)
            PlanetOrbView(
                size: 72,
                gradientColors: goal.design.gradientStops.map { $0.swiftUIColor },
                glow: min(goal.design.glow, 0.12),
                textureAssetName: goal.design.textureAssetName,
                textureOpacity: goal.design.textureOpacity
            )
            // Sit the orb closer to the info box
            .offset(y: float - 2)
            .onAppear {
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    anim = 2 * .pi
                }
            }

            // Info area (keep the box)
            VStack(alignment: .leading, spacing: 8) {
                Text(goal.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .truncationMode(.tail)

                HStack(spacing: 8) {
                    ProgressView(value: goal.progress)
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                        .scaleEffect(x: 1, y: 0.9, anchor: .center)

                    Text(progressPercentText)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.9))
                        .frame(minWidth: 34, alignment: .trailing)
                }

                Text("\(goal.doneTasks)/\(goal.totalTasks) tasks")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.75))
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(.black.opacity(0.28))
            )
            // Move info box up
            .offset(y: -65)
        }
        .padding(12)
        .frame(width: 180, height: 208)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(.white.opacity(0.12), lineWidth: 1)
                )
        )
        .contentShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.22), radius: 8, x: 0, y: 5)
    }
}

private struct FloatingPlanetNode: View {
    let goal: OrbGoal
    let spec: FloatingSpec
    let now: Date

    var body: some View {
        let t = now.timeIntervalSinceReferenceDate
        let dx = CGFloat(sin(t * spec.speed + spec.phase)) * spec.amplitude.width
        let dy = CGFloat(cos(t * (spec.speed * 0.9) + spec.phase)) * spec.amplitude.height

        let opacity = 0.18 + 0.82 * goal.progress // ✅ progress controls opacity
        let size = spec.size

        PlanetOrbView(
            size: size,
            gradientColors: goal.design.gradientStops.map { $0.swiftUIColor },
            glow: goal.design.glow,
            textureAssetName: goal.design.textureAssetName,
            textureOpacity: goal.design.textureOpacity
        )
        .opacity(opacity)
        .position(x: spec.base.x + dx, y: spec.base.y + dy)
    }
}

struct FloatingSpec: Equatable {
    let base: CGPoint
    let size: CGFloat
    let amplitude: CGSize
    let speed: Double
    let phase: Double

    static func random(in canvas: CGSize) -> FloatingSpec {
        let top: CGFloat = 90
        let bottom: CGFloat = 70
        let side: CGFloat = 40

        let x = CGFloat.random(in: side...(max(side, canvas.width - side)))
        let y = CGFloat.random(in: top...(max(top, canvas.height - bottom)))

        return FloatingSpec(
            base: CGPoint(x: x, y: y),
            size: CGFloat.random(in: 90...140),
            amplitude: CGSize(width: .random(in: 10...35), height: .random(in: 10...42)),
            speed: Double.random(in: 0.35...0.75),
            phase: Double.random(in: 0...(Double.pi * 2))
        )
    }

    static func defaultSpec(in canvas: CGSize) -> FloatingSpec {
        FloatingSpec(
            base: CGPoint(x: canvas.width * 0.5, y: canvas.height * 0.4),
            size: 120,
            amplitude: CGSize(width: 20, height: 25),
            speed: 0.5,
            phase: 0
        )
    }
}

#Preview{
    let store = OrbGoalStore()
    if store.goals.isEmpty { store.add(.mock) }
    return NavigationStack {
        
        GoalsPage()
            .environmentObject(store)
            .preferredColorScheme(.dark)
    }
}


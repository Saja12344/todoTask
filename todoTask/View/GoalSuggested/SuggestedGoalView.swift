//
//  SuggestedGoalView.swift
//  todoTask
//

import SwiftUI

struct SuggestedGoalView: View {
    let goalText: String
    let suggestedType: GoalType?
    let onContinue: (GoalShapeOption) -> Void
    let onBack: () -> Void

    @EnvironmentObject private var lang: LanguageManager
    @State private var selectedOption: GoalShapeOption?
    @State private var showPicker = false
    @State private var scanning = true
    @State private var contentRevealed = false

    private var resolvedOption: GoalShapeOption? {
        if let selectedOption { return selectedOption }
        if let suggestedType { return GoalShapeOption.defaultFor(suggestedType) }
        return nil
    }

    var body: some View {
        GoalFlowScreen(
            background: { AppBackground() },
            topBar: {
                HStack {
                    GoalFlowBackButton(action: onBack)
                    Spacer()
                    if resolvedOption != nil {
                        GoalFlowNextButton(action: continueTapped)
                    } else {
                        GoalFlowNextButton(action: {})
                            .opacity(0.35)
                            .allowsHitTesting(false)
                    }
                }
            },
            content: {
                GeometryReader { geo in
                    if showPicker {
                        pickerContent(height: geo.size.height)
                    } else {
                        suggestContent(height: geo.size.height)
                    }
                }
            }
        )
        .onAppear {
            if let suggestedType {
                selectedOption = GoalShapeOption.defaultFor(suggestedType)
            }
            startReveal()
        }
    }

    private func startReveal() {
        scanning = true
        contentRevealed = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.78)) {
                scanning = false
                contentRevealed = true
            }
        }
    }

    @ViewBuilder
    private func suggestContent(height: CGFloat) -> some View {
        VStack(spacing: 0) {
            Spacer(minLength: height * 0.1)

            ZStack {
                SuggestedShapeArtwork()
                    .frame(height: 320)

                if scanning {
                    VStack(spacing: 16) {
                        ProgressView()
                            .tint(Color("accent"))
                        Text(lang.t(.suggestTypeScanning))
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                } else if let option = resolvedOption {
                    VStack(spacing: 14) {
                        Text(lang.t(.suggestShapeIntro))
                            .font(.system(size: 17, weight: .regular))
                            .foregroundStyle(.white.opacity(0.82))
                            .multilineTextAlignment(.center)

                        Text(option.title(lang))
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .minimumScaleFactor(0.75)

                        Text(option.description(lang))
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(.white.opacity(0.55))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)

                        Button {
                            withAnimation(.spring(response: 0.32)) { showPicker = true }
                        } label: {
                            Text(lang.t(.chooseDifferentType))
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.88))
                                .padding(.horizontal, 28)
                                .padding(.vertical, 12)
                                .background {
                                    Capsule()
                                        .fill(.white.opacity(0.08))
                                        .glassEffect(.clear, in: .capsule)
                                }
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 32)
                    .opacity(contentRevealed ? 1 : 0)
                    .scaleEffect(contentRevealed ? 1 : 0.94)
                } else {
                    Text(lang.t(.noMatchTitle))
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.7))
                        .onAppear { showPicker = true }
                }
            }
            .frame(maxWidth: .infinity)

            Spacer(minLength: height * 0.14)
        }
    }

    @ViewBuilder
    private func pickerContent(height: CGFloat) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                Text(lang.t(.selectGoalShape))
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)

                GoalShapeGrid(selectedID: selectedOption?.id) { option in
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                        selectedOption = option
                        showPicker = false
                    }
                }

                Button {
                    withAnimation(.spring(response: 0.32)) { showPicker = false }
                } label: {
                    Text(lang.t(.hideTypes))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
            .padding(.horizontal, 4)
            .frame(minHeight: height, alignment: .top)
            .padding(.bottom, 24)
        }
    }

    private func continueTapped() {
        guard let option = resolvedOption else { return }
        onContinue(option)
    }
}

// MARK: - Figma "Background 2" fluid artwork
private struct SuggestedShapeArtwork: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                RadialGradient(
                    colors: [Color("accent").opacity(0.20), .clear],
                    center: .center,
                    startRadius: 10,
                    endRadius: geo.size.width * 0.75
                )
                .blur(radius: 20)

                Image("Background 2")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .opacity(0.95)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .mask(
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0.0),
                        .init(color: .black, location: 0.28),
                        .init(color: .black, location: 0.72),
                        .init(color: .clear, location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .mask(
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0.0),
                            .init(color: .black, location: 0.12),
                            .init(color: .black, location: 0.88),
                            .init(color: .clear, location: 1.0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            )
        }
        .allowsHitTesting(false)
    }
}

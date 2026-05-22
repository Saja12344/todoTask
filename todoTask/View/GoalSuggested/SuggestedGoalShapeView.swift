////
////  SuggestedGoalShapeView.swift
////  todoTask
////
//
//import SwiftUI
//
//struct SuggestedGoalShapeView: View {
//    let goalText: String
//    let suggestedShape: GoalShape
//    let onFinish: (GoalType) -> Void  // ✅ يروح للديزاين مباشرة
//    let onChangeShape: () -> Void
//    let onBack: (() -> Void)?
//
//    private let goalTypes: [(GoalType, String, String)] = [
//        (.reachTarget, "scope",                     "Reach a Target"),
//        (.buildHabit,  "flame.fill",                "Build a Habit"),
//        (.levelUp,     "chart.line.uptrend.xyaxis", "Level Up"),
//        (.reduce,      "arrow.down.circle",         "Reduce")
//    ]
//
//    private var suggestedType: GoalType {
//        convertToGoalType(suggestedShape)
//    }
//
//    @State private var selectedType: GoalType? = nil
//    @State private var showPicker = false
//
//    var body: some View {
//        ZStack {
//            AppBackground()
//            Image("Background 2").scaledToFill().ignoresSafeArea()
//
//            VStack(spacing: 0) {
//                HStack {
//                    Button(action: { onBack?() }) {
//                        Image(systemName: "chevron.left")
//                            .font(.title2).foregroundColor(.white)
//                            .frame(width: 50, height: 50)
//                            .glassEffect(.clear.tint(Color.black.opacity(0.4)), in: Circle())
//                    }
//                    Spacer()
//                    // ✅ يروح للديزاين مباشرة
//                    Button(action: {
//                        onFinish(selectedType ?? suggestedType)
//                    }) {
//                        Image(systemName: "checkmark")
//                            .font(.title2).foregroundColor(.white)
//                            .frame(width: 50, height: 50)
//                            .glassEffect(.clear.tint(Color.black.opacity(0.4)), in: Circle())
//                    }
//                }
//                .padding(.top, 60)
//                .padding(.horizontal, 20)
//
//                Spacer()
//
//                VStack(spacing: 20) {
//                    Text(goalText)
//                        .font(.system(size: 20, weight: .medium))
//                        .foregroundColor(.white)
//                        .multilineTextAlignment(.center)
//                        .padding(.horizontal, 40)
//
//                    if !showPicker {
//                        // عرض النوع الحالي
//                        VStack(spacing: 12) {
//                            Text("your suggested goal shape is")
//                                .font(.system(size: 16))
//                                .foregroundColor(.white.opacity(0.8))
//
//                            HStack(spacing: 10) {
//                                let current = selectedType ?? suggestedType
//                                let info = goalTypes.first(where: { $0.0 == current })
//                                Image(systemName: info?.1 ?? "scope")
//                                    .font(.system(size: 28))
//                                    .foregroundColor(.white)
//                                Text(info?.2 ?? "")
//                                    .font(.system(size: 28, weight: .bold))
//                                    .foregroundColor(.white)
//                            }
//
//                            Text(GoalSuggestionData.getDescription(suggestedShape))
//                                .font(.system(size: 14))
//                                .foregroundColor(.white.opacity(0.7))
//                                .multilineTextAlignment(.center)
//                                .padding(.horizontal, 20)
//                        }
//                    } else {
//                        // ✅ 4 أنواع فقط
//                        VStack(spacing: 12) {
//                            Text("Choose a goal type")
//                                .font(.system(size: 18, weight: .semibold))
//                                .foregroundColor(.white)
//
//                            LazyVGrid(
//                                columns: [GridItem(.flexible()), GridItem(.flexible())],
//                                spacing: 12
//                            ) {
//                                ForEach(goalTypes, id: \.0) { type, icon, name in
//                                    Button {
//                                        selectedType = type
//                                        withAnimation { showPicker = false }
//                                    } label: {
//                                        VStack(spacing: 8) {
//                                            Image(systemName: icon)
//                                                .font(.system(size: 30))
//                                                .foregroundColor(.white)
//                                            Text(name)
//                                                .font(.system(size: 14, weight: .semibold))
//                                                .foregroundColor(.white)
//                                                .multilineTextAlignment(.center)
//                                        }
//                                        .frame(maxWidth: .infinity)
//                                        .frame(height: 100)
//                                        .glassEffect(
//                                            .clear.tint(Color.black.opacity((selectedType ?? suggestedType) == type ? 0.5 : 0.3)),
//                                            in: .rect(cornerRadius: 20)
//                                        )
//                                        .overlay(
//                                            RoundedRectangle(cornerRadius: 20)
//                                                .stroke(
//                                                    (selectedType ?? suggestedType) == type ? Color.white.opacity(0.8) : Color.clear,
//                                                    lineWidth: 2
//                                                )
//                                        )
//                                    }
//                                }
//                            }
//                            .padding(.horizontal, 20)
//                        }
//                    }
//                }
//                .padding(.bottom, 40)
//
//                Spacer()
//
//                // ✅ Change يفتح الـ 4 أنواع
//                Button(action: {
//                    withAnimation { showPicker.toggle() }
//                }) {
//                    Text(showPicker ? "Cancel" : "Change")
//                        .font(.system(size: 17, weight: .medium))
//                        .foregroundColor(.white)
//                        .frame(width: 200, height: 50)
//                        .glassEffect(.clear.tint(Color.black.opacity(0.4)), in: .rect(cornerRadius: 25))
//                }
//                .padding(.bottom, 50)
//            }
//        }
//        .toolbar(.hidden, for: .tabBar)
//        .onAppear {
//            selectedType = suggestedType
//        }
//    }
//}
//
//// ✅ 4 cases فقط
//func convertToGoalType(_ shape: GoalShape) -> GoalType {
//    switch shape {
//    case .finishTotal:        return .reachTarget
//    case .repeatOnSchedule:   return .buildHabit
//    case .buildStreak:        return .buildHabit
//    case .levelUpGradually:   return .levelUp
//    case .finishByMilestones: return .reachTarget
//    case .reduceSomething:    return .reduce
//    }
//}

import SwiftUI

struct WriteGoalView: View {
    
    @State private var goalText: String = ""
    @State private var suggestedShape: GoalShape? = nil
    
    @State private var showSuggestion = false
    @State private var showManualSelection = false
    
    var body: some View {
        ZStack {
            AppBackground()
            
            VStack(spacing: 0) {
                
                // Top bar
                HStack {
                    Button(action: {}) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .glassEffect(.clear.tint(Color.black.opacity(0.4)), in: Circle())
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        analyzeSuggestion()
                    }) {
                        Image(systemName: "checkmark")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .glassEffect(.clear.tint(Color.black.opacity(0.4)), in: Circle())
                    }
                    .disabled(goalText.isEmpty)
                    .opacity(goalText.isEmpty ? 0.5 : 1)
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
        
        // ✅ suggestion screen
        .fullScreenCover(isPresented: $showSuggestion) {
            SuggestedGoalShapeView(
                goalText: goalText,
                suggestedShape: suggestedShape ?? .finishTotal,
                convertedGoalType: convertToGoalType(suggestedShape ?? .finishTotal),
                onAccept: {
                    showSuggestion = false
                },
                onChangeShape: {
                    showSuggestion = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showManualSelection = true
                    }
                }
            )
        }
        
        // ✅ manual selection
        .fullScreenCover(isPresented: $showManualSelection) {
            GoalShapeView()
        }
    }
    
    // تحليل الهدف
    private func analyzeSuggestion() {
        if let shape = GoalSuggestionData.suggest(for: goalText) {
            suggestedShape = shape
            showSuggestion = true
        } else {
            showManualSelection = true
        }
    }
}

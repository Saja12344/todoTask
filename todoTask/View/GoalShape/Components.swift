import SwiftUI

struct GoalCard: View {
    let icon: String
    let title: String
    let description: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 50))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(description)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: 160)
            .background(Color.clear)
            .glassEffect(
                .clear.tint(Color.black.opacity(isSelected ? 0.5 : 0.4)),
                in: .rect(cornerRadius: 24)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(
                        isSelected ? Color.white.opacity(0.8) : Color.white.opacity(0.3),
                        lineWidth: isSelected ? 2 : 0
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
    }
}

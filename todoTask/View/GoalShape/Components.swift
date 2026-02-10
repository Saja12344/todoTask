//
//  Components.swift
//  todoTask
//
//  Created by شهد عبدالله القحطاني on 22/08/1447 AH.
//

import SwiftUI

// Goal Card Component
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
                .clear,
                in: .rect(cornerRadius: 16)
            )
        
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.black.opacity(0.58)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .blendMode(.overlay)
                    .allowsHitTesting(false)
            )

            
        }
        
    }
}

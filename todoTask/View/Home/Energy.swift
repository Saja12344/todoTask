//
//  Energy.swift
//  todoTask
//
//  Created by Jana Abdulaziz Malibari on 13/02/2026.
//

import SwiftUI


struct Energy: View {
    @State private var isPressed: Bool = false
    @State private var selectedEnergy = 0
    
    @State private var todayEnergy: [Energytoday] = [
        Energytoday(title: "Chill",
                   value: "1",
                   icon: "figure.mind.and.body"),
        Energytoday(title: "Average",
                   value: "2",
                   icon: "figure.mixed.cardio"),
        Energytoday(title: "Hardcore",
                   value: "3",
                   icon: "figure.strengthtraining.traditional")]
    var body: some View {
        NavigationStack {
            ZStack {
                Rectangle()
                    .fill(LinearGradient(colors: [.color, .dark], startPoint: .bottom, endPoint: .top))
                    .ignoresSafeArea()
                Image("Background 4")
                    .resizable()
                    .ignoresSafeArea()
                    .opacity(0.4)
                Image("Gliter")
                    .resizable()
                    .ignoresSafeArea()
                
                VStack(spacing: 20){
                    ForEach(todayEnergy){level in
                        Button(action: {print("Works")}){
                            VStack(spacing: 20){
                                Image(systemName: level.icon)
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                                Text(level.title)
                                    .foregroundColor(.white)
                                    .font(.system(size: 24))
                            }
                        }
                        .frame(width: 340, height: 160)
                        .glassEffect(.clear.interactive(), in: .rect(cornerRadius: 30))
                    }
                }
                
                .onTapGesture {
                    isPressed = true
                }
                .padding(.bottom, 50)
            }
            .navigationTitle("Today's Energy")
        }
        .colorScheme(.dark)
    }
}

#Preview {
    Energy()
}

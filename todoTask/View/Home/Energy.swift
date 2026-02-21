//
//  Energy.swift
//  todoTask
//
//  Created by Jana Abdulaziz Malibari on 13/02/2026.
//

import SwiftUI

struct Energy: View {
    @StateObject private var energyVM = DailyEnergyViewModel()
    @State private var selectedEnergyID: String? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                Rectangle()
                    .fill(LinearGradient(colors: [.darkBlu, .dark], startPoint: .bottom, endPoint: .top))
                    .ignoresSafeArea()
                Image("Background 4")
                    .resizable()
                    .ignoresSafeArea()
                    .opacity(0.4)
                Image("Gliter")
                    .resizable()
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    ForEach(Energytoday.defaults) { level in
                        Button {
                            Task {
                                await energyVM.setEnergyForToday(level)
                                await MainActor.run {
                                    selectedEnergyID = level.id.uuidString
                                    print("Selected energy level: \(level.title)")
                                }
                            }
                        } label: {
                            VStack(spacing: 20) {
                                Image(systemName: level.icon)
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                                Text(level.title)
                                    .foregroundColor(.white)
                                    .font(.system(size: 24))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 160)
                            .background(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(
                                        selectedEnergyID == level.id.uuidString ? Color.accent : Color.clear,
                                        lineWidth: 2
                                    )
                            )
                        }
                        .frame(width: 340, height: 160)
                        .glassEffect(.clear.interactive(), in: .rect(cornerRadius: 30))
                    }
                    
                    // Selected label
                    if let selectedID = selectedEnergyID,
                       let selected = Energytoday.defaults.first(where: { $0.id.uuidString == selectedID }) {
                        Text("Selected: \(selected.title)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.top, 4)
                    } else if let entry = energyVM.todayEntry {
                        Text("Selected: \(entry.title)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.top, 4)
                    } else {
                        Text("Tap to set your energy for today")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.top, 4)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 50)
            }
            .navigationTitle("Today's Energy")
        }
        .colorScheme(.dark)
        .onAppear {
            energyVM.refreshToday()
            if let entry = energyVM.todayEntry {
                selectedEnergyID = Energytoday.defaults.first(where: { $0.title == entry.title })?.id.uuidString
            }
        }
    }
}

#Preview {
    Energy()
}

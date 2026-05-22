//
//  Energy.swift
//  todoTask
//

import SwiftUI

struct Energy: View {
    @EnvironmentObject private var lang: LanguageManager
    @StateObject private var energyVM = DailyEnergyViewModel()
    @State private var selectedEnergyID: String? = nil

    private var levels: [Energytoday] { lang.energyLevels() }

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
                    ForEach(levels) { level in
                        Button {
                            Task {
                                await energyVM.setEnergyForToday(level)
                                await MainActor.run {
                                    selectedEnergyID = level.id.uuidString
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

                    if let selectedID = selectedEnergyID,
                       let selected = levels.first(where: { $0.id.uuidString == selectedID }) {
                        Text(String(format: lang.t(.energySelectedFormat), selected.title))
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.top, 4)
                    } else if let entry = energyVM.todayEntry {
                        Text(String(format: lang.t(.energySelectedFormat),
                                    lang.localizedEnergyTitle(value: entry.value, fallback: entry.title)))
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.top, 4)
                    } else {
                        Text(lang.t(.energyPrompt))
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.top, 4)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 50)
            }
            .navigationTitle(lang.t(.energySettings))
        }
        .colorScheme(.dark)
        .onAppear {
            energyVM.refreshToday()
            if let entry = energyVM.todayEntry {
                selectedEnergyID = levels.first(where: { $0.value == entry.value })?.id.uuidString
            }
        }
    }
}

#Preview {
    Energy()
        .environmentObject(LanguageManager())
}

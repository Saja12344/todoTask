//
//  Components.swift
//  todoTask
//
//  Created by شهد عبدالله القحطاني on 22/08/1447 AH.
//


import SwiftUI

struct FinishTotalView: View {
    @State private var targetNumber: Int = 100
    @State private var unit: String = ""
    @State private var deadlineDate = Date()
    @State private var selectedDays: Set<Int> = []
    @State private var startTime1 = Date()
    @State private var endTime1 = Date()
    @State private var startTime2 = Date()
    @State private var endTime2 = Date()
    
    var body: some View {
        ZStack {
            // Background
            AppBackground()
            
            VStack(spacing: 77) {
                // Navigation
                AppNavigationBar(
                    title: "Finish a Total",
                    onBack: {},
                    onNext: {}
                )
                
                // Content
                ScrollView {
                    VStack(spacing: 16) {
                        // One Big Glass Card
                        GlassCard {
                            VStack(spacing: 20) {
                                // Target Number
                                VStack(alignment: .leading, spacing: 8) {
                                    SectionHeader(title: "Target Number:")
                                    NumberStepper(
                                        title: "",
                                        value: $targetNumber,
                                        range: 1...1000,
                                        suffix: ""
                                    )
                                }
                                
                                // Unit
                                VStack(alignment: .leading, spacing: 11) {
                                    SectionHeader(title: "Unit:")
                                    CustomTextField(
                                        placeholder: "eg. Inches, Bottles, Cats",
                                        text: $unit
                                    )
                                    
                                        .foregroundColor(.white.opacity(0.5))
                                        .font(.system(size: 15))
                                }
                                
                                // Deadline Date
                                VStack(alignment: .leading, spacing: 8) {
                                    GlassDatePicker(
                                        title: "Deadline Date:",
                                        date: $deadlineDate
                                    )
                                }
                                
                                // Days a Week
                                VStack(alignment: .leading, spacing: 8) {
                                    SectionHeader(title: "Days a Week:")
                                    WeekDaysSelector(selectedDays: $selectedDays)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

#Preview {
    FinishTotalView()
}

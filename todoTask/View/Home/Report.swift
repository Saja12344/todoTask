//
//  Report.swift
//  todoTask
//
//  Created by Jana Abdulaziz Malibari on 11/02/2026.
//

import SwiftUI
import Combine



struct Report: View {
    @State private var reportCards: [ReportCard] = [
        ReportCard(title: "Total Goals",
                   value: "5",
                   icon: "target"),
        
        ReportCard(title: "Goals Completed",
                   value: "3",
                   icon: "checkmark.seal.fill"),
        
        ReportCard(title: "Total Planets",
                   value: "2",
                   icon: "globe.americas.fill"),
        
        ReportCard(title: "Over Deadline",
                   value: "0",
                   icon: "calendar.badge.exclamationmark")
    ]

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
                
                VStack(spacing: 10){
                    Text("Progress Report")
                        .font(Font.largeTitle.bold())
                        .foregroundColor(.white)
                        .padding(.leading,-80)
                    
                    Color.clear
                    TabView{
                        ForEach(reportCards) { card in
                            ZStack {
                                HStack {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 30)
                                            .fill(Color.white.opacity(0.2))
                                        
                                        Image(systemName: card.icon)
                                            .font(.system(size: 40))
                                            .foregroundColor(.white)
                                    }
                                    .frame(width: 175)
                                    
                                    VStack(alignment: .leading) {
                                        Text(card.value)
                                            .font(.system(size: 50, weight: .bold))
                                            .foregroundColor(.white)
                                        
                                        Text(card.title)
                                            .font(.title3)
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    .padding()
                                    
                                    Spacer()
                                }
                                .glassEffect(.clear, in: .rect (cornerRadius: 30))
                            }
                            .frame(width:350, height: 160)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .automatic))
                    .padding(.all, -100)
                    
                        ZStack {
                            Rectangle()
                                .frame(width: 340, height: 200)
                                .cornerRadius(20)
                                .foregroundColor(Color.clear)
                            
                            VStack {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .frame(width: 340, height: 45)
                                        .foregroundColor(Color.white.opacity(0.2))
                                    
                                    Text("Consistency")
                                        .font(.system(size: 14, weight: .semibold, design: .default))
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.bottom, 155)
                        }
                        .glassEffect(.clear, in: .rect(cornerRadius: 20))
                        .padding(.top, 80)
                        
                        ZStack {
                            Rectangle()
                                .frame(width: 340, height: 200)
                                .cornerRadius(20)
                                .foregroundColor(Color.clear)
                            
                            VStack {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .frame(width: 340, height: 45)
                                        .foregroundColor(Color.white.opacity(0.2))
                                    
                                    Text("Energy Over Time")
                                        .font(.system(size: 14, weight: .semibold, design: .default))
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.bottom, 155)
                        }
                        .glassEffect(.clear, in: .rect(cornerRadius: 20))
                    }
                .padding(.bottom, 20)
            }
        }
    }
}

#Preview {
    Report()
}

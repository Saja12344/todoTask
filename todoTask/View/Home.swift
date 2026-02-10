//
//  Home.swift
//  OrbitDemo
//
//  Created by Jana Abdulaziz Malibari on 07/02/2026.
//

import SwiftUI

struct Home: View {
    var body: some View {
        ZStack {
            Group {
                if #available(iOS 26.2, *) {
                    NativeTabView()
                } else {
                    NativeTabView()
                }
            }
        }
    }
}

@ViewBuilder
func NativeTabView() -> some View {
    TabView{
        Tab.init("Today", systemImage: "checklist"){
            NavigationStack{
                today()
            }
            .navigationBarBackButtonHidden(true)
            
        }
        Tab.init("Friends", systemImage: "person.2.fill"){
            NavigationStack{
                List{
                    
                }
                .navigationTitle("Friends List")
            }
            .navigationBarBackButtonHidden(true)
            
        }
        Tab.init("Goals", systemImage: "target"){
            NavigationStack{
                Goals()
            }
            .navigationBarBackButtonHidden(true)
            
        }
        Tab.init("Settings", systemImage: "gear"){
            NavigationStack{
                Settings()
            }
            .navigationBarBackButtonHidden(true)
            
        }
    }
    .accentColor(.accent)
    
}

struct today: View {
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var vm = MiniCalendarViewModel()
    var body: some View {
        
        
        ZStack{
            Rectangle()
                .fill(LinearGradient(colors: [.color, .dark], startPoint: .bottom, endPoint: .top))
                .ignoresSafeArea()
            Image("Background 1")
                .resizable()
                .ignoresSafeArea()
            Image("Gliter")
                .resizable()
                .ignoresSafeArea()
            
            VStack(alignment: .leading){
                Text(viewModel.formattedDate)
                    .foregroundColor(.primary)
                    .font(.largeTitle)
                    .bold()
                    .padding(.leading, 20)
                
                
                Text("THIS IS AN INSPIRING QOUTE.")
                    .padding(.leading, 20)
                
                ZStack {
                    Rectangle()
                        .frame(width: 385, height: 134)
                        .foregroundColor(.clear)
                        .glassEffect(.regular, in: .rect(cornerRadius: 10))
                    
                    VStack(alignment: .leading ,spacing: 20) {
                        
                        Menu {
                            ForEach(vm.availableMonths, id: \.self) { month in
                                Button {
                                    vm.changeMonth(to: month)
                                } label: {
                                    Text(month, format: .dateTime.month(.wide))
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Text(vm.monthTitle)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.leading)

                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                        }
                        HStack(spacing: 5) {

                            Button {
                                vm.moveWeek(by: -1)
                            } label: {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.white)
                            }

                            ForEach(vm.visibleWeek, id: \.self) { date in
                                DayView(
                                    date: date,
                                    selectedDate: vm.selectedDate,
                                    today: vm.today
                                )
                                .onTapGesture {
                                    vm.selectedDate = date
                                }
                            }

                            Button {
                                vm.moveWeek(by: 1)
                            } label: {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .padding(.leading, 8.7)
                
                Text("Today's Tasks")
                    .foregroundColor(.primary)
                    .font(.largeTitle)
                    .bold()
                    .padding(.leading, 20)
                ZStack{
                    
                    List{
                        ZStack(alignment: .leading){
                            Rectangle()
                                .fill(.clear)
                                .glassEffect(.regular, in: .rect(cornerRadius: 18))
                            Text("Read 5 flash cards")
                                .padding()
                        }
                        
                        ZStack(alignment: .leading){
                            Rectangle()
                                .fill(.clear)
                                .glassEffect(.regular, in: .rect(cornerRadius: 18))
                            Text("Read 5 flash cards")
                                .padding()
                        }
                        
                        ZStack(alignment: .leading){
                            Rectangle()
                                .fill(.clear)
                                .glassEffect(.regular, in: .rect(cornerRadius: 18))
                            Text("Read 5 flash cards")
                                .padding()
                        }
                        
                    }
                    .listRowBackground(Color.clear)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                }
                
            }
        }
        .colorScheme(.dark)
    }
}

struct Goals: View {
    var body: some View {
        ZStack{
            Rectangle()
                .fill(LinearGradient(colors: [.color, .dark], startPoint: .bottom, endPoint: .top))
                .ignoresSafeArea()
            Image("Background 1")
                .resizable()
                .ignoresSafeArea()
            Image("Gliter")
                .resizable()
                .ignoresSafeArea()
        }
    }
}

struct Settings: View {
    @State private var Uname: String = ""
    @State private var Uemail: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Rectangle()
                    .fill(LinearGradient(colors: [.color, .dark], startPoint: .bottom, endPoint: .top))
                    .ignoresSafeArea()
                Image("Background 1")
                    .resizable()
                    .ignoresSafeArea()
                Image("Gliter")
                    .resizable()
                    .ignoresSafeArea()
                VStack(alignment: .leading) {
                    Text("Jane Doe")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                        .padding(20)
                        .toolbar{
                            ToolbarItem(placement: .topBarTrailing){
                                Button(action: { print("Display") }) {
                                    Image(systemName: "pencil")
                                        .foregroundColor(.primary.opacity(0.7))
                                }
                            }
                        }
                    
                    VStack {
                        List {
                            Button(action: { print("Display") }) {
                                HStack {
                                    Text("Notification")
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.primary.opacity(0.7))
                                }
                                .padding(.vertical, 12)
                            }
                            Button(action: { print("Display") }) {
                                HStack {
                                    Text("Progress Report")
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.primary.opacity(0.7))
                                }
                                .padding(.vertical, 12)
                            }
                            Button(action: { print("Display") }) {
                                HStack {
                                    Text("Clear Goals")
                                        .foregroundColor(Color(.lightRed))
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Color(.lightRed))
                                }
                                .padding(.vertical, 12)
                            }
                            Button(action: { print("Display") }) {
                                HStack {
                                    Text("Log Out")
                                        .foregroundColor(Color(.lightRed))
                                    
                                    Spacer()
                                    
                                    Image(systemName: "power")
                                        .foregroundColor(Color(.lightRed))
                                }
                                .padding(.vertical, 12)
                            }
                        }
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                    }
                }
            }
        }
        .colorScheme(.dark)
    }
}

struct DayView: View {
    let date: Date
    let selectedDate: Date
    let today: Date

    private let calendar = Calendar.current

    var isSelected: Bool {
        calendar.isDate(date, inSameDayAs: selectedDate)
    }

    var isToday: Bool {
        calendar.isDate(date, inSameDayAs: today)
    }

    var body: some View {
        VStack(spacing: 4) {
            Text(date, format: .dateTime.weekday(.abbreviated))
                .font(.caption2)

            Text(date, format: .dateTime.day())
                .font(.headline)
        }
        .frame(width: 44, height: 56)
        .background(
            isSelected
            ? Color.white
            : isToday
                ? Color.accent.opacity(0.35)
                : Color.color.opacity(0.8)
        )
        .foregroundColor(isSelected ? .black : .white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 12))
    }
}



#Preview {
    Home()
}

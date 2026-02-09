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
            Rectangle()
                .fill(LinearGradient(colors: [.color, .dark], startPoint: .bottom, endPoint: .top))
                .ignoresSafeArea()
            
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
                    .navigationTitle("Goals Of The day")
            }
        }
        Tab.init("Friends", systemImage: "person.2.fill"){
            NavigationStack{
                List{
                    
                }
                .navigationTitle("Friends List")
            }
        }
        Tab.init("Goals", systemImage: "target"){
            NavigationStack{
                List{
                    
                }
                .navigationTitle("Goals")
            }
        }
        Tab.init("Settings", systemImage: "gear"){
            NavigationStack{
                Settings()
                    .navigationTitle("Settings")
            }
        }
    }
    
}

struct today: View {
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var vm = MiniCalendarViewModel()
    var body: some View {
        VStack(alignment: .leading){
            Text(viewModel.formattedDate)
                .foregroundColor(.primary)
                .font(.largeTitle)
                .bold()
                .padding(.leading, 20)
            
            
            Text("THIS IS AN INSPIRING QOUTE.")
                .padding(.leading, 20)
            VStack(spacing: 20) {
                // Month Picker
                Menu {
                    ForEach(vm.months, id: \.self) { month in
                        Button {
                            vm.changeMonth(month)
                        } label: {
                            Text(vm.monthTitle(month))
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text(vm.monthTitle(vm.selectedMonth))
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption)
                    }
                    .foregroundColor(.primary)
                }
                .padding(.leading, -150)
                
                // Days Row
                HStack(spacing: 12) {
                    
                    Button(action: vm.previousWeek) {
                        Image(systemName: "chevron.left")
                    }
                    
                    ForEach(vm.visibleDays) { day in
                        VStack(spacing: 6) {
                            Text(vm.dayName(day.date))
                                .font(.system(size: 10, weight: .regular))
                                .opacity(0.6)
                            
                            Text(vm.dayNumber(day.date))
                                .font(.system(size: 12, weight: .heavy))
                                .frame(width: 30, height: 30)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(day.date == vm.selectedDate ? Color.white : Color.black.opacity(0.6))
                                )
                                .foregroundColor(day.date == vm.selectedDate ? .black : .white)
                                .onTapGesture {
                                    vm.selectedDate = day.date
                                }
                        }
                    }
                    
                    Button(action: vm.nextWeek) {
                        Image(systemName: "chevron.right")
                    }
                }
            }
            .padding()
            .glassEffect(.regular, in: .rect(cornerRadius: 18))
            .padding(.all)
            
            Text("Today's Tasks")
                .foregroundColor(.primary)
                .font(.largeTitle)
                .bold()
                .padding(.leading, 20)
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
            
        }
    }
}

struct Settings: View {
    @State private var Uname: String = ""
    @State private var Uemail: String = ""
    
    var body: some View {
        NavigationStack {
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
                //                    .frame(width: 396, height: 404)
                //                    .background(.clear)
                //                    .glassEffect(.regular, in: .rect(cornerRadius: 20))
                .padding(.leading, 20)
                .padding(.trailing, 20)
            }
        }
    }
}




#Preview {
    Home()
}


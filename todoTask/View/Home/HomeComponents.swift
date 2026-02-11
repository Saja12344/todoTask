//
//  HomeComponents.swift
//  todoTask
//
//  Created by Jana Abdulaziz Malibari on 11/02/2026.
//

import SwiftUI


struct CheckBoxItem {
    var name: String
    var isChecked: Bool
}

struct CheckBoxView: View {
    @Binding var item: CheckBoxItem
    
    var body: some View {
        HStack{
            Text(item.name)
            Spacer()
            Image(systemName: item.isChecked ? "checkmark.circle.fill" :"circle")
                .foregroundColor(item.isChecked ? .blue :.gray)
                .font(.system(size: 22))
                .onTapGesture {
                    item.isChecked.toggle()
                }
        }
    }
}

struct today: View {
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var vm = MiniCalendarViewModel()
    @State private var items = [
        CheckBoxItem(name: "Read 5 flash cards", isChecked: false),
        CheckBoxItem(name: "Walk 1 km", isChecked: false),
        CheckBoxItem(name: "Drink at least 4 water cups", isChecked: false)
    ]
    
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
                
                List{
                    ForEach($items, id: \.name) { $item in
                        CheckBoxView(item: $item)
                    }
                }
                .listRowBackground(Color.clear)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                
            }
        }
        .colorScheme(.dark)
    }
}

struct Goals: View {
    var body: some View {
        NavigationStack{
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
                    .toolbar{
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                print("Button tapped!")
                            }) {
                                Image(systemName: "plus")
                            }
                            .foregroundStyle(.white)
                        }
                    }
            }
            .colorScheme(.dark)
        }
    }
}
struct Settings: View {
    @State private var Uname: String = ""
    @State private var Uemail: String = ""
    @State private var showSettingsButton = false
    
    
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
                            Button(action: {  if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            } }) {
                                HStack {
                                    Text("Notification")
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.primary.opacity(0.7))
                                }
                                .padding(.vertical, 12)
                            }
                            .onAppear {
                                notificationDenied { denied in
                                    DispatchQueue.main.async {
                                        showSettingsButton = denied
                                    }
                                }
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

func requestNotificationPermission() {
    UNUserNotificationCenter.current()
        .requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("Notifications allowed")
                } else {
                    print("Notifications denied")
                }
            }
        }
}

func notificationDenied(_ completion: @escaping (Bool) -> Void) {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
        completion(settings.authorizationStatus == .denied)
    }
}
#Preview {
    Settings()
}

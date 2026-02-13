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
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .frame(width: 330, height: 60)
                .foregroundColor(.clear)
                .glassEffect(.clear, in: .rect(cornerRadius: 20))
            HStack{
                Text(item.name)
                Spacer()
                Image(systemName: item.isChecked ? "checkmark.circle.fill" :"circle")
                    .foregroundColor(item.isChecked ? .blue :.gray)
                    .font(.system(size: 32))
                    .glassEffect(.clear.interactive())
                    .onTapGesture {
                        item.isChecked.toggle()
                    }
            }
            .padding(.all, 10)
            .padding(.leading, 30)
            .padding(.trailing, 30)
        }
        .padding(.trailing, 20)
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
            Image("Background 4")
                .resizable()
                .ignoresSafeArea()
                .opacity(0.4)
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
                
                ZStack (alignment: .center){
                    Rectangle()
                        .frame(width: 385, height: 134)
                        .foregroundColor(.clear)
                        .glassEffect(.regular, in: .rect(cornerRadius: 20))
                    
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
                .padding(.leading, 7)
                
                Text("Today's Tasks")
                    .foregroundColor(.primary)
                    .font(.largeTitle)
                    .bold()
                    .padding(.leading, 20)
                
                ZStack{
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: 350,height: 300)
                        .foregroundColor(.clear)
                    ScrollView {
                        VStack(alignment: .center) {
                            ForEach($items, id: \.name) { $item in
                                CheckBoxView(item: $item)
                            }
                        }
                        .padding(.leading, 23)
                    }
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
            Image("Gliter")
                .resizable()
                .ignoresSafeArea()
        }
        .colorScheme(.dark)
        .toolbar {
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
}

struct Settings: View {
    @EnvironmentObject private var userVM: UserViewModel

    @State private var Uname: String = ""
    @State private var Uemail: String = ""
    @State private var showSettingsButton = false

    // Add sheet state
    @State private var isEditingName: Bool = false
    @State private var draftName: String = ""
    // Guest logout confirmation alert state
    @State private var showGuestLogoutAlert: Bool = false

    private var displayName: String {
        if let name = userVM.currentUser?.username, !name.isEmpty {
            return name
        }
        return "Guest"
    }
    
    private var displayID: String {
        if let id = userVM.currentUser?.id, !id.isEmpty {
            return String(id.prefix(8)) + "..."
        }
        return "N/A"
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(LinearGradient(colors: [.color, .dark], startPoint: .bottom, endPoint: .top))
                .ignoresSafeArea()
            Image("Background")
                .resizable()
                .ignoresSafeArea()
            Image("Gliter")
                .resizable()
                .ignoresSafeArea()
            VStack(alignment: .leading, spacing: 4) {
                // Username
                Text(displayName)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 20)
                
                // Short ID below the name
                Text("ID: \(displayID)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
                
                Text("App Management")
                    .padding(.leading, 20)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .frame(width: 360, height: 220)
                        .foregroundColor(.clear)
                        .glassEffect(.clear, in: .rect(cornerRadius: 30))
                    VStack(alignment: .leading, spacing: 10){
                        
                        Button(action: {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack {
                                Text("Notification")
                                    .foregroundColor(.white)
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
                        Rectangle()
                            .frame(width: 320, height: 2)
                            .foregroundColor(.white.opacity(0.3))
                            .glassEffect()
                        
                        NavigationLink(destination: Report()) {
                            HStack {
                                Text("Progress Report")
                                    .foregroundColor(.white)
                            }
                            .padding(.vertical, 12)
                        }
                        Rectangle()
                            .frame(width: 320, height: 2)
                            .foregroundColor(.white.opacity(0.3))
                            .glassEffect()
                        
                        NavigationLink(destination: Energy()) {
                            HStack {
                                Text("Energy Settings")
                                    .foregroundColor(.white)
                            }
                            .padding(.vertical, 12)
                        }
                        .colorScheme(.dark)
                    }
                    .padding(.leading, 10)
                }
                
                Text("Account Management")
                    .padding(.leading, 20)
                    .padding(.top, 20)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .frame(width: 360, height: 140)
                        .foregroundColor(.clear)
                        .glassEffect(.clear, in: .rect(cornerRadius: 30))
                    VStack(alignment: .leading, spacing: 10){
                        
                        Button(action: { print("Display") }) {
                            HStack {
                                Text("Clear Goals")
                                    .foregroundColor(Color(.lightRed))
                            }
                            .padding(.vertical, 12)
                        }
                        Rectangle()
                            .frame(width: 320, height: 2)
                            .foregroundColor(.white.opacity(0.3))
                            .glassEffect()
                        
                        Button(action: {
                            // For guests, confirm before clearing data
                            if userVM.currentUser?.authMode == .guest {
                                showGuestLogoutAlert = true
                            } else {
                                // Registered users: log out immediately
                                userVM.clearLocalUser()
                            }
                        }) {
                            HStack {
                                Text("Log Out")
                                    .foregroundColor(Color(.lightRed))
                            }
                            .padding(.vertical, 12)
                        }
                    }
                    .colorScheme(.dark)
                }
            }
            .padding(.top, -90)
        }
        // Removed the toolbar logout button per your request
        .toolbar{
            ToolbarItem(placement: .topBarTrailing){
                Button(action: {
                    // Prepare and present username editor
                    draftName = userVM.currentUser?.username ?? ""
                    isEditingName = true
                }) {
                    Image(systemName: "pencil")
                }
                .foregroundStyle(.white)
            }
        }
        // Guest-only confirmation alert
        .alert("Log Out?", isPresented: $showGuestLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Log Out", role: .destructive) {
                userVM.clearLocalUser()
            }
        } message: {
            Text("You are continuing as a guest. Logging out will erase all local data.")
        }
        .sheet(isPresented: $isEditingName) {
            EditUsernameSheet(
                initialName: userVM.currentUser?.username ?? "",
                onCancel: { isEditingName = false },
                onSave: { newName in
                    Task { await userVM.updateUsername(to: newName) }
                    isEditingName = false
                }
            )
            .presentationDetents([PresentationDetent.height(220)])
            .presentationDragIndicator(.visible)
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
            ? Color.white.opacity(0.9)
            : isToday
            ? Color.accent.opacity(0.35)
            : Color.color.opacity(0.8)
        )
        .foregroundColor(isSelected ? Color(.color) : .white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .glassEffect(.clear.interactive(), in: .rect(cornerRadius: 12))
    }
}

// MARK: - Edit Username Sheet
private struct EditUsernameSheet: View {
    @State private var name: String
    let onCancel: () -> Void
    let onSave: (String) -> Void
    
    init(initialName: String, onCancel: @escaping () -> Void, onSave: @escaping (String) -> Void) {
        self._name = State(initialValue: initialName)
        self.onCancel = onCancel
        self.onSave = onSave
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .font(.system(size: 24, weight: .semibold))
                        .cornerRadius(50)
                        .foregroundColor(.white.opacity(0.9))
                }
                .frame(width: 40, height: 40)
                .cornerRadius(50)
                .glassEffect(.clear.tint(.white.opacity(0.4)).interactive(), in: .rect(cornerRadius: 50))
                
                Spacer()
                
                // Title
                Text("Edit Username")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.top, 4)
                
                Spacer()
                
                Button(action: {
                    let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    onSave(trimmed)
                }) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        
                }
                .frame(width: 40, height: 40)
                .cornerRadius(50)
                .glassEffect(.clear.tint(.blue).interactive(), in: .rect(cornerRadius: 50))
            }
            .padding(.horizontal, 4)
            // Text field
            TextField("Username", text: $name)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .padding()
                .background(Color.black.opacity(0.25))
                .cornerRadius(10)
                .foregroundColor(.white)
        }
        .padding()
        .preferredColorScheme(.dark)
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
        .environmentObject(UserViewModel())
}

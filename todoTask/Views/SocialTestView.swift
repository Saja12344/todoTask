//
//  SocialTestView.swift
//  todoTask
//
//  Created by saja khalid on 20/08/1447 AH.
//




import SwiftUI
import CloudKit

struct SocialTestView: View {
    
    @StateObject var userVM = UserViewModel()
    @StateObject var friendVM = FriendRequestViewModel()  // ✅ غيرنا الاسم لوضوح أكثر
    
    @State private var log: String = ""
    @State private var myRecordID: String = ""
    @State private var searchText: String = ""
    @State private var searchResults: [User] = []
    
    var body: some View {
        NavigationView {
            ScrollView {  // ✅ أضفنا ScrollView عشان المحتوى الطويل
                VStack(spacing: 15) {
                    
                    // معلومات المستخدم
                    userInfoSection
                    
                    Divider()
                    
                    // الأزرار
                    actionButtons
                    
                    Divider()
                    
                    // ✅ قسم الطلبات المحسّن
                    if !friendVM.sentRequests.isEmpty || !friendVM.receivedRequests.isEmpty {
                        requestsSections
                    }
                    
                    // Console Log
                    logSection
                }
                .padding()
            }
            .navigationTitle("Social Test 🧪")
            .overlay {
                if friendVM.isLoading {
                    ProgressView("Loading...")
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
            }
            .alert("Error", isPresented: .constant(friendVM.errorMessage != nil)) {
                Button("OK") {
                    friendVM.errorMessage = nil
                }
            } message: {
                Text(friendVM.errorMessage ?? "")
            }
        }
    }
    
    
    // MARK: - UI Components
    
    var userInfoSection: some View {
        VStack(spacing: 8) {
            Text("Current User")
                .font(.headline)
            
            if let user = userVM.currentUser {
                Text(user.username)
                    .font(.title2)
                    .foregroundColor(.blue)
                
                if !myRecordID.isEmpty {
                    Text("ID: \(myRecordID.prefix(8))...")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                // ✅ عرض عدد الأصدقاء
                Text("Friends: \(user.friends.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("Not logged in")
                    .foregroundColor(.red)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(10)
    }
    
    var actionButtons: some View {
        VStack(spacing: 12) {
            
            // تسجيل دخول
            if userVM.currentUser == nil || userVM.currentUser?.authMode == .guest {
                Button {
                    Task { await loginUser() }
                } label: {
                    Label("Login with iCloud", systemImage: "person.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            
            // ✅ البحث عن مستخدمين
            VStack(spacing: 8) {
                HStack {
                    TextField("Search username", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                    
                    Button {
                        Task { await searchUsers() }
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(searchText.isEmpty || myRecordID.isEmpty)
                }
                
                // نتائج البحث
                if !searchResults.isEmpty {
                    VStack(spacing: 6) {
                        Text("Search Results:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        ForEach(searchResults, id: \.id) { user in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(user.username)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text(user.id.prefix(8) + "...")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Button {
                                    Task { await sendRequestToUser(user.id) }
                                } label: {
                                    Label("Add", systemImage: "person.badge.plus")
                                        .font(.caption)
                                }
                                .buttonStyle(.bordered)
                            }
                            .padding(10)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            
            Divider()
            
            // ✅ جلب الطلبات
            HStack(spacing: 10) {
                Button {
                    Task { await fetchSentRequests() }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "paperplane.fill")
                        Text("Sent (\(friendVM.sentRequests.count))")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(myRecordID.isEmpty)
                
                Button {
                    Task { await fetchReceivedRequests() }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "tray.fill")
                        Text("Received (\(friendVM.receivedRequests.count))")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.orange)
                .disabled(myRecordID.isEmpty)
            }
        }
        .padding(.horizontal)
    }
    
    // ✅ قسم الطلبات المحسّن
    var requestsSections: some View {
        VStack(spacing: 20) {
            
            // 1️⃣ الطلبات المرسلة
            if !friendVM.sentRequests.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.blue)
                        Text("Sent Requests")
                            .font(.headline)
                    }
                    .padding(.horizontal)
                    
                    ForEach(friendVM.sentRequests, id: \.recordID) { request in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("To: \(request.to.prefix(10))...")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                Text("Status: \(request.status.rawValue)")
                                    .font(.caption2)
                                    .foregroundColor(statusColor(request.status))
                            }
                            
                            Spacer()
                            
                            if request.status == .pending {
                                Button {
                                    Task { await cancelRequest(request) }
                                } label: {
                                    Label("Cancel", systemImage: "xmark.circle")
                                        .font(.caption)
                                }
                                .buttonStyle(.bordered)
                                .tint(.red)
                            } else {
                                Text(request.status == .accepted ? "✓" : "✗")
                                    .foregroundColor(request.status == .accepted ? .green : .red)
                            }
                        }
                        .padding(10)
                        .background(Color.blue.opacity(0.05))
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.05))
                .cornerRadius(12)
            }
            
            // 2️⃣ الطلبات المستلمة
            if !friendVM.receivedRequests.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "tray.fill")
                            .foregroundColor(.orange)
                        Text("Received Requests")
                            .font(.headline)
                    }
                    .padding(.horizontal)
                    
                    ForEach(friendVM.receivedRequests, id: \.recordID) { request in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("From: \(request.from.prefix(10))...")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                Text("Status: \(request.status.rawValue)")
                                    .font(.caption2)
                                    .foregroundColor(statusColor(request.status))
                            }
                            
                            Spacer()
                            
                            if request.status == .pending {
                                HStack(spacing: 8) {
                                    Button {
                                        Task { await acceptRequest(request) }
                                    } label: {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(.green)
                                    
                                    Button {
                                        Task { await rejectRequest(request) }
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.white)
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(.red)
                                }
                            }
                        }
                        .padding(10)
                        .background(Color.orange.opacity(0.05))
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.05))
                .cornerRadius(12)
            }
        }
        .padding(.horizontal)
    }
    
    var logSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Console Log")
                    .font(.headline)
                
                Spacer()
                
                Button {
                    log = ""
                } label: {
                    Label("Clear", systemImage: "trash")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
            
            ScrollView {
                Text(log.isEmpty ? "No logs yet..." : log)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(log.isEmpty ? .gray : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
            }
            .frame(height: 200)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Functions
    
    func loginUser() async {
        do {
            try await userVM.loginWithiCloud()
            if let user = userVM.currentUser {
                myRecordID = user.id
                addLog("✅ Logged in: \(user.username)")
                addLog("📝 RecordID: \(myRecordID.prefix(12))...")
            }
        } catch {
            addLog("❌ Login error: \(error.localizedDescription)")
        }
    }
    
    func searchUsers() async {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
            addLog("❌ Enter a username to search")
            return
        }
        
        guard !myRecordID.isEmpty else {
            addLog("❌ Login first!")
            return
        }
        
        do {
            let results = try await friendVM.searchUsers(by: searchText)
            
            // ✅ تصفية النتائج (إزالة نفسي)
            searchResults = results.filter { $0.id != myRecordID }
            
            if searchResults.isEmpty {
                addLog("⚠️ No users found for '\(searchText)'")
            } else {
                addLog("✅ Found \(searchResults.count) user(s)")
            }
        } catch {
            addLog("❌ Search error: \(error.localizedDescription)")
        }
    }
    
    func sendRequestToUser(_ targetUserID: String) async {
        guard !myRecordID.isEmpty else {
            addLog("❌ Login first!")
            return
        }
        
        do {
            try await friendVM.sendFriendRequest(to: targetUserID, from: myRecordID)
            addLog(" Request sent to \(targetUserID.prefix(8))...")
            
            searchResults = []
            searchText = ""
            
            try await friendVM.fetchSentRequests(for: myRecordID)
            
        } catch {
            addLog("❌ Send error: \(error.localizedDescription)")
        }
    }
    
    func fetchSentRequests() async {
        guard !myRecordID.isEmpty else {
            addLog("❌ Login first!")
            return
        }
        
        do {
            try await friendVM.fetchSentRequests(for: myRecordID)
            addLog("✅ Found \(friendVM.sentRequests.count) sent request(s)")
        } catch {
            addLog("❌ Fetch error: \(error.localizedDescription)")
        }
    }
    
    func fetchReceivedRequests() async {
        guard !myRecordID.isEmpty else {
            addLog("❌ Login first!")
            return
        }
        
        do {
            try await friendVM.fetchReceivedRequests(for: myRecordID)
            addLog("✅ Found \(friendVM.receivedRequests.count) received request(s)")
        } catch {
            addLog("❌ Fetch error: \(error.localizedDescription)")
        }
    }
    
    func acceptRequest(_ request: FriendRequest) async {
        do {
            try await friendVM.acceptRequest(request, userViewModel: userVM)
            addLog("✅ Request accepted ✓")
            addLog("🎉 Now friends with \(request.from.prefix(8))...")
            
            // ✅ تحديث القائمة
            try await friendVM.fetchReceivedRequests(for: myRecordID)
            
            // ✅ تحديث بيانات المستخدم
            try await userVM.loginWithiCloud()
            
        } catch {
            addLog("❌ Accept error: \(error.localizedDescription)")
        }
    }
    
    func rejectRequest(_ request: FriendRequest) async {
        do {
            try await friendVM.rejectRequest(request)
            addLog("✅ Request rejected ✗")
            
            // ✅ تحديث القائمة
            try await friendVM.fetchReceivedRequests(for: myRecordID)
            
        } catch {
            addLog("❌ Reject error: \(error.localizedDescription)")
        }
    }
    
    func cancelRequest(_ request: FriendRequest) async {
        do {
            try await friendVM.cancelSentRequest(request)
            addLog("✅ Request cancelled")
            
        } catch {
            addLog("❌ Cancel error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Helpers
    
    func addLog(_ message: String) {
        let timestamp = DateFormatter.localizedString(
            from: Date(),
            dateStyle: .none,
            timeStyle: .medium
        )
        DispatchQueue.main.async {
            log = "[\(timestamp)] \(message)\n" + log
        }
    }
    
    func statusColor(_ status: FriendRequestStatus) -> Color {
        switch status {
        case .pending: return .orange
        case .accepted: return .green
        case .rejected: return .red
        }
    }
}

#Preview {
    SocialTestView()
}

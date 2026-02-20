//
//  FriendsV.swift
//  todoTask
//
//  Created by saja khalid on 26/08/1447 AH.
//



import SwiftUI
import CloudKit
import Foundation
struct FriendsV: View {
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var userVM = UserViewModel()
    @StateObject private var friendRequestVM = FriendRequestViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // الخلفية
                LinearGradient(colors: [.darkBlu, .dark], startPoint: .bottom, endPoint: .top)
                    .ignoresSafeArea()
                Image("Gliter")
                    .resizable()
                    .ignoresSafeArea()
                
                VStack(spacing: 15) {
                    // User ID
                    if let user = userVM.currentUser {
                        Text("Your ID: \"\(user.username)\"")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    // Search Bar
                    TextField("Friend ID", text: $friendRequestVM.searchText)
                        .padding(10)
                        .padding(.horizontal, 30)
                        .background(
                            RoundedRectangle(cornerRadius: 35)
                                .glassEffect(.regular.tint(.black.opacity(0.3)).interactive())
                        )
                        .overlay(
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                                .padding(.horizontal, 12)
                        )
                        .padding(.horizontal)
                    
                    // محتوى الطلبات والبحث
                    ScrollView {
                        VStack(spacing: 15) {
                            
                            //MARK: -Accepted requests
                            
                            AcceptedFriendsSection(friendRequestVM: friendRequestVM,
                            ) { id in
                                
                                try? await friendRequestVM.removeFriend(myUserID: id, friendID: friendRequestVM.currentUser?.id ?? "")
                            }
                            
                            //MARK: -Received requests
 
                            ReceivedRequestsSection(
                                friendRequestVM: friendRequestVM,
                                acceptAction: { request in
                                    try? await friendRequestVM.acceptRequest(request)
                                },
                                declineAction: { request in
                                    try? await friendRequestVM.rejectRequest(request)
                                }
                            )



                            //MARK: -Pending requests

                            PendingRequestsSection(friendRequestVM: friendRequestVM,
                            ) { request in
                                try? await friendRequestVM.cancelSentRequest(request)
                            }

                        }
                    }
                    .padding()

                }
                
            }
            .colorScheme(.dark)
            
            .navigationTitle("Friends")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            

        }

        
     
    }
    
    
    // MARK: - Accepted Requests Section
    struct AcceptedFriendsSection: View {
        @ObservedObject var friendRequestVM: FriendRequestViewModel

        let removeAction: (String) async -> Void
        
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                if !friendRequestVM.friends.isEmpty {
                    Text("Accepted Friends")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding(.leading, 10)
                    
                    ForEach(friendRequestVM.friends) { friend in
                        HStack {
                            Text(friend.username)
                                .foregroundColor(.white)
                                .bold()
                            Spacer()
                            Button {
                                Task {
                                    await removeAction(friend.id)
                                }
                            } label: {
                                Image(systemName: "person.slash")
                                    .foregroundColor(.white)
                                    .font(.subheadline)
                                    .padding(8)
                                    .glassEffect(.regular.tint(.red.opacity(0.3)), in: .circle)
                            }
                            .buttonStyle(.plain)
                            
                            
                            
                            Button {
                                Task {
                                  
                                    // نفترض عند الضغط على التحدي تنفذ شي ثاني
                                    
                                }
                            } label: {
                                Text("Challenge")
                                    .foregroundColor(.white)
                                    .font(.subheadline)
                                    .bold()
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .glassEffect(.regular.interactive(), in: .capsule)
                            }
                            .buttonStyle(.plain)
                            
                        }
                        .padding()
                        .glassEffect(.regular.tint(.white.opacity(0.1)), in: .rect(cornerRadius: 20))
                    }
                }
            }
        }
    }
    
    
    // MARK: - Received Requests Section
    struct ReceivedRequestsSection: View {
    @ObservedObject var friendRequestVM: FriendRequestViewModel

    let acceptAction: (FriendRequest) async -> Void
    let declineAction: (FriendRequest) async -> Void

    private func username(for userID: String) -> String {
        return friendRequestVM.allUsers.first(where: { $0.id == userID })?.username ?? "Unknown"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !friendRequestVM.receivedRequests.isEmpty {
                Text("Received Requests")
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding(.leading, 10)
                
                ForEach(friendRequestVM.receivedRequests) { request in
                    HStack {
                        Text(username(for: request.from))
                            .foregroundColor(.white)
                            .bold()
                        Spacer()
                        Button {
                            Task {
                                await declineAction(request)
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                                .padding(8)
                                .glassEffect(.regular, in: .circle)
                        }
                        .buttonStyle(.plain)

                        Button {
                            Task {
                                try? await acceptAction(request)
                            }
                        } label: {
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                                .padding(8)
                                .glassEffect(.regular, in: .circle)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding()
                    .glassEffect(.regular.tint(.white.opacity(0.1)), in: .rect(cornerRadius: 20))
                }
            }
        }
    }
}
 
                  

    // MARK: - Pending Requests Section
    struct PendingRequestsSection: View {
        @ObservedObject var friendRequestVM: FriendRequestViewModel

        let cancelAction: (FriendRequest) async -> Void
      
        
        // match the recordID to -> username
        private func username(for userID: String) -> String {
            return friendRequestVM.allUsers.first(where: { $0.id == userID })?.username ?? "Unknown"
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                
                if !friendRequestVM.pendingRequests.isEmpty {
                    Text("Pending Requests")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding(.leading, 10)
                    
                    ForEach(friendRequestVM.pendingRequests)
                    { request in
                        HStack {
                            // print the Pending username

                            Text(username(for: request.to))
                                .foregroundColor(.white)
                                .bold()
                            
                            Spacer()
                            
                            Button {
                                Task {
                                    await cancelAction(request)
                                }
                            } label: {
                                Image(systemName: "person.badge.clock")
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .glassEffect(.regular, in: .circle)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding()
                        .glassEffect(.regular.tint(.white.opacity(0.1)), in: .rect(cornerRadius: 20))
                    }
                }
            }
        }
    }
    
}

#Preview {
    FriendsV()
}

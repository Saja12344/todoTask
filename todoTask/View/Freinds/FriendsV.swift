//
//  FriendsV.swift
//  todoTask
//

import SwiftUI

struct FriendsV: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(LinearGradient(colors: [.darkBlu, .dark], startPoint: .bottom, endPoint: .top))
                .ignoresSafeArea()
            
            Image("Background 4")
                .resizable()
                .ignoresSafeArea()
                .opacity(0.7)
            
            Image("Gliter")
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white.opacity(0.3))
                
                Text("Friends")
                    .font(.title.bold())
                    .foregroundColor(.white)
                
                Text("Coming Soon...")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .colorScheme(.dark)
    }
}

#Preview {
    FriendsV()
}

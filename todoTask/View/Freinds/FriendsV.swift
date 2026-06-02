//  FriendsV.swift
//  todoTask

import SwiftUI

struct FriendsV: View {
    @EnvironmentObject private var store: OrbGoalStore
    @EnvironmentObject private var lang: LanguageManager
    @State private var showCreate = false
    @State private var showJoin   = false
    @State private var joinCode   = ""
    @State private var createdRoomId: String?

    var body: some View {
        ZStack {
            Rectangle()
                .fill(LinearGradient(colors: [.darkBlu, .dark],
                                     startPoint: .bottom, endPoint: .top))
                .ignoresSafeArea()
            Image("Background 4").resizable().ignoresSafeArea().opacity(0.7)
            Image("Gliter").resizable().ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // أيقونة
                ZStack {
                    Circle()
                        .fill(Color.accent.opacity(0.15))
                        .frame(width: 110, height: 110)
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.accent)
                }

                VStack(spacing: 8) {
                    Text("تحدّ صديقك")
                        .font(.title.bold()).foregroundColor(.white)
                    Text("تنافسا على إكمال المهام اليومية\nمن يُكمل أكثر يفوز بالكوكب")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.55))
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 14) {
                    // إنشاء تحدي
                    Button {
                        showCreate = true
                    } label: {
                        Label("إنشاء تحدي", systemImage: "plus.circle.fill")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity).frame(height: 54)
                            .background(Color.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    // الانضمام لتحدي
                    Button {
                        showJoin = true
                    } label: {
                        Label("الانضمام برمز", systemImage: "link")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity).frame(height: 54)
                            .glassEffect(.clear.interactive(), in: .rect(cornerRadius: 16))
                    }
                }
                .padding(.horizontal, 28)

                Spacer()
            }
        }
        .colorScheme(.dark)
        // شيت إنشاء تحدي
        .sheet(isPresented: $showCreate) {
            CreateChallengeSheet(store: store) { roomId in
                createdRoomId = roomId
                showCreate = false
            }
        }
        // شيت الانضمام
        .sheet(isPresented: $showJoin) {
            JoinChallengeSheet { roomId in
                createdRoomId = roomId
                showJoin = false
            }
        }
        // انتقال لصفحة السباق
        .fullScreenCover(item: Binding(
            get: { createdRoomId.map { RoomID(id: $0) } },
            set: { if $0 == nil { createdRoomId = nil } }
        )) { wrapper in
            RocketRaceView(roomId: wrapper.id)
                .environmentObject(store)
        }
    }
}

struct RoomID: Identifiable { let id: String }

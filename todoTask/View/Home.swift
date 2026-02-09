//
//  Home.swift
//  OrbitDemo
//
//  Created by Jana Abdulaziz Malibari on 07/02/2026.
//

import SwiftUI

struct Home: View {
    var body: some View {
        
        VStack{
           
            ZStack{
                Rectangle()
                    .fill(LinearGradient(colors: [.color, .dark], startPoint: .bottom, endPoint: .top))
                    .ignoresSafeArea()
            }
            
            Group{
                if #available(iOS 26, *) {
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
        Tab.init("Home", systemImage: "house.fill"){
            NavigationStack{
                List {

                }
                .scrollContentBackground(.hidden)
                .navigationTitle("Home")
            }
            .navigationBarBackButtonHidden(true)
        }
        Tab.init("Goals", systemImage: "target"){
            NavigationStack{
                List {

                }
                .scrollContentBackground(.hidden)
                .navigationTitle("Goals")
            }
            .navigationBarBackButtonHidden(true)
        }
        Tab.init("Progress", systemImage: "chart.bar.xaxis"){
            NavigationStack{
                List {

                }
                .scrollContentBackground(.hidden)
                .navigationTitle("Your Progress")
            }
            .navigationBarBackButtonHidden(true)
        }
        Tab.init("Settings", systemImage: "gear"){
            NavigationStack{
                List {

                }
                .scrollContentBackground(.hidden)
                .navigationTitle("Settings")
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

struct Goals: View {
    var body: some View {
        NavigationStack{
            Text("Goals")
                .foregroundColor(.white)
                .navigationTitle("Goals")
            
            
        }
    }
}

struct Settings: View {
    @State private var Uname : String = ""
    @State private var Uemail : String = ""
    @State private var Notify = false
    
    
    var body: some View {
        NavigationStack{
            Text("Settings")
                .foregroundColor(.white)
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .bold()
                .toolbar{
                    ToolbarItem(placement: .navigationBarTrailing){
                        Button {
                        } label: {
                            Image(systemName: "pencil")
                        }
                    }
                }
            VStack(alignment: .center){
                Spacer()
                ZStack {
                    Circle()
                        .frame(width: 90, height: 90)
                        .glassEffect(.regular.tint(.white.opacity(0.2)).interactive())
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 42, weight: .bold))
                        .blendMode(.destinationOut)
                }
                .compositingGroup()
                .padding()
                
                Text("Jane Doe")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(1)
                Text("JaneDoe@gmail.com")
                    .tint(.white)
                    .font(.system(size: 17, weight: .thin))
                    .padding(.bottom,20)
                ZStack{
                    Rectangle()
                        .frame(width: 362, height: 404)
                        .glassEffect(.clear, in: .rect(cornerRadius: 24))
                        .padding(.bottom, 50)
                    VStack{
                        Toggle("Notification", isOn: $Notify)
                            .foregroundColor(.white)
                            .padding(.bottom, 20)
                            .padding(.top, -30)
                        
                        
                        Rectangle()
                            .frame(width: 300, height: 2)
                            .foregroundColor(.white.opacity(0.3))
                            .glassEffect()
                        Button(action: {print("Display")}){
                            HStack {
                                Text("FAQ")
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .padding(.vertical, 12)
                        }
                        Button(action: {print("Display")}){
                            HStack {
                                Text("Friends List")
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .padding(.vertical, 12)
                        }
                        Button(action: {print("Display")}){
                            HStack {
                                Text("Clear Goals")
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .padding(.vertical, 12)
                        }
                        Button(action: {print("Display")}){
                            HStack {
                                Text("About App")
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .padding(.vertical, 12)
                        }
                        Button(action: {print("Display")}){
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
                    .padding(.leading,50)
                    .padding(.trailing,50)
                }
            }
        }
    }
}

#Preview {
    Home()
}

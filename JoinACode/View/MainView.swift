//
//  MainView.swift
//  JoinACode
//
//  Created by Ostap Artym on 28.01.2024.
//

import SwiftUI


//Rename to generalView
struct MainView: View {
    
    @State var recentProjects: [ProjectsModel] = []
    @State private var userProfile: UserModel?
    var body: some View {
        
        TabView {
            
            HomeView()
                .tabItem {
                    Image(systemName: "house.circle")
                    Text("Home")
                }
            
            Text("Search")
                .tabItem {
                    Image(systemName: "magnifyingglass.circle")
                    Text("Search")
                }
            
            UserProjectView()
                .tabItem {
                    Image(systemName: "plus.circle")
                    Text("NEW")
                }
            
            Text("Message")
                .tabItem {
                    Image(systemName: "message.circle")
                    Text("Message")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
        }
//        .tint(.white)
        
        
    }
}

#Preview {
    MainView()
}

//
//  UserProjectView.swift
//  JoinACode
//
//  Created by Ostap Artym on 29.01.2024.
//

import SwiftUI

struct UserProjectView: View {
    
    @State var createNewProject: Bool = false
    @State var recentProjects: [ProjectsModel] = []
    @State private var fetchedProjects: [ProjectsModel] = []
    @State private var userProfile: UserModel?

    
    var body: some View {
        
        NavigationStack {
            
            
            VStack(spacing: 15){
                
                Text("MY PROJECTS")
                    .font(.title).bold()
                
                Button {
                    createNewProject.toggle()
                } label: {
                    VStack {
                        Text("Create new project")
                        Image(systemName: "plus")
                    }
                    .font(.title3).bold()
                    
                }
                
                ReusableProjectsView(projects: $recentProjects)
//                ReusableProjectsView(basedOnUID: true, uid: userProfile!.userUID , projects: $fetchedProjects)
                
            }
            .vAlignment(.top)
            .fullScreenCover(isPresented: $createNewProject, content: {
                CreatingNewProject { project in
                    recentProjects.insert(project, at: 0)
                }
            })
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        SearchView()
                    } label: {
                        Image(systemName: "magnifyingglass.circle")
                            
                    }
                }
            }
        }
        

    }
}

#Preview {
    UserProjectView()
}

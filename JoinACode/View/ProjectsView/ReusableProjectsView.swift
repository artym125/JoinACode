//
//  ReusableProjectsView.swift
//  JoinACode
//
//  Created by Ostap Artym on 29.01.2024.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct ReusableProjectsView: View {
    
    var basedOnUID: Bool = false
    var uid: String = ""
    
    @Binding var projects: [ProjectsModel]
    
    @State private var isFetching: Bool = true
    
    @State private var paginationDoc: QueryDocumentSnapshot?
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                if isFetching {
                    ProgressView()
//                        .padding(.top, 30)
                } else {
                    if projects.isEmpty {
                        Text("No projects found")
                    } else {
                        Projects()
                    }
                }
            }
//            .padding(15)
        }
        .refreshable {
            guard !basedOnUID else {return}
            isFetching = true
            projects = []
            paginationDoc = nil
            await fetchProjects()
            
        }
        .task {
            guard projects.isEmpty else {return}
            await fetchProjects()
        }
    }
    
    @ViewBuilder
    func Projects() -> some View {
        ForEach(projects){ project in
            ProjectCardView(projects: project) { updateProject in
                //updating project in the array
                if let index = projects.firstIndex(where: { project in
                    project.id == updateProject.id
                }){
                    projects[index].likedIDs = updateProject.likedIDs
                    projects[index].dislikedIDs = updateProject.dislikedIDs
                }
            } onDelete: {
                //remove project from the array
                withAnimation(.easeInOut(duration: 0.25)) {
                    projects.removeAll{project.id == $0.id}
                }
            }
            .onAppear{
                if project.id == projects.last?.id && paginationDoc != nil {
                    print("Fetch new projects")
                    Task {await fetchProjects()}
                }
            }
            
            Divider()
                .padding(.horizontal, 5)

        }
    }
    
    func fetchProjects() async {
        do {
            var query: Query!
            
            if let paginationDoc {
                query = Firestore.firestore().collection("Projects")
                    .order(by: "publishedDate", descending: true)
                    .start(afterDocument: paginationDoc)
                    .limit(to: 20)
            } else {
                query = Firestore.firestore().collection("Projects").order(by: "publishedDate", descending: true)
                    .limit(to: 20)
            }
//            query = Firestore.firestore().collection("Projects").order(by: "publishedDate", descending: true)
//                .limit(to: 20)
            
            if basedOnUID{
                query = query
                    .whereField("userUID", isEqualTo: uid)
            }
            
            let docs = try await query.getDocuments()
            let fetchedProjects = docs.documents.compactMap { doc -> ProjectsModel? in
                try? doc.data(as: ProjectsModel.self)
            }
            await MainActor.run {
                projects.append(contentsOf: fetchedProjects)
                paginationDoc = docs.documents.last
                isFetching = false
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
}

//struct ReusableProjectsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ReusableProjectsView(projects: .constant([testProject1, testProject2]))
//    }
//}



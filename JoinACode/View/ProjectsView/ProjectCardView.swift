//
//  ProjectCardView.swift
//  JoinACode
//
//  Created by Ostap Artym on 29.01.2024.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

struct ProjectCardView: View {
    
    var projects: ProjectsModel
    var onUpdate: (ProjectsModel) -> ()
    var onDelete: () -> ()
    
    @AppStorage("user_UID") private var userUID: String = ""
    @State private var docListener: ListenerRegistration?
    var body: some View {
        HStack(alignment: .top) {
            
            //            WebImage(url: projects.userProfileURL)
            //                .resizable()
            //                .aspectRatio(contentMode: .fill)
            //                .frame(width: 35, height: 35)
            //                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                
                Text(projects.userName)
                
                Text(projects.publishedDate.formatted(date: .numeric, time: .shortened))
                
                Text(projects.text)
                    .textSelection(.enabled)
                
                ProjectInteraction()
                
                if let projectImageURL = projects.imageURL {
                    GeometryReader {
                        let size = $0.size
                        WebImage(url: projectImageURL)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .padding(15)
                    }
                    .padding(10)
                    .frame(height: 200)
                }
                
            }
            .padding(15)
            
            
            
            
        }
        .hAlignment(.leading)
        .overlay(alignment: .topTrailing, content: {
            if projects.userUID == userUID{
                
                Menu {
                    Button("Delete",role: .destructive) {
                        deleteProject()
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.init(degrees: -90))
                        .foregroundColor(.green)
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .offset(x: 8)
                
            }
        })
        .onAppear {
            if docListener == nil {
                guard let projectID = projects.id else {return}
                docListener = Firestore.firestore().collection("Projects").document(projectID).addSnapshotListener({ snapshot, error in
                    if let snapshot {
                        if snapshot.exists {
                            if let updatedProject = try? snapshot.data(as: ProjectsModel.self){
                                onUpdate(updatedProject)
                            }
                        } else {
                            onDelete()
                        }
                    }
                })
            }
        }
        .onDisappear{
            if let docListener {
                docListener.remove()
                self.docListener = nil
            }
        }
        .onTapGesture {
            print(projects.text)
        }
        
    }
    
    @ViewBuilder
    func ProjectInteraction() -> some View {
        HStack() {
            Button(action: likeProject){
                Image(systemName: projects.likedIDs.contains(userUID) ? "hand.thumbsup.fill" : "hand.thumbsup")
            }
            
            Text("\(projects.likedIDs.count)")
                .font(.caption)
            
            Spacer()
            
            Button(action: dislikeProject){
                Image(systemName: projects.dislikedIDs.contains(userUID) ? "hand.thumbsdown.fill" : "hand.thumbsdown" )
            }
            
            Text("\(projects.dislikedIDs.count)")
                .font(.caption)
            
        }
        .foregroundColor(.red)
        //        .padding(.vertical, 8)
    }
    
    //Like
    func likeProject() {
        Task {
            guard let projectID = projects.id else {return}
            if projects.likedIDs.contains(userUID) {
                try await  Firestore.firestore().collection("Projects").document(projectID).updateData([
                    "likedIDs": FieldValue.arrayRemove([userUID])
                ])
                print("like")
            } else {
                try await Firestore.firestore().collection("Projects").document(projectID).updateData([
                    "likedIDs": FieldValue.arrayUnion([userUID]),
                    "dislikedIDs": FieldValue.arrayRemove([userUID])
                ])
            }
        }
    }
    
    //Dislike
    func dislikeProject() {
        Task {
            guard let projectID = projects.id else {return}
            if projects.dislikedIDs.contains(userUID) {
                try await   Firestore.firestore().collection("Projects").document(projectID).updateData([
                    "dislikedIDs": FieldValue.arrayRemove([userUID])
                ])
            } else {
                try await Firestore.firestore().collection("Projects").document(projectID).updateData([
                    "likedIDs": FieldValue.arrayRemove([userUID]),
                    "dislikedIDs": FieldValue.arrayUnion([userUID])
                ])
            }
        }
    }
    
    func deleteProject() {
        Task {
            do {
                if projects.imageReferenceID != ""{
                    try await Storage.storage().reference().child("Project_Images").child(projects.imageReferenceID).delete()
                }
                guard let projectID = projects.id else {return}
                try await Firestore.firestore().collection("Projects").document(projectID).delete()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
}

//#Preview {
//    ProjectCardView()
//}

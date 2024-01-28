//
//  CreatingNewProject.swift
//  JoinACode
//
//  Created by Ostap Artym on 28.01.2024.
//

import SwiftUI
import PhotosUI
import Firebase
import FirebaseStorage
import FirebaseFirestore

struct CreatingNewProject: View {
    //onProject
    var onProject: (ProjectsModel)->()
    //project title
    @State private var projectText: String = ""
    @State private var projectImageData: Data?
    
    @AppStorage("user_profile_url") private var profileURL: URL?
    @AppStorage("user_name") private var userName: String = ""
    @AppStorage("user_UID") private var userUID: String = ""
    
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading: Bool = false
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var photoItem: PhotosPickerItem?
    @FocusState private var showKeyboard: Bool




    var body: some View {
        VStack {
            HStack {
//                Menu {
//                    Button("Cancel", role: .destructive){
//                        dismiss()
//                    }
//                } 
                Button {
                    dismiss()
                }
            label: {
                    Text("Cancel")
                        .font(.callout).bold()
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.red, in: Capsule())
                }
                .hAlignment(.leading)
                
                Button(action: {createProjectItem()}, label: {
                    Text("Create")
                        .font(.callout).bold()
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.green, in: Capsule())

                })
                .buttonDisableAndOpacity(projectText == "")

            }
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background{
                Rectangle()
                    .fill(.gray.opacity(0.05))
                    .ignoresSafeArea()
            }
            .overlay {
                Text("NEW PROJECT")
                    .bold()
                    .tint(.white)
            }
            
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 15) {
                    
                    if let projectImageData, let image = UIImage(data: projectImageData) {
                        GeometryReader {
                            let size = $0.size
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: size.width, height: size.height)
                                .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                                .overlay(alignment: .topTrailing) {
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.25)){
                                            self.projectImageData = nil
                                        }
                                    } label: {
                                        Image(systemName: "trash")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .tint(.red)
                                    }
                                    .padding(10)
                                }
                                .onTapGesture {
                                    showImagePicker.toggle()
                                }
//                                .padding(15)
                        }
                        .clipped()
                        .frame(height: 200)
                    } else {
                        // Дефолтне зображення, якщо projectImageData є nil
                        Image("pictureNotFound")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                            .onTapGesture {
                                showImagePicker.toggle()
                            }
//                            .padding(15)
//                            .overlay(alignment: .topTrailing) {
//                                Button {
//                                    withAnimation(.easeInOut(duration: 0.25)){
//                                        self.projectImageData = nil
//                                    }
//                                } label: {
//                                    Image(systemName: "trash")
//                                        .font(.title2)
//                                        .fontWeight(.bold)
//                                        .tint(.red)
//                                }
//                                .padding(10)
//                            }
                    }
                    Text("choose image")
                        .font(.system(size: 15))
                        .foregroundStyle(.gray)
                        .opacity(projectImageData == nil ? 1 : 0)
                    
                    VStack {
                        TextField("Project Name", text: $projectText, axis: .vertical)
                            .focused($showKeyboard)
                    }
                    
                    
                    
                }
                .padding(.vertical, 5)
                .padding(.horizontal, 15)
            }
            
            Divider()
            
            HStack {
                Button(action: {
                    showImagePicker.toggle()
                }, label: {
                    Image(systemName: "photo.on.rectangle")
                        .font(.title)
                })
                .hAlignment(.leading)
                
                Button("Done"){
                    showKeyboard = false
                }
            }
            .foregroundColor(.green)
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            
        }
        .vAlignment(.top)
        .photosPicker(isPresented: $showImagePicker, selection: $photoItem)
        .onChange(of: photoItem) { newValue in
            if let newValue {
                Task {
                    if let rawImageData = try? await newValue.loadTransferable(type: Data.self), let image = UIImage(data: rawImageData), let compressedImageData = image.jpegData(compressionQuality: 0.5){
                        await MainActor.run {
                            projectImageData = compressedImageData
                            photoItem = nil
                        }
                    }
                }
            }
        }
        .alert(errorMessage, isPresented: $showError, actions: {
            
        })
        .overlay{
            LoadingView(show: $isLoading)
        }
        .background {
            Image("TestImage1")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            BlurView()
                .ignoresSafeArea()
        }
        .preferredColorScheme(.dark)
    }
    
    func createProjectItem() {
        isLoading = true
        showKeyboard = false
        Task {
            do {
                guard let profileURL = profileURL else {return}
                
                let imageReferenceID = "\(userUID)\(Date())"
                let storageReference = Storage.storage().reference().child("Projects_Images").child(imageReferenceID)
                if let projectImageData {
                    let _ = try await storageReference.putDataAsync(projectImageData)
                    let downloadURL = try await storageReference.downloadURL()
                    
                    let project = ProjectsModel(text: projectText, imageURL: downloadURL, imageReferenceID: imageReferenceID, userName: userName, userUID: userUID, userCountry: "", userLanguage: "", userProfileURL: profileURL)
                    try await createDocumentInFirebase(project)
                } else {
                    let project = ProjectsModel(text: projectText, userName: userName, userUID: userUID, userCountry: "", userLanguage: "", userProfileURL: profileURL)
                    try await createDocumentInFirebase(project)
                }
            } catch {
                await setError(error)
            }
        }
    }
    
    func createDocumentInFirebase(_ project: ProjectsModel) async throws {
        let _ = try Firestore.firestore().collection("Projects").addDocument(from: project, completion: { error in
            if error == nil {
                isLoading = false
                onProject(project)
                dismiss()
            }
            
        })
    }
    
    func setError(_ error: Error) async {
        await MainActor.run {
            errorMessage = error.localizedDescription
            showError.toggle()
        }
    }
}

#Preview {
    CreatingNewProject { _ in
        
    }
}

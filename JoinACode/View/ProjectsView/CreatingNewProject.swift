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
    
    @StateObject var CreatingNPvm: CreatingNewProjectViewModel = CreatingNewProjectViewModel()
    //onProject
    var onProject: (ProjectsModel)->()
    
    @State private var projectImageData: Data?
    @State private var projectTitle: String = ""
    @State private var projectTechStack: String = ""
    @State private var projectDescription: String = ""
    
    
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
                .buttonDisableAndOpacity(projectTitle == "" || projectTechStack == "" || projectDescription == "")

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
                        }
                        .clipped()
                        .frame(height: 230)
                    } else {
                        // Default pic nil
                    Image("pictureNotFound7")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                            .onTapGesture {
                                showImagePicker.toggle()
                            }
                    }
                    Text("choose image")
                        .font(.system(size: 15))
                        .foregroundStyle(.gray)
                        .opacity(projectImageData == nil ? 1 : 0)
                    

                    TextFieldData()
                    
                    
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
                .opacity(showKeyboard ? 1 : 0)
                .animation(.easeInOut(duration: 0.15), value: showKeyboard)
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
            ZStack {
                Image("pictureNotFound7")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            
            BlurView()
                .ignoresSafeArea()
            }
        }
        .preferredColorScheme(.dark)
    }
    
    @ViewBuilder
    func TextFieldData() -> some View {
        VStack(spacing: 10) {
            
            CustomTextField(
                objectOfTextField: $projectTitle,
                textFieldType: TextField(
                    "",
                    text: $projectTitle,
                    prompt:Text("Title*")
                        .foregroundColor(.gray)))
            .focused($showKeyboard)
            
            CustomTextField(
                objectOfTextField: $projectTechStack,
                textFieldType: TextField(
                    "",
                    text: $projectTechStack,
                    prompt:Text("Project tech stack*")
                        .foregroundColor(.gray)))
            .focused($showKeyboard)
            
            TextField("", text: $projectDescription, prompt: Text("Description*")
                    .foregroundColor(.gray), axis: .vertical)
                .frame(minHeight: 100, alignment: .top)
                .padding()
                .background(projectDescription.isEmpty ? Color.gray.opacity(0.3) : Color.gray.opacity(0.6))
                .cornerRadius(12)
                .foregroundColor(Color.white)
                .font(.headline)
                .accentColor(Color.white.opacity(0.8))
                .focused($showKeyboard)
                .onChange(of: projectDescription) { newValue in
                    if newValue.count > 250 {
                        projectDescription = String(newValue.prefix(250))
                    }
                }
                .overlay(alignment: .bottomTrailing) {
                    Text("\(projectDescription.count) / 250")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(5)
                }
            
            Text("* - require field")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .padding(10)
        }
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
                    
                    let project = ProjectsModel(text: projectTitle, imageURL: downloadURL, imageReferenceID: imageReferenceID, userName: userName, userUID: userUID, userCountry: "", userLanguage: "", userProfileURL: profileURL)
                    try await createDocumentInFirebase(project)
                } else {
                    let project = ProjectsModel(text: projectTitle, userName: userName, userUID: userUID, userCountry: "", userLanguage: "", userProfileURL: profileURL)
                    try await createDocumentInFirebase(project)
                }
            } catch {
                await setError(error)
            }
        }
    }
    
    func createDocumentInFirebase(_ project: ProjectsModel) async throws {
        let doc = Firestore.firestore().collection("Projects").document()
        let _ = try doc.setData(from: project, completion: { error in
            if error == nil {
                
                isLoading = false
                var updatedProject = project
                updatedProject.id = doc.documentID
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

//extension UIImage {
//    static var pictureNotFoundIndex = 0
//    
//    static func getNextPictureNotFound() -> UIImage? {
//        let pictureNotFoundNames = ["pictureNotFound1", "pictureNotFound2"]
//        
//        guard pictureNotFoundIndex < pictureNotFoundNames.count else {
//            // Якщо індекс виходить за межі масиву, повертайте nil або обирайте іншу логіку за необхідності.
//            return nil
//        }
//        
//        let imageName = pictureNotFoundNames[pictureNotFoundIndex]
//        pictureNotFoundIndex = (pictureNotFoundIndex + 1) % pictureNotFoundNames.count
//        
//        return UIImage(named: imageName)
//    }
//}

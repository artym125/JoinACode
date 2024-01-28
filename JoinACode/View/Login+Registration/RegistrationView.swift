//
//  RegistrationView.swift
//  JoinACode
//
//  Created by Ostap Artym on 28.01.2024.
//

import SwiftUI
import PhotosUI
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseFirestoreSwift

struct RegistrationView: View {
    
    @State var fullname: String = ""
    @State var nickname: String = ""
    @State var emailID: String = ""
    @State var password: String = ""
//    @State var userDevCategory: String = ""
    
    @State var userProfilePictureData: Data?
    @State var showImagePicker: Bool = false
    @State var photoItem: PhotosPickerItem?
    
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    
    @State var isLoading: Bool = false
    
    @Environment(\.dismiss) var dismissToSingView
    
    //USER DEFAULTS
    
    @AppStorage("log_status") var logStatus: Bool = false
    @AppStorage("user_profile_url") var profileURL: URL?
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    
//    var categoryOfProg: String
//    var stackOfTechology: String
//    var userJobExperience: String
//    var userCountry: String
//    var userLanguage: String
//    var userProfileURL: URL
    
    var body: some View {

                VStack(spacing: 0) {
                    
                    VStack {
                        
                        ViewThatFits {
                            ScrollView(.vertical, showsIndicators: false) {
                                HelperView()
                            }
                            
                            HelperView()
                        }
                        
                        VStack {
                            Text("Already have account?")
                                .foregroundStyle(Color.gray)
                            
                            Button("Login Now") {
                                dismissToSingView()
                            }
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                        }
//                        .font(.callout)
                        .vAlignment(.bottom)
                    }
                    .padding(15)
                    .overlay(content: {
                        LoadingView(show: $isLoading)
                    })
                    .photosPicker(isPresented: $showImagePicker, selection: $photoItem)
                    .onChange(of: photoItem) { newValue in
                        if let newValue {
                            Task {
                                do {
                                    guard let imageData = try await newValue.loadTransferable(type: Data.self) else {
                                        return
                                    }
                                    await MainActor.run {
                                        userProfilePictureData = imageData
                                    }
                                } catch {
                                    
                                }
                            }
                        }
                    }
                    .alert(errorMessage, isPresented: $showError, actions: {
                        
                    })
                    .background {
                        ZStack {
                            
                            Image("TestImage2")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                            BlurView()
                        }
                        .ignoresSafeArea()
                    }
            }
        
    }
    
    @ViewBuilder
    func HelperView() -> some View {
        
        VStack(spacing: 10) {

                Text("Welcome to Join A Code 🚀")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(3)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 5)
                
                ZStack {
                    if let userProfilePictureData, let image = UIImage(data: userProfilePictureData) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Image("defaulUserPic")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .foregroundStyle(LinearGradient(colors: [Color.white, Color.blue], startPoint: .topTrailing, endPoint: .bottomLeading))
                    }
                }
                .frame(width: 85, height: 85)
                .clipShape(Circle())
                .contentShape(Circle())
                .onTapGesture {
                    showImagePicker.toggle()
                }
                .padding(.top, 20)
                
                Text("Choose your photo")
                    .font(.callout)
                    .foregroundStyle(Color.white.opacity(0.6))
            
            CustomTextField(
                objectOfTextField: $fullname,
                textFieldType: TextField(
                    "",
                    text: $fullname,
                    prompt:Text("$fullname")
                        .foregroundColor(.gray)))
            
            CustomTextField(
                objectOfTextField: $nickname,
                textFieldType: TextField(
                    "",
                    text: $nickname,
                    prompt:Text("$$nickname")
                        .foregroundColor(.gray)))
            
            CustomTextField(
                objectOfTextField: $emailID,
                textFieldType: TextField(
                    "",
                    text: $emailID,
                    prompt:Text("emailID")
                        .foregroundColor(.gray)))
            
            CustomTextField(
                objectOfTextField: $password,
                textFieldType: SecureField(
                    "",
                    text: $password,
                    prompt:Text("$password")
                        .foregroundColor(.gray)))
            
//            CustomTextField(
//                objectOfTextField: $userDevCategory,
//                textFieldType: TextField(
//                    "",
//                    text: $userDevCategory,
//                    prompt:Text("userDevCategory")
//                        .foregroundColor(.gray)))
            
            Button{
                registerUser()
            } label: {
                Text("SIGN UP")
                    .foregroundStyle(Color.black)
                    .fontWeight(.bold)
                    .hAlignment(.center)
                    .buttonStyleFill(.brown)
            }
            .buttonDisableAndOpacity(fullname == "" || nickname == "" || emailID == "" || password == "")
            .padding(.top, 15)
        }
        .onAppear {
                // Check if userProfilePictureData is nil, and if so, set it to the default image
                if userProfilePictureData == nil {
                    userProfilePictureData = UIImage(named: "defaulUserPic")?.jpegData(compressionQuality: 1)
                }
            }
    }
    
    func registerUser() {
        isLoading = true
        endEditingCloseKeyboards()
        Task {
            do {
//                if userProfilePictureData == nil {
//                    // Use the default image if no photo selected
//                    userProfilePictureData = UIImage(systemName: "person.circle.fill")?.jpegData(compressionQuality: 1.0)
//                }
                
                // Creating User
                try await Auth.auth().createUser(withEmail: emailID, password: password)
                // Upload userImage into Firebase Profile
                guard let userUID = Auth.auth().currentUser?.uid else {return}
                guard let imageData = userProfilePictureData else {return}
                let storageRef = Storage.storage().reference().child("Profile_Images").child(userUID)
                let _ = try await storageRef.putDataAsync(imageData)
                // Down.. user photo url
                let downloadURL = try await storageRef.downloadURL()
                // Creating firestore object - USER
                let users = UserModel(userUID: userUID, fullname: fullname, nickname: nickname, userEmail: emailID, categoryOfProg: "", stackOfTechology: "", userJobExperience: "", userCountry: "", userLanguage: "", userProfileURL: downloadURL)
                //Save user INFO into firestore database
                let _ = try Firestore.firestore().collection("Users").document(userUID).setData(from: users, completion: {
                    error in
                    if error == nil {
                        print("Saved User successfully")
                        userNameStored = nickname
                        self.userUID = userUID
                        profileURL = downloadURL
                        logStatus = true
                    } else {
                        print("NOOOO Saved User successfully")
                    }
                })
            } catch {
//                try await Auth.auth().currentUser?.delete()
                await setError(error)
            }
        }
    }
    
    func setError(_ error: Error) async {
        await MainActor.run {
            errorMessage = error.localizedDescription
            showError.toggle()
            isLoading = false
        }
    }
}

#Preview {
    RegistrationView()
}

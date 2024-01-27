//
//  LoginView.swift
//  JoinACode
//
//  Created by Ostap Artym on 26.01.2024.
//

import SwiftUI
import PhotosUI
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseFirestoreSwift
//import FirebaseFirestore

struct LoginView: View {
    
    @State var emailID: String = ""
    @State var password: String = ""
    //View Properties
    @State var createAccount: Bool = false
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    
    @State var isLoading: Bool = false
    
    @AppStorage("log_status") var logStatus: Bool = false
    @AppStorage("user_profile_url") var profileURL: URL?
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    
    var body: some View {
        VStack {
            Text("Join A Code 🚀")
                .font(.title.bold())
                .foregroundStyle(.white)
                
            Spacer()
            
            VStack(spacing: 15) {
                
                CustomTextField(objectOfTextField: $emailID, textFieldType: TextField("", text: $emailID, prompt: Text("Email").foregroundColor(.gray))
                                    .keyboardType(.emailAddress) // Додайте цей рядок
                                , textContentType: .emailAddress)
                
                CustomTextField(objectOfTextField: $password, textFieldType: SecureField("", text: $password, prompt: Text("Password").foregroundColor(.gray)))

                
                Button {
                    resetPassword()
                } label: {
                    Text("Reset password ?")
                        .font(.callout)
                        .fontWeight(.medium)
                        .hAlignment(.trailing)
                        .tint(.white.opacity(0.8))
                        .padding(.top, 20)
                }
                
                Button {
                    loginUser()
                } label: {
                    Text("SIGN IN")
                        .foregroundStyle(Color.white)
                        .fontWeight(.bold)
                        .hAlignment(.center)
                        .buttonStyleFill(.blue.opacity(0.5))
                }
            }
            .padding(.top, 20)
            
            Spacer()
            
            VStack(spacing: 5) {
                Text("Dont have an account?")
                    .foregroundStyle(Color.gray)
                
                Button("Register Now") {
                    createAccount.toggle()
                }
                .font(.title2.bold())
                .foregroundStyle(.white)
            }
            
            
            
        }
        .padding(15)
        .overlay(content: {
            LoadingView(show: $isLoading)
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
        .fullScreenCover(isPresented: $createAccount) {
            RegistrationView()
        }
        .alert(errorMessage, isPresented: $showError) {
            
        }
    }
    
    func loginUser() {
        isLoading = true
        endEditingCloseKeyboards()
        Task {
            do {
                try await Auth.auth().signIn(withEmail: emailID, password: password)
                print("User Found")
                try await fetchUser()
            } catch {
                await setError(error)
            }
        }
    }
    
    func fetchUser() async throws {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        let user = try await Firestore.firestore().collection("Users").document(userID).getDocument(as: UserModel.self)
        await MainActor.run(body: {
            userUID = userID
            userNameStored = user.nickname

            profileURL = user.userProfileURL
            logStatus = true
        })
    }
    
    func setError(_ error: Error) async {
        await MainActor.run {
            errorMessage = error.localizedDescription
            showError.toggle()
            isLoading = false
        }
    }
    
    func resetPassword() {
        Task {
            do {
                try await Auth.auth().sendPasswordReset(withEmail: emailID)
                print("Link Sent")
            } catch {
                await setError(error)
            }
        }
    }
}

#Preview {
    LoginView()
}

struct BlurView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        
    }
    
}

//MARK: RegistrationView
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
                        Image(systemName: "person.circle.fill")
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
    }
    
    func registerUser() {
        isLoading = true
        endEditingCloseKeyboards()
        Task {
            do {
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

extension View {
    
    func endEditingCloseKeyboards() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func hAlignment (_ alignment: Alignment) -> some View {
        self
            .frame(maxWidth: .infinity, alignment: alignment)
    }
    
    func vAlignment (_ alignment: Alignment) -> some View {
        self
            .frame(maxHeight: .infinity, alignment: alignment)
    }
    
    // Необхідно переробити у Style View Extension
    
    func borderLine(_ width: CGFloat, _ color: Color) -> some View {
        self
            .padding(.horizontal, 15)
            .padding(.vertical, 15)
            .background {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .stroke(color, lineWidth: width)
            }
    }
    
    func buttonStyleFill(_ color: Color) -> some View {
        self
            .padding(.horizontal, 15)
            .padding(.vertical, 15)
            .background {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(color)
            }
    }
    
    func buttonDisableAndOpacity(_ items: Bool) -> some View {
        self
            .disabled(items)
            .opacity(items ? 0.4 : 1)
    }
}

struct CustomTextField<TextFieldType>: View where TextFieldType: View {

    @Binding var objectOfTextField: String
    var textFieldType: TextFieldType
    var textContentType: UITextContentType?

    var body: some View {
            textFieldType
                .padding()
                .textContentType(textContentType)
                .background(objectOfTextField.isEmpty ? Color.gray.opacity(0.3) : Color.gray.opacity(0.6))
                .cornerRadius(12)
                .foregroundColor(Color.white)
                .font(.headline)
                .accentColor(Color.white.opacity(0.8))
    }
}

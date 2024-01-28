//
//  LoginView.swift
//  JoinACode
//
//  Created by Ostap Artym on 26.01.2024.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

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

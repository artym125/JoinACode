//
//  HomeView.swift
//  JoinACode
//
//  Created by Ostap Artym on 29.01.2024.
//


import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore

struct HomeView: View {
    
    @State private var userProfile: UserModel?
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    @State var isLoading: Bool = false
    
    @AppStorage("log_status") var logStatus: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if let userProfile {
                    ReusableUserProfileContent(user: userProfile, showUserContent: false, showUserProjectContent: true)
                        .refreshable {
                            self.userProfile = nil
                            await fetchUserData()
                        }
                } else {
                    ZStack {
                        Image("TestImage1")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .ignoresSafeArea()
                        
                        BlurView()
                            .ignoresSafeArea()
                        
                        ProgressView()
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Logout") {
                            logout()
                        }
                        
                        Button("Delete Account", role: .destructive) {
                            deleteAccount()
                        }
                        
                    } label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.init(degrees: 90))
                            .tint(.white)
                            .scaleEffect(0.9)
                    }
                }
            }
            .background {
                Image("TestImage1")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
                
                BlurView()
                    .ignoresSafeArea()
            }
        }

        .overlay {
            LoadingView(show: $isLoading)
        }
        .alert(errorMessage, isPresented: $showError) {
        }
        .task {
            if userProfile != nil {return}
            await fetchUserData()
        }
        .preferredColorScheme(.dark)
    }
    
    func fetchUserData() async {
        guard let userUID = Auth.auth().currentUser?.uid else {return}
        guard let user = try? await Firestore.firestore().collection("Users").document(userUID).getDocument(as: UserModel.self) else {return}
        await MainActor.run {
            userProfile = user
        }
    }
    
    func logout() {
        
//        isLoading = true
        try? Auth.auth().signOut()
        userProfile = nil
        logStatus = false
    }
    
    func deleteAccount() {
        isLoading = true
        Task {
            do {
                guard let userUID = Auth.auth().currentUser?.uid else {return}
                let reference = Storage.storage().reference().child("Profile_Images").child(userUID)
                try await reference.delete()
                try await Firestore.firestore().collection("Users").document(userUID).delete()
                try await Auth.auth().currentUser?.delete()
                userProfile = nil
                logStatus = false
            } catch {
                await setError(error)
            }

        }
    }
    
    func setError(_ error: Error) async {
        await MainActor.run {
            isLoading = false
            errorMessage = error.localizedDescription
            showError.toggle()
        }
    }
}

#Preview {
    HomeView()
}

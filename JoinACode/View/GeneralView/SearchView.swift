//
//  SearchView.swift
//  JoinACode
//
//  Created by Ostap Artym on 29.01.2024.
//

import SwiftUI
import FirebaseFirestore

struct SearchView: View {
    
    @State private var fetchedUsers: [UserModel] = []
    @State private var searchText: String = ""
    
    @Environment(\.dismiss) private var dismiss
    
    
    var body: some View {
        
            List {
                ForEach(fetchedUsers) { user in
                    NavigationLink{
                        ReusableUserProfileContent(user: user)
                    } label: {
                        Text(user.fullname)
                            .font(.callout)
                            .hAlignment(.leading)
                    }
                }
            }
            .listStyle(.plain)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Search User")
            .searchable(text: $searchText)
            .onSubmit(of: .search) {
                Task {await searchUsers()}
            }
            .onChange(of: searchText, perform: { newValue in
                if newValue.isEmpty {
                    fetchedUsers = []
                }
            })
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel"){
                        dismiss()
                    }
                    .tint(.black)
                }
            }
        
    }
    
    func searchUsers() async {
        do {
            //need to do correct search
            let queryLowerCased = searchText.lowercased()
            let queryUpperCased = searchText.uppercased()
            
            let documents = try await Firestore.firestore().collection("Users")
                .whereField("fullname", isGreaterThanOrEqualTo: searchText)
                .whereField("fullname", isLessThanOrEqualTo: "\(searchText)\u{f8ff}")
                .getDocuments()
            
            let users = try documents.documents.compactMap { doc -> UserModel? in
                try doc.data(as: UserModel.self)
            }
            await MainActor.run {
                fetchedUsers = users
            }
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
}

#Preview {
    SearchView()
}

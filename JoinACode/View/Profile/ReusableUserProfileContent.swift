//
//  ReusableUserProfileContent.swift
//  JoinACode
//
//  Created by Ostap Artym on 28.01.2024.
//

import SwiftUI
import SDWebImageSwiftUI

struct ReusableUserProfileContent: View {
    var user: UserModel
    @State private var fetchedProjects: [ProjectsModel] = []
    var showUserContent: Bool = true
    var showUserProjectContent: Bool = true

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack {
                if showUserContent{
                    VStack {
                        HStack(spacing: 10) {
                            WebImage(url: user.userProfileURL).placeholder{
                                Image("defaulUserPic")
                                    .resizable()
                                
                            }
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text(user.fullname)
                                    .font(.title2.bold())
                                Text(user.nickname)
                                    .font(.title2.bold())
                            }
                            .hAlignment(.leading)
                        }
                        
                        
                        VStack(alignment: .leading) {
                            
                            Text(user.userEmail)
                            
                            Text(user.categoryOfProg)
                            
                            Text(user.stackOfTechology)
                            
                            Text(user.userJobExperience)
                            
                            Text(user.userCountry)
                            
                            Text(user.userLanguage)
                            
                        }
                        .font(.title3)
                        .fontWeight(.semibold)
                        .hAlignment(.leading)
                    }
                }
                
                if showUserProjectContent {
                    VStack {
                        Text("Projects")
                            .font(.title.bold())
                            .hAlignment(.leading)
                            .padding(.vertical, 15)
                        
                        ReusableProjectsView(basedOnUID: true, uid: user.userUID, projects: $fetchedProjects)
                    }
                }
                
            }
            .padding(25)
        }
    }
}

//#Preview {
//    ReusableUserProfileContent(user: testUser1)
//}

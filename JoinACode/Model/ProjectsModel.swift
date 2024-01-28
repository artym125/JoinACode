//
//  ProjectsModel.swift
//  JoinACode
//
//  Created by Ostap Artym on 28.01.2024.
//

import SwiftUI
import FirebaseFirestoreSwift
import Firebase

struct ProjectsModel: Identifiable, Codable {
    @DocumentID var id: String?
    var text: String
    var imageURL: URL?
    var imageReferenceID: String = ""
    var publishedDate: Date = Date()
    var likedIDs: [String] = []
    var dislikedIDs: [String] = []
    //USER INFO
    var userName: String
    var userUID: String
    var userCountry: String
    var userLanguage: String
    var userProfileURL: URL
    
    enum CodingKeys: CodingKey {
        case id
        case text
        case imageURL
        case imageReferenceID
        case publishedDate
        case likedIDs
        case dislikedIDs
        //USER INFO
        case userName
        case userUID
        case userCountry
        case userLanguage
        case userProfileURL
    }
}


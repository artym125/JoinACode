//
//  UserModel.swift
//  JoinACode
//
//  Created by Ostap Artym on 27.01.2024.
//

import SwiftUI
import FirebaseFirestoreSwift
import FirebaseFirestore

struct UserModel: Identifiable, Codable {
    @DocumentID var id: String?
    var userUID: String
    var fullname: String
    var nickname: String
    var userEmail: String
    var categoryOfProg: String
    var stackOfTechology: String
    var userJobExperience: String
    var userCountry: String
    var userLanguage: String
    var userProfileURL: URL
    
    enum CodingKeys: CodingKey {
        case id
        case userUID
        case fullname
        case nickname
        case userEmail
        case categoryOfProg
        case stackOfTechology
        case userJobExperience
        case userCountry
        case userLanguage
        case userProfileURL
    }
}

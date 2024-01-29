//
//  ProjectsModel.swift
//  JoinACode
//
//  Created by Ostap Artym on 28.01.2024.
//

import SwiftUI
import FirebaseFirestoreSwift
import Firebase

struct ProjectsModel: Identifiable, Codable, Equatable {
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

let testProject1 = ProjectsModel(
    id: "1",
    text: "Це тестовий проект 1",
    imageURL: URL(string: "https://example.com/image1.jpg"),
    imageReferenceID: "image1",
    publishedDate: Date(),
    likedIDs: ["user1", "user2"],
    dislikedIDs: ["user3"],
    userName: "John Doe",
    userUID: "user1",
    userCountry: "Україна",
    userLanguage: "українська",
    userProfileURL: URL(string: "https://example.com/user1_profile.jpg")!
)

let testProject2 = ProjectsModel(
    id: "2",
    text: "Це тестовий проект 2",
    imageURL: URL(string: "https://example.com/image2.jpg"),
    imageReferenceID: "image2",
    publishedDate: Date(),
    likedIDs: ["user2"],
    dislikedIDs: [],
    userName: "Jane Smith",
    userUID: "user2",
    userCountry: "Сполучені Штати",
    userLanguage: "англійська",
    userProfileURL: URL(string: "https://example.com/user2_profile.jpg")!
)

// Тут ви можете створити інші тестові об'єкти за аналогією


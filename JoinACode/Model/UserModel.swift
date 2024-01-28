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

let testUser1 = UserModel(
    id: "1",
    userUID: "uid123",
    fullname: "John Doe",
    nickname: "johndoe123",
    userEmail: "john.doe@example.com",
    categoryOfProg: "iOS Developer",
    stackOfTechology: "Swift, SwiftUI, UIKit",
    userJobExperience: "5 years",
    userCountry: "USA",
    userLanguage: "English",
    userProfileURL: URL(string: "https://images.app.goo.gl/uSNfAqJnxSHwcorJ6")!
)

let testUser2 = UserModel(
    id: "2",
    userUID: "uid456",
    fullname: "Jane Smith",
    nickname: "janesmith789",
    userEmail: "jane.smith@example.com",
    categoryOfProg: "Backend Developer",
    stackOfTechology: "Node.js, Express, MongoDB",
    userJobExperience: "3 years",
    userCountry: "Canada",
    userLanguage: "French",
    userProfileURL: URL(string: "https://example.com/janesmith")!
)

// Можете додати більше тестових користувачів, якщо потрібно.

// Додаємо всі тестові користувачі до масиву
let testUsers = [testUser1, testUser2]

// Тепер ви можете використовувати масив testUsers для виведення чи обробки тестових даних у вашому додатку.


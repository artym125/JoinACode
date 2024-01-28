//
//  CustomTextField.swift
//  JoinACode
//
//  Created by Ostap Artym on 28.01.2024.
//

import SwiftUI

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

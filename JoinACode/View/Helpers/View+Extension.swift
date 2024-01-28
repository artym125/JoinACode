//
//  View+Extension.swift
//  JoinACode
//
//  Created by Ostap Artym on 28.01.2024.
//

import SwiftUI

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

//
//  LoadingView.swift
//  JoinACode
//
//  Created by Ostap Artym on 28.01.2024.
//

import SwiftUI

struct LoadingView: View {
    
    @Binding var show: Bool
    
    var body: some View {
        
        ZStack {
            if show {
                Group {
                    Rectangle()
                        .fill(.black.opacity(0.45))
                        .ignoresSafeArea()
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .green))
                        .padding(15)
                        .background(.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                        .scaleEffect(2.0)
                }
            }
        }
        .animation(.easeInOut(duration: 0.95), value: show)
        
    }
}

//struct LoadingView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoadingView(show: .constant(true)) // Додайте власний колір фону для попереднього перегляду
//    }
//}

//dfdf

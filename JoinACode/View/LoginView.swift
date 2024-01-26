//
//  LoginView.swift
//  JoinACode
//
//  Created by Ostap Artym on 26.01.2024.
//

import SwiftUI

struct LoginView: View {
    
    @State var emailID: String = ""
    @State var password: String = ""
    
    @State var createAccount: Bool = false
    
    var body: some View {
        
        NavigationStack {
            
                VStack(spacing: 0) {
                    
                    //Custom Nav Title Color
                    Divider()
                    .background(
                    LinearGradient(colors: [.blue, .yellow],
                    startPoint: .leading,
                    endPoint: .trailing)
                    .opacity(0.5)
                    .shadow(.drop(radius: 2, y: 2)),
                    ignoresSafeAreaEdges: .top)
                    
                    VStack {
                        Text("Welcome Back")
                            .font(.title3.bold())
                            .hAlignment(.leading)
                        
                        VStack(spacing: 10) {
                            
                            TextField("Email",
                                      text: $emailID)
                                .textContentType(.emailAddress)
                                .borderLine(1, .black.opacity(0.1))
                                .padding(.top, 12)
                            
                            SecureField("Password",
                                      text: $password)
                                .textContentType(.emailAddress)
                                .borderLine(1, .black.opacity(0.1))
                                .padding(.top, 15)
                            
                            Button {
                                
                            } label: {
                                Text("Reset password ?")
                                    .font(.callout)
                                    .fontWeight(.medium)
                                    .hAlignment(.trailing)
                                    .tint(.black)
                                    .padding(.top, 20)
                            }
                            
                            Button {
                                
                            } label: {
                                Text("SIGN IN")
                                    .foregroundStyle(Color.black)
                                    .hAlignment(.center)
                                    .buttonStyleFill(.brown)
                            }
                            .padding(.top, 15)
                        }
                        
                        HStack {
                            Text("Dont have an account?")
                                .foregroundStyle(Color.gray)
                            
                            Button("Register Now") {
                                createAccount.toggle()
                            }
                            .fontWeight(.bold)
                            .foregroundStyle(.black)
                        }
                        .font(.callout)
                        .vAlignment(.bottom)
                    }
                    .padding(15)
                    //Color main VStack
                    .background(LinearGradient(colors: [.green.opacity(0.1), .green.opacity(0.6)], startPoint: .top, endPoint: .bottom)
//                        .opacity(0.2))
                                )
            }
            .navigationTitle("SING IN")
            .fullScreenCover(isPresented: $createAccount) {
                RegistrationView()
            }
        }
    }
}

#Preview {
    LoginView()
}

//MARK: RegistrationView
struct RegistrationView: View {
    
    @State var emailID: String = ""
    @State var password: String = ""
    @State var userName: String = ""
    
    @Environment(\.dismiss) var dismissToSingView
    
    
    var body: some View {
        NavigationStack {
            
                VStack(spacing: 0) {
                    
                    //Custom Nav Title Color
                    Divider()
                    .background(
                    LinearGradient(colors: [.blue, .green],
                    startPoint: .leading,
                    endPoint: .trailing)
                    .opacity(0.5)
                    .shadow(.drop(radius: 2, y: 2)),
                    ignoresSafeAreaEdges: .top)
                    
                    VStack {
                        Text("Welcome Back")
                            .font(.title3.bold())
                            .hAlignment(.leading)
                        
                        VStack(spacing: 10) {
                            
                            TextField("User Name",
                                      text: $userName)
                                .textContentType(.emailAddress)
                                .borderLine(1, .black.opacity(0.1))
                                .padding(.top, 12)
                            
                            TextField("Email",
                                      text: $emailID)
                                .textContentType(.emailAddress)
                                .borderLine(1, .black.opacity(0.1))
                                .padding(.top, 12)
                            
                            SecureField("Password",
                                      text: $password)
                                .textContentType(.emailAddress)
                                .borderLine(1, .black.opacity(0.1))
                                .padding(.top, 15)
                            
                            Button {
                                
                            } label: {
                                Text("SIGN UP")
                                    .foregroundStyle(Color.black)
                                    .hAlignment(.center)
                                    .buttonStyleFill(.brown)
                            }
                            .padding(.top, 15)
                        }
                        
                        HStack {
                            Text("Already have account?")
                                .foregroundStyle(Color.gray)
                            
                            Button("Login Now") {
                                dismissToSingView()
                            }
                            .fontWeight(.bold)
                            .foregroundStyle(.black)
                        }
                        .font(.callout)
                        .vAlignment(.bottom)
                    }
                    .padding(15)
                    //Color main VStack
                    .background(LinearGradient(colors: [.green.opacity(0.1), .green.opacity(0.6)], startPoint: .top, endPoint: .bottom)
//                        .opacity(0.2))
                                )
            }
            .navigationTitle("SIGN UP")
        }
    }
}

extension View {
    
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
    
    
}

//Test

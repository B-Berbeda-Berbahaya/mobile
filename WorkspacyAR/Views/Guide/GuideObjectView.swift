//
//  GuideObjectView.swift
//  WorkspacyAR
//
//  Created by Mochammad Athar Humam Ghazanfar on 15/07/26.
//

import SwiftUI

struct GuideObjectView: View {
    let onDismiss: (() -> Void)
    
    var body: some View {
        ZStack{
            
            GeometryReader { geo in
                ZStack{
                    Color.black
                        .opacity(0.45)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 61)
                    {
                        Text("How to use the object")
                            .font(.system(size: 50, weight: .medium))
                        HStack(spacing: 105){
                            Image("1finger")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 130, height: 200)
                            Text("1 Finger = Move Object")
                                .font(.system(size: 30, weight: .regular))
                        }
                        HStack(spacing: 105){
                            Image("2finger")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 130, height: 200)
                            Text("1 Finger = Move Object")
                                .font(.system(size: 30, weight: .regular))
                        }
                        HStack(spacing: 105){
                            Image("3finger")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 130, height: 200)
                            Text("1 Finger = Move Object")
                                .font(.system(size: 30, weight: .regular))
                        }
                        Button {
                            onDismiss()
                        } label: {
                            Text("Understood")
                                .font(.system(size: 26, weight: .regular))
                                .frame(width: 180, height: 44)
                        }
                        .buttonStyle(.borderedProminent)
                       
                    }
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.all, )
                }
                .ignoresSafeArea()
            }

        }
    }
}

#Preview {
    GuideObjectView(onDismiss: {})
}

//
//  GuideScanningView.swift
//  WorkspacyAR
//
//  Created by Mochammad Athar Humam Ghazanfar on 15/07/26.
//

import SwiftUI

struct GuideScanningView: View {
    
    let onDismiss: (() -> Void)
    
    var body: some View {
        ZStack{
            
            GeometryReader { geo in
                ZStack{
                    Color.black
                        .opacity(0.45)
                        .ignoresSafeArea()
                    VStack(spacing: 50)
                    {
                        Text("Stand up and face the table")
                            .font(.system(size: 50, weight: .medium))
                        
                        Image("Scanning")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 416, height: 346)
                        
                        Text("Hold your device at chest height")
                            .font(.system(size: 50))
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
                }
                .ignoresSafeArea()
            }

        }
        
            
    }
}

#Preview {
    GuideScanningView(onDismiss: {})
}

//
// This source file is part of the StanfordBDHG VisionProSurgery project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct Start: View {
    @State private var showingSetUp = false
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                VStack(spacing: 8) {
                    Text("Spezi VP Surgery")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Vision pro enabled streaming system")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Image("icon")
                    .resizable()
                    .frame(width: 140, height: 140)
                    .cornerRadius(20)
                    .aspectRatio(contentMode: .fit)
                    .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                
                Spacer()
                
                Text("Connect your Vision Pro to a live laproscopic video tower stream over your local IP. Must have Spezi Server app installed on your laptop to start server.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Button(action: {
                    showingSetUp = true
                }) {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 250, height: 50)
                        .cornerRadius(25)
                }
                .fullScreenCover(isPresented: $showingSetUp) {
                    SetUp()
                }

                Spacer()
            }
            .padding(.top, 60)
            .padding(.bottom, 30)
        }
        .frame(width: 500, height: 600)
    }
}

#Preview {
    Start()
}

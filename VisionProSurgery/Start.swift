// This source file is part of the StanfordBDHG VisionProSurgery project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT

import SwiftUI

struct HeaderView: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("ONBOARDING_APP_TITLE")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("ONBOARDING_APP_SUBTITLE")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}

struct IconView: View {
    var body: some View {
        Image("icon")
            .resizable()
            .frame(width: 140, height: 140)
            .cornerRadius(20)
            .aspectRatio(contentMode: .fit)
            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
            .accessibilityLabel("ACCESSIBILITY_ICON_LABEL")
    }
}

struct StartButton: View {
    @Binding var showingSetUp: Bool
    
    var body: some View {
        Button(action: {
            showingSetUp = true
        }) {
            Text("START_BUTTON_TITLE")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(width: 250, height: 50)
                .cornerRadius(25)
        }
        .fullScreenCover(isPresented: $showingSetUp) {
            SetUp()
        }
    }
}

struct Start: View {
    @State private var showingSetUp = false
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                HeaderView()
                IconView()
                Spacer()
                Text("ONBOARDING_DESCRIPTION")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                StartButton(showingSetUp: $showingSetUp)
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

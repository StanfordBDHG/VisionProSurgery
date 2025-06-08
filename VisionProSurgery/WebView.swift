//
// This source file is part of the StanfordBDHG VisionProSurgery project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI
import WebKit

struct ContentView: View {
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            VStack {
                if let url = URL(string: SetUp.fullURL) {
                    WebView(url: url)
                        .edgesIgnoringSafeArea(.all)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Text("Invalid URL")
                }
                Spacer()
            }
        }
            .frame(width: 640, height: 480)
    }
}


struct WebView: UIViewRepresentable {
    let url: URL
    

    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}


#Preview {
    ContentView()
}

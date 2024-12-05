// This source file is part of the StanfordBDHG VisionProSurgery project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT

import SwiftUI

struct PortInputView: View {
    @Binding var portNums: [String]

    var body: some View {
        HStack {
            ForEach(0..<4, id: \ .self) { index in
                TextField("", text: $portNums[index])
                    .multilineTextAlignment(.center)
                    .fontWeight(.bold)
                    .keyboardType(.numberPad)
                    .frame(width: 50, height: 50)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
            }
        }
    }
}

struct IPAddressInputView: View {
    @Binding var ipAddress: String

    var body: some View {
        TextField("IP_TEXTFIELD_PLACEHOLDER", text: $ipAddress)
            .padding(.leading, 10)
            .cornerRadius(20)
            .foregroundColor(.white)
            .frame(width: 300, height: 50)
            .background(Color(.systemGray6))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white, lineWidth: 1)
            )
    }
}

struct ConnectionButton: View {
    @Binding var showStream: Bool
    @Binding var showingAlert: Bool
    @Binding var saveConnection: Bool
    @Binding var portNums: [String]
    @Binding var ipAddress: String

    var body: some View {
        Button("CONNECTION_BUTTON_TITLE") {
            Task {
                await establishConnection()
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("CONNECTION_ALERT_TITLE"),
                message: Text("CONNECTION_ALERT_MESSAGE"),
                dismissButton: .default(Text("Ok"))
            )
        }
        .sheet(isPresented: $showStream) {
            ContentView()
        }
    }

    private func establishConnection() async {
        let isConnected = await checkForConnection()
        if isConnected {
            if saveConnection {
                saveConnectionDetails()
            }
            showStream = true
        } else {
            showingAlert = true
        }
    }

    private func checkForConnection() async -> Bool {
        let portString = portNums.joined()
        let url = "http://\(ipAddress):\(portString)/video"
        SetUp.fullURL = url
        guard let url = URL(string: url) else {
            return false
        }

        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                return true
            }
        } catch {
            return false
        }
        return false
    }

    private func saveConnectionDetails() {
        UserDefaults.standard.set(ipAddress, forKey: "ipAddress")
        UserDefaults.standard.set(portNums, forKey: "portNums")
    }
}

struct SaveConnectionToggle: View {
    @Binding var saveConnection: Bool

    var body: some View {
        HStack {
            Button(action: {
                saveConnection.toggle()
            }) {
                Circle()
                    .stroke(saveConnection ? Color.gray : Color.white, lineWidth: 2)
                    .frame(width: 25, height: 25)
                    .background(saveConnection ? Color.gray : Color.clear)
                    .overlay(
                        Image(systemName: saveConnection ? "checkmark" : "")
                            .foregroundColor(.white)
                            .accessibilityHidden(true)
                    )
            }
            Text("SAVE_BUTTON_DESCRIPTION")
                .foregroundColor(.white)
                .padding(.leading, 10)
        }
    }
}

struct SetUp: View {
    static var fullURL: String = ""

    @State private var portNums: [String] = Array(repeating: "", count: 4)
    @State private var ipAddress: String = ""
    @State private var showAlert: Bool = false
    @State private var showStream: Bool = false
    @State private var saveConnection: Bool = false

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack {
                headerView
                inputFields
                connectionControls
            }
        }
        .cornerRadius(20)
        .onAppear {
            loadConnectionDetails()
        }
    }

    private var headerView: some View {
        VStack {
            Text("PORT_ENTRY_LABEL")
                .font(.largeTitle)
            Text("PORT_ENTRY_SUBTITLE")
                .font(.title)
                .fontWeight(.light)
        }
    }

    private var inputFields: some View {
        VStack(spacing: 20) {
            PortInputView(portNums: $portNums)
            IPAddressInputView(ipAddress: $ipAddress)
        }
    }

    private var connectionControls: some View {
        VStack(spacing: 20) {
            ConnectionButton(
                showStream: $showStream,
                showingAlert: $showAlert,
                saveConnection: $saveConnection,
                portNums: $portNums,
                ipAddress: $ipAddress
            )
            SaveConnectionToggle(saveConnection: $saveConnection)
        }
    }

    private func loadConnectionDetails() {
        if let savedIp = UserDefaults.standard.string(forKey: "ipAddress") {
            ipAddress = savedIp
        }
        if let savedPorts = UserDefaults.standard.array(forKey: "portNums") as? [String] {
            portNums = savedPorts
        }
    }
}

#Preview {
    SetUp()
}

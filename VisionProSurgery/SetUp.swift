import SwiftUI

struct SetUp: View {
    @State private var portNums: [String] = Array(repeating: "", count: 4)
    @State private var ipAddress: String = ""
    @State private var isConnected: Bool = false
    @State private var showAlert: Bool = false
    @State private var showContentView: Bool = false
    @State private var saveConnection: Bool = false
    static public var fullURL: String = ""

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            VStack {
                Text("Enter Port Pin")
                    .font(.largeTitle)
                Text("Set up video stream")
                    .font(.title)
                    .fontWeight(.light)
                HStack {
                    ForEach(0..<4, id: \.self) { index in
                        TextField("", text: $portNums[index])
                            .multilineTextAlignment(.center)
                            .fontWeight(.bold)
                            .keyboardType(.numberPad)
                            .frame(width: 50, height: 50)
                            .background(Color(.systemGray6))
                            .padding(.vertical, 10)
                            .cornerRadius(20)
                    }
                }
                TextField("Enter IP address", text: $ipAddress)
                    .padding(.leading, 10)
                    .cornerRadius(20)
                    .foregroundColor(.white)
                    .frame(width: 300, height: 50)
                    .background(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white, lineWidth: 1)
                    )
                    .padding(.bottom, 20)
                Button("Establish Connection") {
                    Task {
                        await establishConnection()
                    }
                }
                .padding(.bottom, 20)
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
                            )
                            .cornerRadius(12.5)
                    }
                    Text("Save IP and Port Number")
                        .foregroundColor(.white)
                        .padding(.leading, 10)
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Connection Failed"),
                        message: Text("You entered an invalid IP address or port. Make sure your video stream has been started using Spezi Server."),
                        dismissButton: .default(Text("Ok"))
                    )
                }
                .sheet(isPresented: $showContentView) {
                    ContentView()
                }
            }
        }
        .cornerRadius(20)
        .onAppear {
            loadConnectionDetails()
        }
    }

    func establishConnection() async {
        let isConnected = await checkForConnection()
        if isConnected {
            if saveConnection {
                saveConnectionDetails()
            }
            showContentView = true
        } else {
            showAlert = true
        }
    }

    func checkForConnection() async -> Bool {
        var portString = ""
        for portNum in portNums {
            portString += portNum
        }
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
            } else {
                return false
            }
        } catch {
            return false
        }
    }

    func saveConnectionDetails() {
        UserDefaults.standard.set(ipAddress, forKey: "ipAddress")
        UserDefaults.standard.set(portNums, forKey: "portNums")
    }

    func loadConnectionDetails() {
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

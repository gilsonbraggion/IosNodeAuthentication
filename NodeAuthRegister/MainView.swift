import SwiftUI
import Combine

struct MainView: View {
    @State private var email = "gilson.braggion@gmail.com"
    @State private var password = "1"
    @State private var token: String?
    @State private var queixas: [Queixa] = []
    @State private var isAuthenticated = false
    @State private var isRegistering = false
    
    @State private var message = ""
    
    var body: some View {
        
        NavigationStack {
            VStack {
                    
                Spacer()
                
                if isAuthenticated {
                    QueixaView()
                } else {
                    TextField("email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocorrectionDisabled(true) // Disable autocorrect
                        .textInputAutocapitalization(.never) // Prevent capital letters
                        .keyboardType(.emailAddress) // Use email-specific keyboard
                        .padding()
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocorrectionDisabled(true)
                        .padding()
                    
                    Button("Login") {
                        novoLogin()
                    }.padding()
                    .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    
                    Text(message)
                        .foregroundColor(.red)
                        .padding()

                    
                    Spacer();
                    NavigationLink(destination: RegisterUser()) {
                        Text("Go to Detail View")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }.padding()
        }
    }
    
    func login() {
        guard let url = URL(string: "http://localhost:3000/login") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["email": $email, "password": $password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, _ in
            guard let data = data else {
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: String],
               let token = json["token"] {
                DispatchQueue.main.async {
                    self.token = token
                    self.isAuthenticated = true
                }
            }
        }.resume()
    }
    
    
    func novoLogin( ) {
        let newUser = User(username: "", email: email, password: password, fullName: "")
        AuthService.shared.login(user: newUser) { success, responseMessage in
            DispatchQueue.main.async {
                if success {
                    self.token = token
                    self.isAuthenticated = true
                    
                } else {
                    message = responseMessage ?? "Login Failed. Please try again."
                }
            }
        }
    }
    
    func fetchCustomers() {
        guard let url = URL(string: "http://localhost:3097/api/queixa/buscarTodos"), let token = token else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data, let queixas = try? JSONDecoder().decode([Queixa].self, from: data) else { return }
            DispatchQueue.main.async {
                self.queixas = queixas
            }
        }.resume()
    }
}

#Preview {
    MainView()
}

import SwiftUI

struct RegisterUser: View {
    
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var fullName = ""
    @State private var message = ""
    
    var body: some View {
        VStack {
            TextField("Username", text: $username)
            TextField("Email", text: $email)
            SecureField("Password", text: $password)
            TextField("Full Name", text: $fullName)
            
            Button(action: registerUser) {
                Text("Register")
            }
            
            Text(message)
                .foregroundColor(.red)
                .padding()
        }
        .padding()
    }
    
    func registerUser() {
        let newUser = User(username: username, email: email, password: password, fullName: fullName)
        
        AuthService.shared.registerUser(user: newUser) { success, responseMessage in
            DispatchQueue.main.async {
                if success {
                    message = "Registration successful!"
                    // Optionally call for further user data after registration
                    
                    UserService.shared.getUserData { success, message in
                        
                        print(message ?? "")
                        
                        self.message = message ?? "Failed to get user data"
                    }
                } else {
                    message = responseMessage ?? "Registration failed"
                }
            }
        }
    }
}

#Preview {
    RegisterUser()
}

import Foundation

class AuthService {
    static let shared = AuthService()
    
    let baseURL = "http://localhost:3097/api/auth"
    
    func registerUser(user: User, completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: "\(baseURL)/register") else {
            completion(false, "Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(user)
            request.httpBody = jsonData
        } catch {
            completion(false, "Failed to encode user data")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(false, "Request failed: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                completion(false, "No data received")
                return
            }
            
            do {
                
                let registerResponse = try JSONDecoder().decode(RegisterResponse.self, from: data)

                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 201 {
                        UserDefaults.standard.set(registerResponse.token, forKey: "token")
                        completion(true, "Usuário registrado com sucesso")
                    } else {
                        completion(false, registerResponse.mensagem)
                    }
                }
            } catch {
                completion(false, "Failed to decode response")
            }
        }
        
        task.resume()
    }
    
    
    func login(user: User, completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: "\(baseURL)/login") else {
            completion(false, "Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(user)
            request.httpBody = jsonData
        } catch {
            completion(false, "Failed to encode user data")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(false, "Request failed: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                completion(false, "No data received")
                return
            }
            
            do {
                if let httpResponse = response as? HTTPURLResponse {
                    
                    print(httpResponse.statusCode);
                    
                    if httpResponse.statusCode == 200 {
                        UserDefaults.standard.set(data, forKey: "token")
                        completion(true, "Usuário logado com sucesso com sucesso")
                    } else {
                        let registerResponse = try JSONDecoder().decode(RegisterResponse.self, from: data)
                        completion(false, registerResponse.mensagem)
                    }
                }
            } catch {
                completion(false, "Failed to decode response")
            }
        }
        
        task.resume()
    }
}

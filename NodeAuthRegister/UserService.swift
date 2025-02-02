import Foundation

class UserService {
    static let shared = UserService()
    
    let baseURL = "http://localhost:3000"
    
    func getUserData(completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: "\(baseURL)/user/profile") else {
            completion(false, "Invalid URL")
            return
        }
        
        guard let token = UserDefaults.standard.string(forKey: "jwtToken") else {
            completion(false, "User not authenticated")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(false, "Request failed: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                completion(false, "No data received")
                return
            }
            
            // Process the user data response
            completion(true, "User data retrieved successfully")
        }
        
        task.resume()
    }
}

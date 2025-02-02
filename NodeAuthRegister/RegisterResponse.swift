import Foundation

struct RegisterResponse: Codable {
    var tipo: String
    var mensagem: String
    var detalhes: String
    var token : String?
    
}

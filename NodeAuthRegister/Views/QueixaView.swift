import SwiftUI

struct QueixaView: View {
    @State private var queixas = [Queixa]()
    @State private var searchText = ""
    @State private var isDirecionar = false
    
    @State private var selectedFilter: FilterType = .ativos
    
    let baseURL = "http://localhost:3097/api/queixa/buscarTodos"
    
    
    enum FilterType: String, CaseIterable {
        case ativos = "Ativos"
        case todos = "Todos"
    }

    var filteredList: [Queixa] {
        switch selectedFilter {
        case .todos:
            return queixas
        case .ativos:
            return queixas.filter { $0.removido == false }
        }
    }
    
    var body: some View {
        NavigationStack {
            Picker("Filter", selection: $selectedFilter) {
                ForEach(FilterType.allCases, id: \..self) { filter in
                    Text(filter.rawValue)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            List {
                ForEach(filteredList) { item in
                    Text(item.nome)
                        .swipeActions(edge: .trailing) {
                        }
                }
            }
            .refreshable {
                buscarQueixas()
            }
            .onAppear(perform: {
                buscarQueixas()
            })
        }
        .navigationTitle("Queixas")
        .searchable(text: $searchText, prompt: "Procurar pacientes")
        
    }
    
    func buscarQueixas() {
        
        var tokenJwt: String = ""
        if let tokenData = UserDefaults.standard.data(forKey: "token"),
           let tokenDict = try? JSONSerialization.jsonObject(with: tokenData, options: []) as? [String: String],
           let tokenValue = tokenDict["token"] {
            print("Token Value: \(tokenValue)")
            
            tokenJwt = tokenValue
        }
        
        guard let url = URL(string: "\(baseURL)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(tokenJwt)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }
            guard let data = data else {
                print("No data received.")
                return
            }
            do {
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        let retorno = try JSONDecoder().decode([Queixa].self, from: data)
                        DispatchQueue.main.async {
                            self.queixas = retorno
                        }
                    } else {
                        print("Deu problema")
                    }
                }
            } catch {
                print("Decoding error: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
}

struct Queixa: Identifiable, Codable {
    let id: String
    let nome: String
    let removido: Bool
}

struct QueixaView_Previews: PreviewProvider {
    static var previews: some View {
        QueixaView()
    }
}

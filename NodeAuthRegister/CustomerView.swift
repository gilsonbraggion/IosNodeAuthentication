import SwiftUI

struct CustomerListView: View {
    var customers: [Customer]
    var body: some View {
        
        NavigationStack {
            VStack {
                List(customers, id: \._id) { customer in
                    VStack(alignment: .leading) {
                        Text(customer.name).font(.headline)
                        Text(customer.email).font(.subheadline)
                    }
                }
            }.padding()
        }.navigationTitle("Customers")
    }
}


struct Customer: Codable {
    let _id: String
    let name: String
    let email: String
}


#Preview {
    CustomerListView(customers: [
        .init(
            _id: "1",
            name: "Gilson",
            email: "gilsonbraggion@gmail.com"
        ),
        .init(
            _id: "2",
            name: "João",
            email: "joao.joao@joao.com.br"
        )])
}

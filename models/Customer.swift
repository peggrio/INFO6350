import UIKit

// MARK: - Customer Model
struct Customer {
    var id: Int
    var name: String
    var age: Int
    var email: String
}

// MARK: - Customer Data Manager
class CustomerDataManager {
    static let shared = CustomerDataManager()
    private var customers: [Customer] = []
    private var nextId = 1
    
//    private init() {
//        // Load initial test data
//        addCustomer(name: "John Doe", age: 30, email: "john@example.com")
//        addCustomer(name: "Jane Smith", age: 25, email: "jane@example.com")
//    }
    
    // MARK: - CRUD Operations
    func getAllCustomers() -> [Customer] {
        return customers
    }
    
    func getCustomer(by id: Int) -> Customer? {
        return customers.first(where: { $0.id == id })  // Fixed syntax here
    }
    
    func addCustomer(name: String, age: Int, email: String) -> Customer {
        let customer = Customer(id: nextId, name: name, age: age, email: email)
        customers.append(customer)
        nextId += 1
        return customer
    }
    
    func updateCustomer(_ customer: Customer) -> Bool {
        if let index = customers.firstIndex(where: { $0.id == customer.id }) {
            customers[index] = customer
            return true
        }
        return false
    }
    
    func deleteCustomer(id: Int) -> Bool {
        if PolicyDataManager.shared.hasActivePolicies(for: id) {
            print("Cannot delete customer with ID \(id) because they have active policies.")
            return false
        }
        
        // Proceed with deletion if no active policies
        if let index = customers.firstIndex(where: { $0.id == id }) {
            customers.remove(at: index)
            return true
        }
        return false
    }
}

import UIKit

// MARK: - Policy Model
struct Policy {
    var id: Int
    var customerId: Int
    var policyType: String
    var premiumAmount: Double
    var startDate: String
    var endDate: String
}

// MARK: - Policy Data Manager
class PolicyDataManager {
    static let shared = PolicyDataManager()
    private var policies: [Policy] = []
    private var nextId = 1
    
//    private init() {
//        // Optional: Load initial test data
//        addPolicy(customerId: 1, policyType: "Health Insurance", premiumAmount: 200.0, startDate: "2024-01-01", endDate: "2025-01-01")
//        addPolicy(customerId: 2, policyType: "Life Insurance", premiumAmount: 150.0, startDate: "2024-03-01", endDate: "2034-03-01")
//    }
    
    enum PolicyError: Error {
        case customerNotFound
    }
    
    // MARK: - CRUD Operations
    
    func getAllPolicies() -> [Policy] {
        return policies
    }
    
    func getPolicies(byCustomerId customerId: Int) -> [Policy] {
        return policies.filter { $0.customerId == customerId }
    }
    
    func getPolicy(byId id: Int) -> Policy? {
        return policies.first(where: { $0.id == id })
    }
    
    func customerIdExisted(customerId: Int) -> Bool {
        return CustomerDataManager.shared.getCustomer(by: customerId) != nil
    }
    
    func addPolicy(customerId: Int, policyType: String, premiumAmount: Double, startDate: String, endDate: String) -> Policy {
        let policy = Policy(id: nextId, customerId: customerId, policyType: policyType, premiumAmount: premiumAmount, startDate: startDate, endDate: endDate)
        policies.append(policy)
        nextId += 1
        return policy
        }
    
    func updatePolicy(_ policy: Policy) -> Bool {
        if let index = policies.firstIndex(where: { $0.id == policy.id }) {
            policies[index] = policy
            return true
        }
        return false
    }
    
    func deletePolicy(id: Int) -> Bool {
        
        if let index = policies.firstIndex(where: { $0.id == id }) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            if let endDate = dateFormatter.date(from: policies[index].endDate),
               endDate > Date() {
                return false
            }
            
            policies.remove(at: index)
            return true
        }
        return false
    }
    
    // MARK: - Additional Helper Functions
    
    func hasActivePolicies(for customerId: Int) -> Bool {
        return policies.contains (where: { $0.customerId == customerId })
    }
}

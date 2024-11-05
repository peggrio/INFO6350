import UIKit

// MARK: - Payment Model
struct Payment {
    var id: Int
    var policyId: Int
    var paymentAmount: Double
    var paymentDate: String
    var paymentMethod: String
    var status: String
}

// MARK: - Payment Data Manager
class PaymentDataManager {
    static let shared = PaymentDataManager()
    private var payments: [Payment] = []
    private var nextId = 1
    
    // MARK: - CRUD Operations
    
    // Add a new payment for a specific policy
    func addPayment(policyId: Int, paymentAmount: Double, paymentDate: String, paymentMethod: String, status: String) -> Payment {
        let payment = Payment(id: nextId, policyId: policyId, paymentAmount: paymentAmount, paymentDate: paymentDate, paymentMethod: paymentMethod, status: status)
        payments.append(payment)
        nextId += 1
        return payment
    }
    
    // Update an existing payment
    func updatePayment(_ payment: Payment) -> Bool {
        if let index = payments.firstIndex(where: { $0.id == payment.id }) {
            payments[index] = payment
            return true
        }
        return false
    }
    
    // Delete a payment (only if not processed)
    func deletePayment(_ paymentId: Int) -> Bool {
        if let index = payments.firstIndex(where: { $0.id == paymentId }) {
            if payments[index].status.lowercased() != "processed" {
                payments.remove(at: index)
                return true
            } else {
                print("Cannot delete processed payments.")
            }
        }
        return false
    }
    
    // Get all payments for a specific policy
    func getAllPayments(forPolicyId policyId: Int) -> [Payment] {
        return payments.filter { $0.policyId == policyId }
    }
    
    // Get all payments
    func getAllPayments() -> [Payment] {
        return payments
    }
}

import UIKit

// MARK: - Claim Model
struct Claim {
    var id: Int
    var policyId: Int
    var claimAmount: Double
    var dateOfClaim: String
    var status: String
}

// MARK: - Claim Data Manager
class ClaimDataManager {
    static let shared = ClaimDataManager()
    private var claims: [Claim] = []
    private var nextId = 1
    
    // MARK: - CRUD Operations
    
    // Add a new claim for a specific policy
    func addClaim(policyId: Int, claimAmount: Double, dateOfClaim: String, status: String) -> Claim {
        let claim = Claim(id: nextId, policyId: policyId, claimAmount: claimAmount, dateOfClaim: dateOfClaim, status: status)
        claims.append(claim)
        nextId += 1
        return claim
    }
    
    // Update an existing claim
    func updateClaim(_ claim: Claim) -> Bool {
        if let index = claims.firstIndex(where: { $0.id == claim.id }) {
            claims[index] = claim
            return true
        }
        return false
    }
    
    // Delete a claim (only if not approved)
    func deleteClaim(_ claimId: Int) -> Bool {
        if let index = claims.firstIndex(where: { $0.id == claimId }) {
            if claims[index].status.lowercased() != "approved" {
                claims.remove(at: index)
                return true
            } else {
                print("Cannot delete approved claims.")
            }
        }
        return false
    }
    
    // Get all claims for a specific policy
    func getAllClaims(forPolicyId policyId: Int) -> [Claim] {
        return claims.filter { $0.policyId == policyId }
    }
    
    // Get all claims
    func getAllClaims() -> [Claim] {
        return claims
    }
}

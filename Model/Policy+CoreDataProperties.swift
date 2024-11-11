import Foundation
import CoreData


extension Policy {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Policy> {
        return NSFetchRequest<Policy>(entityName: "Policy")
    }

    @NSManaged public var customer_id: Int64
    @NSManaged public var end_date: Date?
    @NSManaged public var id: Int64
    @NSManaged public var premium_amount: Double
    @NSManaged public var start_date: Date?
    @NSManaged public var type: String?
    @NSManaged public var claim: NSSet?
    @NSManaged public var customer: Customer?
    @NSManaged public var payment: NSSet?

}

// MARK: Generated accessors for claim
extension Policy {

    @objc(addClaimObject:)
    @NSManaged public func addToClaim(_ value: Claim)

    @objc(removeClaimObject:)
    @NSManaged public func removeFromClaim(_ value: Claim)

    @objc(addClaim:)
    @NSManaged public func addToClaim(_ values: NSSet)

    @objc(removeClaim:)
    @NSManaged public func removeFromClaim(_ values: NSSet)

}

// MARK: Generated accessors for payment
extension Policy {

    @objc(addPaymentObject:)
    @NSManaged public func addToPayment(_ value: Payment)

    @objc(removePaymentObject:)
    @NSManaged public func removeFromPayment(_ value: Payment)

    @objc(addPayment:)
    @NSManaged public func addToPayment(_ values: NSSet)

    @objc(removePayment:)
    @NSManaged public func removeFromPayment(_ values: NSSet)

}

extension Policy : Identifiable {

}

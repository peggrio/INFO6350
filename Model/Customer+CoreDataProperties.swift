import Foundation
import CoreData


extension Customer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Customer> {
        return NSFetchRequest<Customer>(entityName: "Customer")
    }

    @NSManaged public var age: Int64
    @NSManaged public var email: String?
    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var policy: NSSet?

}

// MARK: Generated accessors for policy
extension Customer {

    @objc(addPolicyObject:)
    @NSManaged public func addToPolicy(_ value: Policy)

    @objc(removePolicyObject:)
    @NSManaged public func removeFromPolicy(_ value: Policy)

    @objc(addPolicy:)
    @NSManaged public func addToPolicy(_ values: NSSet)

    @objc(removePolicy:)
    @NSManaged public func removeFromPolicy(_ values: NSSet)

}

extension Customer : Identifiable {

}

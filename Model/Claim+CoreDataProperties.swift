import Foundation
import CoreData


extension Claim {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Claim> {
        return NSFetchRequest<Claim>(entityName: "Claim")
    }

    @NSManaged public var claim_amount: Double
    @NSManaged public var date_Of_claim: Date?
    @NSManaged public var id: Int64
    @NSManaged public var policy_id: Int64
    @NSManaged public var status: String?
    @NSManaged public var policy: Policy?

}

extension Claim : Identifiable {

}

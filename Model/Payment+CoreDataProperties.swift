//
//  Payment+CoreDataProperties.swift
//  CoreDataAssignment08
//
//  Created by Peizhen Liao on 11/9/24.
//
//

import Foundation
import CoreData


extension Payment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Payment> {
        return NSFetchRequest<Payment>(entityName: "Payment")
    }

    @NSManaged public var id: Int64
    @NSManaged public var policy_id: Int64
    @NSManaged public var payment_amount: Double
    @NSManaged public var payment_date: Date?
    @NSManaged public var payment_method: String?
    @NSManaged public var status: String?
    @NSManaged public var policy: Policy?

}

extension Payment : Identifiable {

}

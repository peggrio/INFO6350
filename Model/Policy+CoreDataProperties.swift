//
//  Policy+CoreDataProperties.swift
//  CoreDataAssignment08
//
//  Created by Peizhen Liao on 11/8/24.
//
//

import Foundation
import CoreData


extension Policy {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Policy> {
        return NSFetchRequest<Policy>(entityName: "Policy")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var type: String?
    @NSManaged public var premium_amount: Double
    @NSManaged public var start_date: Date?
    @NSManaged public var end_date: Date?
    @NSManaged public var customer: Customer?

}

extension Policy : Identifiable {

}

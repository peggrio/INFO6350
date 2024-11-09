//
//  Customer+CoreDataProperties.swift
//  CoreDataAssignment08
//
//  Created by Peizhen Liao on 11/7/24.
//
//

import Foundation
import CoreData


extension Customer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Customer> {
        return NSFetchRequest<Customer>(entityName: "Customer")
    }

    @NSManaged public var age: Int64
    @NSManaged public var email: String?
    @NSManaged public var name: String?
    @NSManaged public var id: UUID?

}

extension Customer : Identifiable {

}

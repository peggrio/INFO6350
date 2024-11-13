import Foundation
import UIKit
import CoreData

// MARK: - Data Models
struct CustomerDTO: Codable {
    let id: String
    let age: Int64
    let name: String
    let email: String
    let profilePictureUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name = "name"
        case email
        case age = "age"
        case profilePictureUrl = "profilePictureUrl"
    }
}

// MARK: mapping
extension Customer {
    func toDTO() -> CustomerDTO {
        return CustomerDTO(
            id: self.id ?? "",
            age: self.age, name: self.name ?? "",
            email: self.email ?? "",
            profilePictureUrl: self.profilePictureUrl ?? ""
        )
    }
    
    static func fromDTO(_ dto: CustomerDTO, context: NSManagedObjectContext) -> Customer {
        let customer = Customer(context: context)
        customer.id = dto.id
        customer.name = dto.name
        customer.age = dto.age
        customer.email = dto.email
        customer.profilePictureUrl = dto.profilePictureUrl
        
        if let imageData = try? Data(contentsOf: URL(string: dto.profilePictureUrl)!) {
            customer.profilePicture = imageData
        }
        return customer
    }
}

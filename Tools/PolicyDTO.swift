import Foundation
import UIKit
import CoreData

struct PolicyDTO: Codable {
    let id: String
    let premium_amount: Double
    let start_date: Date
    let end_date: Date
    let customer_id: String
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case customer_id
        case start_date
        case end_date
        case premium_amount
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        premium_amount = try container.decode(Double.self, forKey: .premium_amount)
        customer_id = try container.decode(String.self, forKey: .customer_id)
        type = try container.decode(String.self, forKey: .type)
        
        // Create date formatter for ISO 8601 dates
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // Decode dates
        let startDateString = try container.decode(String.self, forKey: .start_date)
        let endDateString = try container.decode(String.self, forKey: .end_date)
        
        guard let startDate = dateFormatter.date(from: startDateString),
              let endDate = dateFormatter.date(from: endDateString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .start_date,
                in: container,
                debugDescription: "Date string does not match format"
            )
        }
        
        start_date = startDate
        end_date = endDate
    }
}

// MARK: mapping
extension Policy {
    
    static func fromDTO(_ dto: PolicyDTO, context: NSManagedObjectContext) -> Policy {
        let policy = Policy(context: context)
        policy.id = dto.id
        policy.customer_id = dto.customer_id
        policy.premium_amount = dto.premium_amount
        policy.start_date = dto.start_date
        policy.end_date = dto.end_date
        policy.type = dto.type

        return policy
    }
}

import Foundation
import UIKit
import CoreData

// MARK: - API Service
class CustomerAPIService {
    private let baseURL = "https://67339378a042ab85d11755a3.mockapi.io/api/v1"
    
    enum APIError: Error {
        case invalidURL
        case networkError
        case decodingError
        case imageDownloadError
    }
    
    func populateCustomers() async throws -> [CustomerDTO] {
        
        print("populate!")
        
        guard let url = URL(string: "\(baseURL)/customers") else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([CustomerDTO].self, from: data)
    }
    
    func populateCustomerImage(from urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else {
            throw APIError.decodingError
        }
        
        return image
    }
    
//    func fetchPolicies() async throws -> [Policy] {
//        guard let url = URL(string: "\(baseURL)/policies") else {
//            throw APIError.invalidURL
//        }
//        
//        let (data, _) = try await URLSession.shared.data(from: url)
//        return try JSONDecoder().decode([PolicyDTO].self, from: data)
//    }
}

//// MARK: - Customer Core data Service
//class CustomerCoreDataService {
////    private let CustomerCoreDataManager = CustomerCoreDataManager.shared
//    private let imageCache = ImageCache.shared
//    
//    func synchronizeCustomers(with dtos: [CustomerDTO]) async throws {
//        for dto in dtos {
//            // Download image if URL has changed or image doesn't exist
//            let imageData = try await downloadImageIfNeeded(for: dto)
//            try CustomerCoreDataManager.shared.createOrUpdateCustomer(from: dto, imageData: imageData)
//        }
//    }
//    
//    private func downloadImageIfNeeded(for dto: CustomerDTO) async throws -> Data? {
//        guard let existingCustomer = try findExistingCustomer(with: String(dto.id)) else {
//            return try await downloadImage(from: dto.profilePictureUrl)
//        }
//        
//        if existingCustomer.profilePictureUrl != dto.profilePictureUrl {
//            return try await downloadImage(from: dto.profilePictureUrl)
//        }
//        
//        return existingCustomer.profileImageData
//    }
//    
//    private func findExistingCustomer(with id: String) throws -> Customer? {
//        let fetchRequest: NSFetchRequest<Customer> = Customer.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
//        return try CustomerCoreDataManager.shared.context.fetch(fetchRequest).first
//    }
//    
//    private func downloadImage(from urlString: String) async throws -> Data? {
//        guard let url = URL(string: urlString) else { return nil }
//        let (data, _) = try await URLSession.shared.data(from: url)
//        return data
//    }
//    
//    func getCustomerImage(_ customer: Customer) -> UIImage? {
//        // Check memory cache first
//        if let cachedImage = imageCache.getImage(forKey: String(customer.id)) {
//            return cachedImage
//        }
//        
//        // Then check Core Data
//        if let imageData = customer.profileImageData,
//           let image = UIImage(data: imageData) {
//            // Cache the image in memory
//            imageCache.setImage(image, forKey: String(customer.id))
//            return image
//        }
//        
//        return nil
//    }
//}

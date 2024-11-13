//import UIKit
//import CoreData
//import PhotosUI
//
//class CustomerProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    private let apiService = CustomerAPIService()
//    private let imageManager = ImageManager.shared
//    private let coreDataManager = CustomerCoreDataManager.shared
//    
//    private var customer: CustomerDTO
//    
//    // Add custom initializer
//    init(customer: CustomerDTO) {
//        print("cusromer profile view reached")
//        self.customer = customer
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    // Required initializer
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    // UI Components
//    private lazy var profileImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleAspectFill
//        imageView.clipsToBounds = true
//        imageView.layer.cornerRadius = 50
//        imageView.isUserInteractionEnabled = true
//        return imageView
//    }()
//        
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        loadCustomerData()
//    }
//    
//    private func setupUI() {
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
//        profileImageView.addGestureRecognizer(tapGesture)
//        // Add other UI setup code
//    }
//    
//    private func loadCustomerData() {
//        Task {
//            do {
//                let customers = try await apiService.populateCustomers()
//                // For demo, get first customer
//                if let firstCustomer = customers.first {
//                    customer = firstCustomer
//                    await loadProfileImage()
//                }
//            } catch {
//                print("Error loading customer data: \(error)")
//            }
//        }
//    }
//    
//    private func loadProfileImage() async {
//        guard let customer = Optional(customer) else { return }
//        
//        // Try to load from Core Data first
//        if let savedImageData = coreDataManager.getCustomerImage(for: customer.id),
//           let savedImage = UIImage(data: savedImageData) {
//            DispatchQueue.main.async {
//                self.profileImageView.image = savedImage
//            }
//            return
//        }
//        
//        // If not in Core Data and we have a URL, try to download
//        guard let profilePictureUrl = Optional(customer.profilePictureUrl) else {
//            // Set a default image or handle the case where no URL exists
//            DispatchQueue.main.async {
//                self.profileImageView.image = UIImage(systemName: "person.circle.fill")
//            }
//            return
//        }
//        
//        do {
//            if let downloadedImage = try await imageManager.downloadImage(from: profilePictureUrl) {
//                DispatchQueue.main.async {
//                    self.profileImageView.image = downloadedImage
//                }
//                // Save to Core Data
//                if let imageData = downloadedImage.jpegData(compressionQuality: 0.8) {
//                    coreDataManager.saveCustomerImage(imageData, for: customer.id)
//                }
//            }
//        } catch {
//            print("Error loading profile image: \(error)")
//            // Set a default image on error
//            DispatchQueue.main.async {
//                self.profileImageView.image = UIImage(systemName: "person.circle.fill")
//            }
//        }
//    }
//    
//    @objc private func profileImageTapped() {
//        let imagePicker = UIImagePickerController()
//        imagePicker.delegate = self
//        imagePicker.sourceType = .photoLibrary
//        imagePicker.allowsEditing = true
//        present(imagePicker, animated: true)
//    }
//    
//    // MARK: - UIImagePickerControllerDelegate
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        guard let selectedImage = info[.editedImage] as? UIImage,
//              let customer = Optional(customer),
//              let imageData = selectedImage.jpegData(compressionQuality: 0.8) else {
//            return
//        }
//        
//        profileImageView.image = selectedImage
//        coreDataManager.saveCustomerImage(imageData, for: customer.id)
//        dismiss(animated: true)
//    }
//}

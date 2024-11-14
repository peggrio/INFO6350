import UIKit
import CoreData

class CustomerProfileViewController: UIViewController {
    
    // MARK: - Properties
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var customer: Customer!
    weak var delegate: CustomerUpdateProfileDelegate?
    
    
    private var selectedProfileImage: UIImage?
    
    // MARK: - UI Elements
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 75
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.systemBlue.cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let changePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Upload Photo", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let takePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Take Photo", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let updateProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Update Profile", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        populateData()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Update Profile"
        
        view.addSubview(profileImageView)
        view.addSubview(changePhotoButton)
        view.addSubview(takePhotoButton)
        view.addSubview(updateProfileButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
           profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
           profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
           profileImageView.widthAnchor.constraint(equalToConstant: 150),
           profileImageView.heightAnchor.constraint(equalToConstant: 150),
           
           changePhotoButton.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
           changePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
           
           takePhotoButton.topAnchor.constraint(equalTo: changePhotoButton.bottomAnchor, constant: 16),
           takePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
           
           updateProfileButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
           updateProfileButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
           updateProfileButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
       ])
    }
    
    private func setupActions() {
        changePhotoButton.addTarget(self, action: #selector(presentImagePicker), for: .touchUpInside)
        takePhotoButton.addTarget(self, action: #selector(presentCamera), for: .touchUpInside)
        updateProfileButton.addTarget(self, action: #selector(updateProfileTapped), for: .touchUpInside)
    }
    
    private func populateData() {
        if let customer = customer {
            if let profilePictureData = customer.profilePicture {
                profileImageView.image = UIImage(data: profilePictureData)
            } else {
                profileImageView.image = UIImage(systemName: "person.circle.fill")
            }
        } else {
            // Set the default image if customer is nil
            profileImageView.image = UIImage(systemName: "person.circle")
        }
    }
    
    // MARK: - Actions
    @objc private func presentImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc private func presentCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc private func updateProfileTapped() {
        guard let customer = customer, let newProfilePicture = selectedProfileImage else {
            showAlert(message: "Failed to locate this customer or select new profile")
            return
        }
        
        // Update the customer's profile picture
        customer.profilePicture = newProfilePicture.pngData()
        print("id after save profile is: \(customer.id)")
        do {
            try context.save()
            delegate?.didUpdateCustomerProfile(customer)
            navigationController?.popViewController(animated: true)
        } catch {
            showAlert(message: "Failed to update profile")
        }
    }
    
    private func showAlert(message: String, style: AlertStyle = .error) {
        let customAlert = AlertView()
        customAlert.show(style: style, message: message, in: self, autoDismiss: style == .success)
    }
}

extension CustomerProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            profileImageView.image = image
            selectedProfileImage = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

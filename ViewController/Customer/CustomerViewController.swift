import UIKit
import CoreData

protocol CustomerUpdateDelegate: AnyObject {
    func didUpdateCustomer(_ customer: Customer)
}

class CustomerViewController: UIViewController {
    
    // MARK: Properties
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private let apiService = CustomerAPIService()
    
    var customer: Customer!

    weak var delegate: CustomerUpdateDelegate?
    
    // MARK: - UI Elements
    private let idLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.keyboardType = .default
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let ageTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.systemBlue.cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let changePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change Photo", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let updateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Update Customer", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        populateData()
        setupKeyboardToolbar()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Customer details"

        view.addSubview(idLabel)
        view.addSubview(nameTextField)
        view.addSubview(ageTextField)
        view.addSubview(emailLabel)
        view.addSubview(profileImageView)
        view.addSubview(changePhotoButton)
        view.addSubview(updateButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // profileImageView
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),

            // idLabel
            idLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            idLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            idLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // nameTextField
            nameTextField.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 16),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // ageTextField
            ageTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 16),
            ageTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            ageTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // emailLabel
            emailLabel.topAnchor.constraint(equalTo: ageTextField.bottomAnchor, constant: 16),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // changePhotoButton
            changePhotoButton.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 20),
            changePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // updateButton
            updateButton.topAnchor.constraint(equalTo: changePhotoButton.bottomAnchor, constant: 20),
            updateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setupActions() {
        changePhotoButton.addTarget(self, action: #selector(handleImageTap), for: .touchUpInside)
        updateButton.addTarget(self, action: #selector(updateCustomerTapped), for: .touchUpInside)
    }
    
    private func populateData() {
        
        if let customer = customer {
            print("name:\(customer.name)")
            print("url:\(customer.profilePictureUrl)")
            idLabel.text = "id: \(customer.id)"
            if let email = customer.email {
                emailLabel.text = "Email: \(email)"
            }
            nameTextField.text = customer.name
            ageTextField.text = String(customer.age)
            
            // Populate the image asynchronously
            Task {
                let image = try await apiService.populateCustomerImage(from: customer.profilePictureUrl ?? "")
                DispatchQueue.main.async {
                    // Update UI on the main thread
                    self.profileImageView.image = image
                }
            }
        } else {
            // Set the default image if customer is nil
            profileImageView.image = UIImage(systemName: "person.circle.fill")
        }
        //        print("name:\(customer.name)")
        //        print("url:\(customer.profilePictureUrl)")
        //        idLabel.text = "id: \(customer.id)"
        //        if let email = customer.email {
        //            emailLabel.text = "Email: \(email)"
        //        }
        //        nameTextField.text = customer.name
        //        ageTextField.text = String(customer.age)
        //        
        //        // Populate the image asynchronously
        //        Task {
        //            let image = try await apiService.populateCustomerImage(from: customer.profilePictureUrl ?? "")
        //            DispatchQueue.main.async {
        //                // Update UI on the main thread
        //                self.profileImageView.image = image
        //            }
        //        }
        //    } else {
        //        // Set the default image if customer is nil
        //        profileImageView.image = UIImage(systemName: "person.circle.fill")
        //    }
        //    }
        //    
    }
    private func setupKeyboardToolbar() {
        // Create toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // Create flexible space to push the Done button to the right
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        // Create Done button
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        
        // Add items to toolbar
        toolbar.items = [flexSpace, doneButton]
        
        // Set toolbar as inputAccessoryView
        nameTextField.inputAccessoryView = toolbar
        ageTextField.inputAccessoryView = toolbar
    }
    
    // MARK: - Actions
    @objc private func doneButtonTapped() {
        view.endEditing(true)
    }
    
    @objc private func handleImageTap() {
        print("handle image tapped")
        // Navigate to change profile picture view controller
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        if let changeProfileVC = storyboard.instantiateViewController(withIdentifier: "CustomerProfileViewController") as? CustomerProfileViewController {
//            changeProfileVC.delegate = self
//            changeProfileVC.policyId = policyId
//            navigationController?.pushViewController(addClaimVC, animated: true)
//        }
    }

    // MARK: - Actions
    @objc private func updateCustomerTapped() {
        guard let name = nameTextField.text,
              let age = Int64(ageTextField.text ?? "0") else {
            showAlert(message: "Please enter valid value")
            return
        }

        // updating
        customer.name = name
        customer.age = age
        
        do{
            try self.context.save()
            
            //notify delegate
            delegate?.didUpdateCustomer(customer)
            navigationController?.popViewController(animated: true)
            
            //log
            print("\(String(describing: customer.name)) updated")
        }catch{
            print("Error add the customer: \(error)")
            showAlert(message: "Failed to update customer")
        }
    }
    
    //showing alert
    private func showAlert(message: String, style: AlertStyle = .error) {
        let customAlert = AlertView()
        customAlert.show(style: style, message: message, in: self, autoDismiss: style == .success)
    }
}

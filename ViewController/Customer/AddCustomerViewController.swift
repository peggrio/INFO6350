import UIKit
import CoreData

protocol CustomerAddDelegate: AnyObject {
    func didUpdateCustomer(_ customer: Customer)
}

protocol CustomerAddProfileDelegate: AnyObject {
    func didUpdateCustomerProfile(_ customer: Customer)
}

class AddCustomerViewController: UIViewController {

    // MARK: Properties
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var customer: Customer?
    
    weak var delegate: AddCustomerDelegate?
    
    private var currentCustomer: Customer {
        if let existingCustomer = customer {
            return existingCustomer
        } else {
            // Create a temporary customer that hasn't been saved to Core Data yet
            let tempCustomer = Customer(context: context)
            tempCustomer.id = getNextCustomerId()
            // Transfer any existing field values
            tempCustomer.name = nameTextField.text
            tempCustomer.email = emailTextField.text
            if let ageText = ageTextField.text, let age = Int64(ageText) {
                tempCustomer.age = age
            }
            return tempCustomer
        }
    }
    
    // MARK: - UI Elements
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Enter customer name"
        textField.keyboardType = .default
        return textField
    }()
    
    private let ageLabel: UILabel = {
        let label = UILabel()
        label.text = "Age"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let ageTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Enter customer age"
        textField.keyboardType = .numberPad
        return textField
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Email"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Enter customer email"
        textField.keyboardType = .emailAddress
        return textField
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
    
    private let uploadProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Upload profile", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return button
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Customer", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return button
    }()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        populateData()
        setupKeyboardToolbar()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Add Customer"
        
        // Add subviews to container stack view
        view.addSubview(containerStackView)
        
        // Create field stack views
        let nameStack = createFieldStack(label: nameLabel, field: nameTextField)
        let ageStack = createFieldStack(label: ageLabel, field: ageTextField)
        let emailStack = createFieldStack(label: emailLabel, field: emailTextField)
        
        // Add all stacks to container
        containerStackView.addArrangedSubview(nameStack)
        containerStackView.addArrangedSubview(ageStack)
        containerStackView.addArrangedSubview(emailStack)
        containerStackView.addArrangedSubview(profileImageView)
        containerStackView.addArrangedSubview(uploadProfileButton)
        containerStackView.addArrangedSubview(addButton)
        
        // Add some padding at the bottom
        containerStackView.setCustomSpacing(40, after: emailStack)
    }
    
    private func createFieldStack(label: UILabel, field: UITextField) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.addArrangedSubview(label)
        stack.addArrangedSubview(field)
        return stack
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container stack view constraints
            containerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            containerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Profile image view constraints
            profileImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3), // 30% of screen height
            profileImageView.widthAnchor.constraint(equalTo: profileImageView.heightAnchor)
        ])
    }
    
    private func setupActions() {
        uploadProfileButton.addTarget(self, action: #selector(handleImageTap), for: .touchUpInside)
        addButton.addTarget(self, action: #selector(addCustomerTapped), for: .touchUpInside)
    }
    
    private func populateData() {
        
        if let customer = customer {
            
            // Populate the image asynchronously
            Task {
                if let profilePictureData = customer.profilePicture {
                    profileImageView.image = UIImage(data: profilePictureData)
                } else {
                    // Set the default image if customer is nil
                    profileImageView.image = UIImage(systemName: "person.circle.fill")
                }
            }
        }
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
        emailTextField.inputAccessoryView = toolbar
    }
    
    // MARK: - Actions
    @objc private func doneButtonTapped() {
        view.endEditing(true)
    }
    
    // MARK: - Helper Methods
    private func getNextCustomerId() -> String {
        let fetchRequest: NSFetchRequest<Customer> = Customer.fetchRequest()
        
        do {
            let customers = try context.fetch(fetchRequest)
            
            // Convert all valid IDs to integers and find the maximum
            let maxId = customers.compactMap { Int($0.id ?? "0") }
                .max() ?? 0
            
            return String(maxId + 1)
        } catch {
            print("Error fetching customers: \(error)")
            return "1"
        }
    }
    
    // MARK: - Actions
    
    @objc private func handleImageTap() {
        
        print("handle image tapped")
        
        // Navigate to change profile picture view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let changeProfileVC = storyboard.instantiateViewController(withIdentifier: "CustomerProfileViewController") as? CustomerProfileViewController {
                changeProfileVC.delegate = self
                changeProfileVC.customer = currentCustomer
            navigationController?.pushViewController(changeProfileVC, animated: true)
        }
    }
    
    @objc private func addCustomerTapped() {
        guard let name = nameTextField.text, !name.isEmpty,
              let ageText = ageTextField.text, let age = Int64(ageText),
              let email = emailTextField.text, !email.isEmpty else {
            showAlert(message: "Please fill all fields correctly")
            return
        }
        
        // Validate email format
        if !isValidEmail(email) {
            showAlert(message: "Please enter a valid email address")
            return
        }

        // adding
        // Use the current customer instead of creating a new one
        let customerToSave = currentCustomer
        customerToSave.name = name
        customerToSave.age = age
        customerToSave.email = email
        
        //Save the data
        do{
            print("id is: \(customerToSave.id)")
            try self.context.save()
            
            //notify delegate
            delegate?.didAddCustomer(customerToSave)
            navigationController?.popViewController(animated: true)
            
            //log
            print("\(customerToSave.name) added")
        }catch{
            print("Error add the customer: \(error)")
            showAlert(message: "Failed to update customer")
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    

    //showing alert
    private func showAlert(message: String, style: AlertStyle = .error) {
        let customAlert = AlertView()
        customAlert.show(style: style, message: message, in: self, autoDismiss: style == .success)
    }
}

extension AddCustomerViewController: CustomerUpdateProfileDelegate {
    func didUpdateCustomerProfile(_ customer: Customer) {
        // Update the current customer
        self.customer = customer
        
        // Refresh the UI
        populateData()
    }
}

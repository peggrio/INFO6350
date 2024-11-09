import UIKit
import CoreData

class AddCustomerViewController: UIViewController {

    // MARK: Properties
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var customer: Customer?
    
    weak var delegate: AddCustomerDelegate?
    
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
            containerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupActions() {
        addButton.addTarget(self, action: #selector(addCustomerTapped), for: .touchUpInside)
    }
    
    // MARK: - Helper Methods
    private func getNextCustomerId() -> Int64 {
        let fetchRequest: NSFetchRequest<Customer> = Customer.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        fetchRequest.fetchLimit = 1
        
        do {
            let customers = try context.fetch(fetchRequest)
            if let lastCustomer = customers.first {
                return lastCustomer.id + 1
            }
            return 1 // Start with 1 if no customers exist
        } catch {
            print("Error fetching last customer ID: \(error)")
            return 1
        }
    }
    
    // MARK: - Actions
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
        // create a customer object
        let newCustomer = Customer(context:self.context)
        newCustomer.id = getNextCustomerId()
        newCustomer.name = name
        newCustomer.age = age
        newCustomer.email = email
        
        //Save the data
        do{
            try self.context.save()
            
            //notify delegate
            delegate?.didAddCustomer(newCustomer)
            navigationController?.popViewController(animated: true)
            
            //log
            print("\(newCustomer.name) added")
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

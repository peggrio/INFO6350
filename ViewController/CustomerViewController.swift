import UIKit

protocol CustomerUpdateDelegate: AnyObject {
    func didUpdateCustomer(_ customer: Customer)
}

class CustomerViewController: UIViewController {
    
    // MARK: Properties
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
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
        textField.keyboardType = .decimalPad
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
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Customer details"

        view.addSubview(idLabel)
        view.addSubview(nameTextField)
        view.addSubview(ageTextField)
        view.addSubview(emailLabel)
        view.addSubview(updateButton)
    }
    
    private func setupConstraints() {
            NSLayoutConstraint.activate([
                idLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                idLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                idLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                
                nameTextField.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 20),
                nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                
                ageTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
                ageTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                ageTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                
                emailLabel.topAnchor.constraint(equalTo: ageTextField.bottomAnchor, constant: 20),
                emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                emailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                
                updateButton.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 40),
                updateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
        }

    private func setupActions() {
        updateButton.addTarget(self, action: #selector(updateCustomerTapped), for: .touchUpInside)
    }
    
    private func populateData() {
        idLabel.text = "id: \(customer.id)"
        emailLabel.text = "Email: \(customer.email)"
        nameTextField.text = customer.name
        ageTextField.text = String(customer.age)
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
            print("\(customer.name) updated")
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


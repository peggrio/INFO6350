import UIKit

// MARK: - Add/Edit Customer View Controller
class AddCustomerViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    weak var delegate: AddCustomerDelegate?
    private let dataManager = CustomerDataManager.shared
    var customer: Customer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        if let customer = customer {
            populateFields(with: customer)
        }
    }
    
    private func setupUI() {
        setupKeyboardTypes()
    }
    
    
    private func setupKeyboardTypes() {
        nameTextField.keyboardType = .default
        ageTextField.keyboardType = .numberPad
        emailTextField.keyboardType = .emailAddress
    }
    
    private func populateFields(with customer: Customer) {
        nameTextField.text = customer.name
        ageTextField.text = String(customer.age)
        emailTextField.text = customer.email
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let name = nameTextField.text, !name.isEmpty,
              let ageText = ageTextField.text, let age = Int(ageText),
              let email = emailTextField.text, !email.isEmpty else {
            showAlert(message: "Please fill all fields correctly")
            return
        }
        
        // Validate email format
        if !isValidEmail(email) {
            showAlert(message: "Please enter a valid email address")
            return
        }
        
        if let existingCustomer = customer {
            // Update existing customer
            let updatedCustomer = Customer(
                id: existingCustomer.id,
                name: name,
                age: age,
                email: email
            )
            
            if dataManager.updateCustomer(updatedCustomer) {
                navigationController?.popViewController(animated: true)
            } else {
                showAlert(message: "Failed to update customer")
            }
        } else {
            // Create new customer
            let newCustomer = dataManager.addCustomer(name: name, age: age, email: email)
            
            showAlert(message: "Customer added successfully", style: .success)
            //notify delegate
            delegate?.didAddCustomer(newCustomer)
            navigationController?.popViewController(animated: true)
        }
        
        // Dismiss the view controller
        dismiss(animated: true)
    }

    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func showAlert(message: String, style: AlertStyle = .error) {
        let customAlert = CustomAlertView()
        customAlert.show(style: style, message: message, in: self, autoDismiss: style == .success)
    }
}

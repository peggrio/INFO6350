import UIKit

class UpdateCustomerViewController2: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    
    // MARK: - Properties
    weak var delegate: UpdateCustomerDelegate?
    private let dataManager = CustomerDataManager.shared
    var customer: Customer?
    
    var customerId: Int = 0
    var customerName: String = ""
    var customerAge: String = ""
    var customerEmail: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        // Set delegates
        nameTextField.delegate = self
        ageTextField.delegate = self
        
        // Pre-fill the text fields with current customer data
        nameTextField.text = customerName
        ageTextField.text = customerAge
        setupKeyboardTypes()
        
        // Make nameTextField first responder after a brief delay
        DispatchQueue.main.async {
            self.nameTextField.becomeFirstResponder()
        }
    }
    
    private func setupKeyboardTypes() {
        nameTextField.keyboardType = .default
        ageTextField.keyboardType = .numberPad
    }
    
    // MARK: - UITextFieldDelegate methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            ageTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }

    @IBAction func cancelTapped(_ sender: UIButton) {
        view.endEditing(true)
        dismiss(animated: true)
    }
    
    @IBAction func updateTapped(_ sender: UIButton) {
        // First, resign first responder
        view.endEditing(true)
        
        print("update button tapped")
        
        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty else {
            showAlert(message: "Please enter a valid name")
            return
        }
        
        guard let ageText = ageTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !ageText.isEmpty,
              let age = Int(ageText) else {
            showAlert(message: "Please enter a valid age")
            return
        }
        
        // Create updated customer
        let updatedCustomer = Customer(id: customerId, name: name, age: age, email: customerEmail)
        
        print(customerId)
        print(name)
        print(age)
        print(customerEmail)
        
        if dataManager.updateCustomer(updatedCustomer) {
            // Notify delegate of the update
            delegate?.didUpdateCustomer(updatedCustomer)
            dismiss(animated: true)
        } else {
            showAlert(message: "Failed to update customer")
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

import UIKit

protocol CustomerDataUpdateDelegate: AnyObject {
    func didUpdateCustomer(_ customer: Customer)
}

class CustomerDataViewController: UIViewController {
    
    
    @IBOutlet weak var CustomerNameTextField: UITextField!
    
    @IBOutlet weak var CustomerAgeTextField: UITextField!
    
    @IBOutlet weak var email_label: UILabel!
    
    @IBOutlet weak var id_label: UILabel!
    
    private let dataManager = CustomerDataManager.shared
    weak var delegate: CustomerDataUpdateDelegate?
    
    var id = ""
    var name = ""
    var age = ""
    var email = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Populate the fields with current data
        setupUI()
    }
    
    private func setupUI() {
        id_label.text = "ID: \(id)"
        CustomerNameTextField.text = "\(name)"
        CustomerAgeTextField.text = "\(age)"
        email_label.text = "Email: \(email)"
    }
    
    //
    //    private func setupNavigationBar() {
    //        navigationItem.rightBarButtonItem = UIBarButtonItem(
    //            title: "Update",
    //            style: .plain,
    //            target: self,
    //            action: #selector(updateTapped)
    //        )
    //    }
    
    @IBAction func updateTapped(_ sender: UIButton) {
        
        print("update buttom tapped")
        
        guard let name = CustomerNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty else {
            showAlert(message: "Please enter a valid name")
            return
        }
        
        guard let ageText = CustomerAgeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !ageText.isEmpty,
              let age = Int(ageText) else {
            showAlert(message: "Please enter a valid age")
            return
        }
        
        // Create updated customer
        let updatedCustomer = Customer(id: Int(id) ?? 0, name: name, age: age, email: email)
        
        if dataManager.updateCustomer(updatedCustomer) {
            // Notify delegate of the update
            showAlert(message: "Customer updated successfully", style: .success)
            delegate?.didUpdateCustomer(updatedCustomer)
            dismiss(animated: true)
        } else {
            showAlert(message: "Failed to update customer")
        }
        
        // Notify delegate
        delegate?.didUpdateCustomer(updatedCustomer)
        
        // Pop the view controller
        navigationController?.popViewController(animated: true)
    }
    
    private func showAlert(message: String, style: AlertStyle = .error) {
        let customAlert = CustomAlertView()
        customAlert.show(style: style, message: message, in: self, autoDismiss: style == .success)
    }
}

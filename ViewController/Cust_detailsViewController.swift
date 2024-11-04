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
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
        
//        if let updateVC = storyboard?.instantiateViewController(withIdentifier: "UpdateCustomerViewController") as? UpdateCustomerViewController {
//            updateVC.customerId = Int(id) ?? 0
//            updateVC.customerName = name
//            updateVC.customerAge = age
//            updateVC.customerEmail = email
//            updateVC.delegate = self
//            present(updateVC, animated: true)
//        }
//    }
//
//    @IBAction func deleteTapped(_ sender: UIButton) {
//        print("delete buttom tapped")
//        
//        // Show confirmation alert
//        let alert = UIAlertController(
//            title: "Delete Customer",
//            message: "Are you sure you want to delete customer '\(name)'?",
//            preferredStyle: .alert
//        )
//        
//        // Add Cancel action
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        
//        // Add Delete action
//        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
//            guard let self = self else { return }
//            
//            // Try to delete the customer
//            if self.dataManager.deleteCustomer(id: Int(self.id) ?? 0) {
//                // Show success alert
//                self.showDeleteSuccessAlert()
//            } else {
//                // Show error alert
//                self.showDeleteFailedAlert()
//            }
//        })
//        
//        // Present the alert
//        present(alert, animated: true)
//        
//    }
//    
//    private func showDeleteSuccessAlert() {
//            let alert = UIAlertController(
//                title: "Success",
//                message: "Customer deleted successfully",
//                preferredStyle: .alert
//            )
//            
//            alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
//                // Pop back to previous view controller
//                self?.navigationController?.popViewController(animated: true)
//            })
//            
//            present(alert, animated: true)
//        }
//        
//        private func showDeleteFailedAlert() {
//            let alert = UIAlertController(
//                title: "Error",
//                message: "Failed to delete customer",
//                preferredStyle: .alert
//            )
//            
//            alert.addAction(UIAlertAction(title: "OK", style: .default))
//            
//            present(alert, animated: true)
//        }
//}
//
//// MARK: - Update Delegate Protocol
//protocol UpdateCustomerDelegate: AnyObject {
//    func didUpdateCustomer(_ customer: Customer)
//}
//
//// MARK: - CustomerDataViewController Extension
//extension CustomerDataViewController: UpdateCustomerDelegate {
//    func didUpdateCustomer(_ customer: Customer) {
//        // Update the UI with new customer data
//        name = customer.name
//        age = String(customer.age)
//        setupUI()
//    }


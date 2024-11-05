import UIKit

protocol PolicyDataUpdateDelegate: AnyObject {
    func didUpdatePolicy(_ policy: Policy)
}

class PolicyDataViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var policyIdLabel: UILabel!
    @IBOutlet weak var policyCustomerIdLabel: UILabel!
    @IBOutlet weak var policyTypePicker: UIPickerView!
    @IBOutlet weak var policyAmountTextField: UITextField!
    @IBOutlet weak var policyStartDateLabel: UILabel!
    @IBOutlet weak var policyEndDatePicker: UIDatePicker!
    
    private let dataManager = PolicyDataManager.shared
    weak var delegate: PolicyDataUpdateDelegate?
    
    // Data properties
    var policyId = ""
    var customerId = ""
    var policyType = ""
    var policyAmount = ""
    var startDate = Date()
    var endDate = Date()
    
    var policy: Policy?
    
    // Policy type options for picker
    private let policyTypes = ["Health", "Life", "Auto", "Travel"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPicker()
        setupNavigationBar()
    }
    
    private func setupUI() {
        // Set up read-only fields
        policyIdLabel.text = "Policy ID: \(policyId)"
        policyCustomerIdLabel.text = "Customer ID: \(customerId)"
        policyStartDateLabel.text = "Policy start date: \(formatDate(startDate))"
        
        // Set up editable fields
        policyAmountTextField.text = policyAmount
        policyEndDatePicker.date = endDate
        policyEndDatePicker.minimumDate = startDate // Ensure end date can't be before start date
        
        // Configure text field
        policyAmountTextField.keyboardType = .decimalPad
    }
    
    private func setupPicker() {
        policyTypePicker.delegate = self
        policyTypePicker.dataSource = self
        
        // Set initial selection
        if let index = policyTypes.firstIndex(of: policyType) {
            policyTypePicker.selectRow(index, inComponent: 0, animated: false)
        }
    }
    
    // MARK: - Setup
    private func setupNavigationBar() {
        let viewClaimsButton = UIBarButtonItem(
            title: "View Claims",
            style: .plain,
            target: self,
            action: #selector(viewClaimTapped)
        )
        
        let viewPaymentsButton = UIBarButtonItem(
            title: "View Payments",
            style: .plain,
            target: self,
            action: #selector(viewPaymentsTapped)
        )
        
        // Set as right bar button item
        navigationItem.rightBarButtonItems = [viewClaimsButton, viewPaymentsButton]
    }
    
    // MARK: - Navigation
    @IBAction func updateTapped(_ sender: UIButton) {
        print("update button tapped")
        
        // Validate policy amount
        guard let amountText = policyAmountTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !amountText.isEmpty,
              let amount = Double(amountText) else {
            showAlert(message: "Please enter a valid policy amount")
            return
        }
        
        // Get selected policy type
        let selectedPolicyType = policyTypes[policyTypePicker.selectedRow(inComponent: 0)]
        
        // Get selected end date
        let selectedEndDate = policyEndDatePicker.date
        
        // Validate end date is after start date
        guard selectedEndDate > startDate else {
            showAlert(message: "End date must be after start date")
            return
        }
        
        // Format dates as strings
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let startDateString = dateFormatter.string(from: startDate)
        let endDateString = dateFormatter.string(from: selectedEndDate)
        
        
        // Create updated policy
        let updatedPolicy = Policy(
            id: Int(policyId) ?? 0,
            customerId: Int(customerId) ?? 0,
            policyType: selectedPolicyType,
            premiumAmount: amount,
            startDate: startDateString,
            endDate: endDateString
        )
        
        if dataManager.updatePolicy(updatedPolicy) {
            // Notify delegate of the update
            delegate?.didUpdatePolicy(updatedPolicy)
            dismiss(animated: true)
            showAlert(message: "Policy updated successfully", style: .success)
        } else {
            showAlert(message: "Failed to update policy")
        }
    }
    
    
    @objc func viewClaimTapped(_ sender: UIBarButtonItem) {
        print("view claim tapped")
        
        if let claimsVC = storyboard?.instantiateViewController(withIdentifier: "ClaimTableViewController") as? ClaimTableViewController {
            // Pass the data
            claimsVC.policyId = Int(policyId)
            claimsVC.policyType = policyType
            
            // Push the view controller
            navigationController?.pushViewController(claimsVC, animated: true)
        }
    }
    
    @objc func viewPaymentsTapped() {
        let paymentsVC = PaymentTableViewController()
        paymentsVC.policyId = Int(policyId)
        navigationController?.pushViewController(paymentsVC, animated: true)
    }
    
    
    // MARK: - UIPickerView DataSource & Delegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return policyTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return policyTypes[row]
    }
    
    // MARK: - Helper Methods
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func showAlert(message: String, style: AlertStyle = .error) {
        let customAlert = CustomAlertView()
        customAlert.show(style: style, message: message, in: self, autoDismiss: style == .success)
    }
}

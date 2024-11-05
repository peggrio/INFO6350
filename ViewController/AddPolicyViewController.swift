import UIKit

class AddPolicyViewController: UIViewController {

    @IBOutlet weak var customerIdTextField: UITextField!
    
    @IBOutlet weak var policyTypePicker: UIPickerView!
    
    @IBOutlet weak var premiumAmountTextField: UITextField!
    
    @IBOutlet weak var policyStartDatePicker: UIDatePicker!
    
    @IBOutlet weak var policyEndDatePicker: UIDatePicker!
    
    // MARK: - Properties
    weak var delegate: AddPolicyDelegate?
    private let dataManager = PolicyDataManager.shared
    var policy: Policy?
    private let policyTypes = ["Health", "Life", "Auto", "Travel"]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        if let policy = policy {
            populateFields(with: policy)
        }
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        policyTypePicker.dataSource = self
        policyTypePicker.delegate = self
        setupKeyboardTypes()
    }
    
    private func setupKeyboardTypes() {
        customerIdTextField.keyboardType = .default
        premiumAmountTextField.keyboardType = .default
    }
    
    private func setupDatePickers() {
        // Set the date picker mode to .date to only show the date, not the time
        policyStartDatePicker.datePickerMode = .date
        policyEndDatePicker.datePickerMode = .date
    }
    
    private func populateFields(with policy: Policy) {
        customerIdTextField.text = String(policy.customerId)
        premiumAmountTextField.text = String(policy.premiumAmount)
        if let index = policyTypes.firstIndex(of: policy.policyType) {
            policyTypePicker.selectRow(index, inComponent: 0, animated: false)
        }
    }
    
    // MARK: - Actions
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let customerIdText = customerIdTextField.text, let customerId = Int(customerIdText),
              let premiumText = premiumAmountTextField.text, let premium = Double(premiumText) else {
            showAlert(message: "Please fill all fields with valid data")
            return
        }
        
        let selectedType = policyTypes[policyTypePicker.selectedRow(inComponent: 0)]
        
        let selectedStartDate = policyStartDatePicker.date
        let selectedEndDate = policyEndDatePicker.date
        
        // Validate end date is equal or after start date
        guard selectedEndDate >= selectedStartDate else {
            showAlert(message: "End date must be after start date")
            return
        }
        
        
        // Format dates as strings
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let startDateString = dateFormatter.string(from: selectedStartDate)
        let endDateString = dateFormatter.string(from: selectedEndDate)
        
        
        if let existingPolicy = policy {
            let updatedPolicy = Policy(
                id: existingPolicy.id,
                customerId: existingPolicy.customerId,
                policyType: selectedType,
                premiumAmount: premium,
                startDate: startDateString,
                endDate: endDateString
            )

            if dataManager.updatePolicy(updatedPolicy) {
                // Notify delegate of the updated policy
                delegate?.didAddPolicy(updatedPolicy)
            } else {
                showAlert(message: "Failed to update policy")
            }
        } else {
            print("check check")
            if !dataManager.customerIdExisted(customerId: Int(customerId)) {
                print("check check2")
                showAlert(message: "Customer id not existed")
                return
            }
            
            print("check check3")
            let newPolicy = dataManager.addPolicy(
                customerId: Int(customerId),
                policyType: selectedType,
                premiumAmount: premium,
                startDate: startDateString,
                endDate: endDateString
            )
            showAlert(message: "Policy added successfully", style: .success)
            // Notify delegate of the new policy
            delegate?.didAddPolicy(newPolicy)
        
        }

        dismiss(animated: true)
    }
    
    private func showAlert(message: String, style: AlertStyle = .error) {
        let customAlert = AlertView()
        customAlert.show(style: style, message: message, in: self, autoDismiss: style == .success)
    }
}

// MARK: - UIPickerViewDataSource & UIPickerViewDelegate
extension AddPolicyViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return policyTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return policyTypes[row]
    }
}

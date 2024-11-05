import UIKit

// MARK: - AddClaimViewController
class AddClaimViewController: UIViewController {
    // MARK: - UI Elements
    private let amountTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Claim Amount"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .decimalPad
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.maximumDate = Date()
        return picker
    }()
    
    private let statusPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit Claim", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Properties
    var policyId: Int!
    private let statusOptions = ["Pending", "In Review", "Approved", "Rejected"]
    private let dataManager = ClaimDataManager.shared
    weak var delegate: ClaimUpdateDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "New Claim"
        
        statusPicker.delegate = self
        statusPicker.dataSource = self
        
        // Create labels
        let dateLabel = UILabel()
        dateLabel.text = "Date Of Claim"
        dateLabel.font = .systemFont(ofSize: 16, weight: .medium)
        dateLabel.textColor = .label
        
        let amountLabel = UILabel()
        amountLabel.text = "Amount"
        amountLabel.font = .systemFont(ofSize: 16, weight: .medium)
        amountLabel.textColor = .label
        
        let statusLabel = UILabel()
        statusLabel.text = "Status"
        statusLabel.font = .systemFont(ofSize: 16, weight: .medium)
        statusLabel.textColor = .label
        
        view.addSubview(amountLabel)
        view.addSubview(amountTextField)
        view.addSubview(dateLabel)
        view.addSubview(datePicker)
        view.addSubview(statusLabel)
        view.addSubview(statusPicker)
        view.addSubview(submitButton)
        
        // Set up constraints
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        amountTextField.translatesAutoresizingMaskIntoConstraints = false
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        statusPicker.translatesAutoresizingMaskIntoConstraints = false
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Amount label and text field
            amountLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            amountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            amountTextField.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 8),
            amountTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            amountTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            amountTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Date label and picker
            dateLabel.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 20),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            datePicker.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
            datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Status label and picker
            statusLabel.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            statusPicker.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 8),
            statusPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            statusPicker.heightAnchor.constraint(equalToConstant: 120),
            
            // Submit button
            submitButton.topAnchor.constraint(equalTo: statusPicker.bottomAnchor, constant: 30),
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            submitButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupActions() {
        submitButton.addTarget(self, action: #selector(submitClaimTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func submitClaimTapped() {
        guard let amountText = amountTextField.text,
              let amount = Double(amountText) else {
            showAlert(message: "Please enter a valid amount")
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: datePicker.date)
        let status = statusOptions[statusPicker.selectedRow(inComponent: 0)]
        
        let claim = dataManager.addClaim(
            policyId: policyId,
            claimAmount: amount,
            dateOfClaim: dateString,
            status: status
        )
        
        delegate?.didAddClaim(claim)
        navigationController?.popViewController(animated: true)
    }
    
    private func showAlert(message: String, style: AlertStyle = .error) {
        let customAlert = AlertView()
        customAlert.show(style: style, message: message, in: self, autoDismiss: style == .success)
    }
}

// MARK: - UIPickerView Extensions
extension AddClaimViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return statusOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return statusOptions[row]
    }
}

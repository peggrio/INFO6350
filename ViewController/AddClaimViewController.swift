import UIKit
import CoreData

class AddClaimViewController: UIViewController {

    // MARK: Properties
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var policyId: Int!
    var claim: Claim!
    private let statusOptions = ["Pending", "In Review", "Approved", "Rejected"]
    weak var delegate: ClaimUpdateDelegate?
    
    private let datePicker = UIDatePicker()
    private var activeTextField: UITextField?
    
    // MARK: - UI Elements
    private let amountTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Claim Amount"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .decimalPad
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "Date of Claim: "
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let claimDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.maximumDate = Date()
        return picker
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Status: "
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit Claim", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        setupKeyboardToolbar()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "New Claim"
        
        statusPicker.delegate = self
        statusPicker.dataSource = self
        
        view.addSubview(amountTextField)
        view.addSubview(dateLabel)
        view.addSubview(claimDatePicker)
        view.addSubview(statusLabel)
        view.addSubview(statusPicker)
        view.addSubview(submitButton)
        
    }
    
    
    private func setupConstraints() {
        // Constants for consistent spacing
        let padding: CGFloat = 20
        let spacing: CGFloat = 16
        
        NSLayoutConstraint.activate([
            // Amount TextField
            amountTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding),
            amountTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            amountTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            amountTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Date Label
            dateLabel.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: spacing * 1.5),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            
            // Date Picker
            claimDatePicker.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: spacing/2),
            claimDatePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            claimDatePicker.heightAnchor.constraint(equalToConstant: 40),
            
            // Status Label
            statusLabel.topAnchor.constraint(equalTo: claimDatePicker.bottomAnchor, constant: spacing * 1.5),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            
            // Status Picker
            statusPicker.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: spacing/2),
            statusPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            statusPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            statusPicker.heightAnchor.constraint(equalToConstant: 120),
            
            // Submit Button
            submitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -padding),
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            submitButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    
    private func setupActions() {
        submitButton.addTarget(self, action: #selector(submitClaimTapped), for: .touchUpInside)
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
        amountTextField.inputAccessoryView = toolbar
    }
    
    // MARK: - Actions
    @objc private func doneButtonTapped() {
        view.endEditing(true)
    }
    
    // MARK: - Helper Methods
    private func getNextClaimId() -> Int64 {
        let fetchRequest: NSFetchRequest<Claim> = Claim.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        fetchRequest.fetchLimit = 1
        
        do {
            let claims = try context.fetch(fetchRequest)
            if let lastClaim = claims.first {
                return lastClaim.id + 1
            }
            return 1 // Start with 1 if no customers exist
        } catch {
            print("Error fetching last claim ID: \(error)")
            return 1
        }
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
        let dateString = dateFormatter.string(from: claimDatePicker.date)
        let status = statusOptions[statusPicker.selectedRow(inComponent: 0)]
        
        // Validate dates
        guard let date = dateFormatter.date(from: dateString) else {
            showAlert(message: "Invalid date format")
            return
        }
        
        //add the claim
        let newClaim = Claim(context: self.context)
        newClaim.id = getNextClaimId()
        newClaim.policy_id = Int64(policyId)
        newClaim.claim_amount = amount
        newClaim.date_Of_claim = date
        newClaim.status = status
        
        // Save the data
        do {
            try self.context.save()
            delegate?.didAddClaim(newClaim)
            navigationController?.popViewController(animated: true)
            print("Claim added for policy: \(String(policyId) ?? "")")
        } catch {
            print("Error adding the claim: \(error)")
            showAlert(message: "Failed to add claim")
        }
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

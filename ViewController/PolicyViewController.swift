import UIKit

protocol PolicyUpdateDelegate: AnyObject {
    func didUpdatePolicy(_ policy: Policy)
}

class PolicyViewController: UIViewController {
    
    // MARK: Properties
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var policy: Policy!
    weak var delegate: PolicyUpdateDelegate?
    
    // MARK: - UI Elements
    private let policyIDLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.text = "Insurance Type: "
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let typeTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Policy Type"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let premiumLabel: UILabel = {
        let label = UILabel()
        label.text = "Premium amount: "
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let premiumTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.keyboardType = .decimalPad
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let startDateLabel: UILabel = {
        let label = UILabel()
        label.text = "Start Date: "
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let endDateLabel: UILabel = {
        let label = UILabel()
        label.text = "End Date:"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let endDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .compact
        }
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private let updateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Update Policy", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // navigate to Claim
    
    private let viewClaimButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("View Claims", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // navigate to Payment
    
    private let viewPaymentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("View Payments", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        populateData()
        setupKeyboardToolbar()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Policy Details"
        
        view.addSubview(policyIDLabel)
        view.addSubview(typeLabel)
        view.addSubview(typeTextField)
        view.addSubview(premiumLabel)
        view.addSubview(premiumTextField)
        view.addSubview(startDateLabel)
        view.addSubview(endDateLabel)
        view.addSubview(endDatePicker)
        view.addSubview(updateButton)
        view.addSubview(viewClaimButton)
        view.addSubview(viewPaymentButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Policy ID Label
            policyIDLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            policyIDLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            policyIDLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Type Label and TextField
            typeLabel.topAnchor.constraint(equalTo: policyIDLabel.bottomAnchor, constant: 20),
            typeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            typeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            typeTextField.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 8),
            typeTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            typeTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Premium Label and TextField
            premiumLabel.topAnchor.constraint(equalTo: typeTextField.bottomAnchor, constant: 20),
            premiumLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            premiumLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            premiumTextField.topAnchor.constraint(equalTo: premiumLabel.bottomAnchor, constant: 8),
            premiumTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            premiumTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Start Date Label
            startDateLabel.topAnchor.constraint(equalTo: premiumTextField.bottomAnchor, constant: 20),
            startDateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            startDateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // End Date Label and Picker
            endDateLabel.topAnchor.constraint(equalTo: startDateLabel.bottomAnchor, constant: 20),
            endDateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            endDateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            endDatePicker.topAnchor.constraint(equalTo: endDateLabel.bottomAnchor, constant: 8),
            endDatePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            endDatePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Update Button
            updateButton.topAnchor.constraint(equalTo: endDatePicker.bottomAnchor, constant: 40),
            updateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            updateButton.widthAnchor.constraint(equalToConstant: 200),
            updateButton.heightAnchor.constraint(equalToConstant: 44),
            
            // View Claim Button
            viewClaimButton.topAnchor.constraint(equalTo: updateButton.bottomAnchor, constant: 20),
            viewClaimButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            viewClaimButton.widthAnchor.constraint(equalToConstant: 200),
            viewClaimButton.heightAnchor.constraint(equalToConstant: 44),
            
            // View Payment Button
            viewPaymentButton.topAnchor.constraint(equalTo: viewClaimButton.bottomAnchor, constant: 20),
            viewPaymentButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            viewPaymentButton.widthAnchor.constraint(equalToConstant: 200),
            viewPaymentButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupActions() {
        updateButton.addTarget(self, action: #selector(updatePolicyTapped), for: .touchUpInside)
        viewClaimButton.addTarget(self, action: #selector(viewClaimTapped), for: .touchUpInside)
        viewPaymentButton.addTarget(self, action: #selector(viewPaymentTapped), for: .touchUpInside)
    }
    
    private func populateData() {
        policyIDLabel.text = "Policy ID: \(policy.id)"
        typeTextField.text = policy.type
        premiumTextField.text = String(format: "%.2f", policy.premium_amount)
        startDateLabel.text = "Start Date: \(formatDate(policy.start_date))"
        endDateLabel.text = "End Date: \(formatDate(policy.end_date))"
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
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
        typeTextField.inputAccessoryView = toolbar
        premiumTextField.inputAccessoryView = toolbar
    }
    
    // MARK: - Actions
    @objc private func doneButtonTapped() {
        view.endEditing(true)
    }
    
    
    // MARK: - Actions
    @objc private func updatePolicyTapped() {
        
        guard let type = typeTextField.text,
              let premiumText = premiumTextField.text,
              let premium = Double(premiumText) else {
            showAlert(message: "Please enter valid values")
            return
        }
        
        // Get selected end date
        let selectedEndDate = endDatePicker.date
        
        // Validate end date is after start date
        guard selectedEndDate >= policy.start_date! else {
            showAlert(message: "End date must be after start date")
            return
        }
        
        // Updating policy
        policy.type = type
        policy.premium_amount = premium
        policy.end_date = selectedEndDate
        
        do {
            try context.save()
            
            // Notify delegate
            delegate?.didUpdatePolicy(policy)
            navigationController?.popViewController(animated: true)
            
            // Log
            print("Policy \(policy.id) updated")
        } catch {
            print("Error updating the policy: \(error)")
            showAlert(message: "Failed to update policy")
        }
    }
    
    @objc func viewClaimTapped() {
        // log
        print("view claim tapped")
        
        guard let policy = policy else {
            print("Error: No policy available")
            return
        }
    
        if let claimsVC = storyboard?.instantiateViewController(withIdentifier: "ClaimTableViewController") as? ClaimTableViewController {
            // Pass the data
            claimsVC.policy = policy
            claimsVC.policyId = Int(policy.id)

            // Push the view controller
            navigationController?.pushViewController(claimsVC, animated: true)
        }
    }
    
    @objc func viewPaymentTapped() {
        // log
        print("view payment tapped")
        
        if let paymentsVC = storyboard?.instantiateViewController(withIdentifier: "PaymentTableViewController") as? PaymentTableViewController {
            // Pass the data
            paymentsVC.policy = policy
            paymentsVC.policyId = Int(policy.id)
            
            // Push the view controller
            navigationController?.pushViewController(paymentsVC, animated: true)
        }
    }
    
    private func showAlert(message: String, style: AlertStyle = .error) {
        let customAlert = AlertView()
        customAlert.show(style: style, message: message, in: self, autoDismiss: style == .success)
    }
}

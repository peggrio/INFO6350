import UIKit

protocol ClaimUpdateDelegate: AnyObject {
    func didUpdateClaim(_ claim: Claim)
}

class ClaimViewController: UIViewController {
    
    // MARK: Properties
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var claim: Claim!
    private let statusOptions = ["Pending", "In Review", "Approved", "Rejected"]
    weak var delegate: ClaimUpdateDelegate?
    
    // MARK: - UI Elements
    private let claimIDLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.text = "Claim Amount: "
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let amountTextField: UITextField = {
        let textField = UITextField()
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
    
    private let updateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Update Claim", for: .normal)
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
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Claim Details"
        
        statusPicker.delegate = self
        statusPicker.dataSource = self
        
        view.addSubview(claimIDLabel)
        view.addSubview(amountLabel)
        view.addSubview(dateLabel)
        view.addSubview(statusLabel)
        view.addSubview(statusPicker)
        view.addSubview(updateButton)
    }
    
    private func setupConstraints() {
        // Constants for layout
        let padding: CGFloat = 20
        let spacing: CGFloat = 15
        
        NSLayoutConstraint.activate([
            // Claim ID Label
            claimIDLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding),
            claimIDLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            claimIDLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            
            // Amount Label
            amountLabel.topAnchor.constraint(equalTo: claimIDLabel.bottomAnchor, constant: spacing * 2),
            amountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            
            // Amount TextField
            amountTextField.centerYAnchor.constraint(equalTo: amountLabel.centerYAnchor),
            amountTextField.leadingAnchor.constraint(equalTo: amountLabel.trailingAnchor, constant: spacing),
            amountTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            amountTextField.heightAnchor.constraint(equalToConstant: 40),
            
            // Date Label
            dateLabel.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: spacing * 2),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            
            // Status Label
            statusLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: spacing * 2),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            
            // Status Picker
            statusPicker.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: spacing),
            statusPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            statusPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            statusPicker.heightAnchor.constraint(equalToConstant: 150),
            
            // Update Button
            updateButton.topAnchor.constraint(equalTo: statusPicker.bottomAnchor, constant: spacing * 2),
            updateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            updateButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            updateButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupActions() {
        updateButton.addTarget(self, action: #selector(updateClaimTapped), for: .touchUpInside)
    }
    
    private func populateData() {
        amountTextField.text = String(format: "%.2f", claim.claim_amount)
        dateLabel.text = "Date of Claim: \(formatDate(claim.date_Of_claim))"
        if let statusIndex = statusOptions.firstIndex(of: claim.status!) {
            statusPicker.selectRow(statusIndex, inComponent: 0, animated: false)
        }
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    // MARK: - Actions
    @objc private func updateClaimTapped() {
        
        guard let amountText = amountTextField.text,
              let amount = Double(amountText) else {
            showAlert(message: "Please enter a valid amount")
            return
        }
        
        let status = statusOptions[statusPicker.selectedRow(inComponent: 0)]
        
        // Updating the claim
        claim.claim_amount = amount
        claim.status = status
        
        do {
            try context.save()
            
            // Notify delegate
            delegate?.didUpdateClaim(claim)
            navigationController?.popViewController(animated: true)
            
            // Log
            print("Claim \(claim.id) updated")
        } catch {
            print("Error updating the claim: \(error)")
            showAlert(message: "Failed to update claim")
        }
    }
    
    private func showAlert(message: String, style: AlertStyle = .error) {
        let customAlert = AlertView()
        customAlert.show(style: style, message: message, in: self, autoDismiss: style == .success)
    }
}

// MARK: - UIPickerView Extensions for ClaimDetailViewController
extension ClaimViewController: UIPickerViewDelegate, UIPickerViewDataSource {
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

import UIKit

// MARK: - ClaimDetailViewController
class ClaimDataViewController: UIViewController {
    // MARK: - UI Elements
    private let amountTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.keyboardType = .decimalPad
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
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
    
    // MARK: - Properties
    var claim: Claim!
    private let statusOptions = ["Pending", "In Review", "Approved", "Rejected"]
    private let dataManager = ClaimDataManager.shared
    weak var delegate: ClaimUpdateDelegate?
    
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
        
        view.addSubview(amountTextField)
        view.addSubview(dateLabel)
        view.addSubview(statusPicker)
        view.addSubview(updateButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            amountTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            amountTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            amountTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            dateLabel.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 20),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            statusPicker.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
            statusPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            updateButton.topAnchor.constraint(equalTo: statusPicker.bottomAnchor, constant: 40),
            updateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            updateButton.widthAnchor.constraint(equalToConstant: 200),
            updateButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupActions() {
        updateButton.addTarget(self, action: #selector(updateClaimTapped), for: .touchUpInside)
    }
    
    private func populateData() {
        amountTextField.text = String(claim.claimAmount)
        dateLabel.text = "Date of Claim: \(claim.dateOfClaim)"
        
        if let statusIndex = statusOptions.firstIndex(of: claim.status) {
            statusPicker.selectRow(statusIndex, inComponent: 0, animated: false)
        }
    }
    
    // MARK: - Actions
    @objc private func updateClaimTapped() {
        guard let amountText = amountTextField.text,
              let amount = Double(amountText) else {
            showAlert(message: "Please enter a valid amount")
            return
        }
        
        let status = statusOptions[statusPicker.selectedRow(inComponent: 0)]
        
        // Update the claim
        let updatedClaim = Claim(
            id: claim.id,
            policyId: claim.policyId,
            claimAmount: amount,
            dateOfClaim: claim.dateOfClaim,
            status: status
        )
        
        if dataManager.updateClaim(updatedClaim) {
            delegate?.didUpdateClaim(updatedClaim)
            navigationController?.popViewController(animated: true)
        } else {
            showAlert(message: "Failed to update claim")
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UIPickerView Extensions for ClaimDetailViewController
extension ClaimDataViewController: UIPickerViewDelegate, UIPickerViewDataSource {
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

// MARK: - Protocols
protocol ClaimUpdateDelegate: AnyObject {
    func didAddClaim(_ claim: Claim)
    func didUpdateClaim(_ claim: Claim)
}

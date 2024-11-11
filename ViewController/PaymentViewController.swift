import UIKit

protocol PaymentUpdateDelegate: AnyObject {
    func didAddPayment(_ payment: Payment)
    func didUpdatePayment(_ payment: Payment)
}

class PaymentViewController: UIViewController {
    
    // MARK: Properties
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var payment: Payment!
    private let statusOptions = ["Pending","Failed", "Cancelled", "Processed"]
    weak var delegate: PaymentUpdateDelegate?
    
    // MARK: - UI Elements
    private let paymentIDLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.text = "Payment Amount: "
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
        label.text = "Date of Payment: "
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
        button.setTitle("Update Payment", for: .normal)
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
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Payment Details"
        
        statusPicker.delegate = self
        statusPicker.dataSource = self
        
        view.addSubview(paymentIDLabel)
        view.addSubview(amountLabel)
        view.addSubview(amountTextField)
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
            // Payment ID Label
            paymentIDLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding),
            paymentIDLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            paymentIDLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            
            // Amount Label
            amountLabel.topAnchor.constraint(equalTo: paymentIDLabel.bottomAnchor, constant: spacing * 2),
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
        updateButton.addTarget(self, action: #selector(updatePaymentTapped), for: .touchUpInside)
    }
    
    private func populateData() {
        amountTextField.text = String(format: "%.2f", payment.payment_amount)
        dateLabel.text = "Date of Payment: \(formatDate(payment.payment_date))"
        if let statusIndex = statusOptions.firstIndex(of: payment.status!) {
            statusPicker.selectRow(statusIndex, inComponent: 0, animated: false)
        }
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
        amountTextField.inputAccessoryView = toolbar
    }
    
    // MARK: - Actions
    @objc private func doneButtonTapped() {
        view.endEditing(true)
    }
    
    // MARK: - Actions
    @objc private func updatePaymentTapped() {
        
        guard let amountText = amountTextField.text,
              let amount = Double(amountText) else {
            showAlert(message: "Please enter a valid amount")
            return
        }
        
        let status = statusOptions[statusPicker.selectedRow(inComponent: 0)]
        
        // Updating the payment
        payment.payment_amount = amount
        payment.status = status
        
        do {
            try context.save()
            
            // Notify delegate
            delegate?.didUpdatePayment(payment)
            navigationController?.popViewController(animated: true)
            
            // Log
            print("Payment \(payment.id) updated")
        } catch {
            print("Error updating the payment: \(error)")
            showAlert(message: "Failed to update payment")
        }
    }
    
    private func showAlert(message: String, style: AlertStyle = .error) {
        let customAlert = AlertView()
        customAlert.show(style: style, message: message, in: self, autoDismiss: style == .success)
    }
}

// MARK: - UIPickerView Extensions for PaymentDetailViewController
extension PaymentViewController: UIPickerViewDelegate, UIPickerViewDataSource {
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

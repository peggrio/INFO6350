import UIKit
import CoreData

class AddPaymentViewController: UIViewController {

    // MARK: Properties
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var policyId: String!
    var payment: Payment!
    
    private let methodOptions = ["Credit Card", "Bank Transfer", "Cash", "Check"]
    private let statusOptions = ["Pending","Failed", "Cancelled", "Processed"]
    weak var delegate: PaymentUpdateDelegate?
    
    private let datePicker = UIDatePicker()
    private var activeTextField: UITextField?
    
    // MARK: - UI Elements
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.text = "Payment amount: "
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let amountTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Payment Amount"
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
    
    private let paymentDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.maximumDate = Date()
        return picker
    }()
    
    private let methodLabel: UILabel = {
        let label = UILabel()
        label.text = "Payment method: "
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let methodPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
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
        button.setTitle("Submit Payment", for: .normal)
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
        title = "New Payment"
        
        methodPicker.delegate = self
        methodPicker.dataSource = self
        statusPicker.delegate = self
        statusPicker.dataSource = self
        
        view.addSubview(amountLabel)
        view.addSubview(amountTextField)
        view.addSubview(dateLabel)
        view.addSubview(paymentDatePicker)
        view.addSubview(methodLabel)
        view.addSubview(methodPicker)
        view.addSubview(statusLabel)
        view.addSubview(statusPicker)
        view.addSubview(submitButton)
        
    }
    
    
    private func setupConstraints() {
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
            
            paymentDatePicker.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
            paymentDatePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            paymentDatePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Method label and picker
            methodLabel.topAnchor.constraint(equalTo: paymentDatePicker.bottomAnchor, constant: 20),
            methodLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            methodPicker.topAnchor.constraint(equalTo: methodLabel.bottomAnchor, constant: 8),
            methodPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            methodPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            methodPicker.heightAnchor.constraint(equalToConstant: 120),
            
            // Status label and picker
            statusLabel.topAnchor.constraint(equalTo: methodPicker.bottomAnchor, constant: 20),
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
        submitButton.addTarget(self, action: #selector(submitPaymentTapped), for: .touchUpInside)
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
    private func getNextPaymentId() -> String {
        let fetchRequest: NSFetchRequest<Payment> = Payment.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        fetchRequest.fetchLimit = 1
        
        do {
            let payments = try context.fetch(fetchRequest)
            if let lastPayment = payments.first {
                return String(Int(bitPattern: lastPayment.id) + 1)
            }
            return "1" // Start with 1 if no customers exist
        } catch {
            print("Error fetching last payment ID: \(error)")
            return "1"
        }
    }
    
    // MARK: - Actions
    @objc private func submitPaymentTapped() {
        
        guard let amountText = amountTextField.text,
              let amount = Double(amountText) else {
            showAlert(message: "Please enter a valid amount")
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: paymentDatePicker.date)
        let method = methodOptions[methodPicker.selectedRow(inComponent: 0)]
        let status = statusOptions[statusPicker.selectedRow(inComponent: 0)]

        // Validate dates
        guard let date = dateFormatter.date(from: dateString) else {
            showAlert(message: "Invalid date format")
            return
        }
        
        //add the payment
        let newPayment = Payment(context: self.context)
        newPayment.id = getNextPaymentId()
        newPayment.policy_id = policyId
        newPayment.payment_amount = amount
        newPayment.payment_date = date
        newPayment.payment_method = method
        newPayment.status = status
        
        // Save the data
        do {
            try self.context.save()
            delegate?.didAddPayment(newPayment)
            navigationController?.popViewController(animated: true)
            print("Payment added for policy: \(String(policyId) ?? "")")
        } catch {
            print("Error adding the payment: \(error)")
            showAlert(message: "Failed to add payment")
        }
    }
    
    
    private func showAlert(message: String, style: AlertStyle = .error) {
        let customAlert = AlertView()
        customAlert.show(style: style, message: message, in: self, autoDismiss: style == .success)
    }
}

// MARK: - UIPickerView Extensions
extension AddPaymentViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == methodPicker {
            return methodOptions.count
        } else if pickerView == statusPicker {
            return statusOptions.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == methodPicker {
            return methodOptions[row]
        } else if pickerView == statusPicker {
            return statusOptions[row]
        }
        return nil
    }
}


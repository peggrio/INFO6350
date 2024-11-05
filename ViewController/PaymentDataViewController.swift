import UIKit

class PaymentDataViewController: UIViewController {
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
   
    private let paymentMethodPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
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
   
   // MARK: - Properties
   var payment: Payment!
   private let paymentMethods = ["Credit Card", "Bank Transfer", "Cash", "Check"]
   private let paymentStatuses = ["Pending","Failed", "Cancelled", "Processed"]
   private let dataManager = PaymentDataManager.shared
   weak var delegate: PaymentUpdateDelegate?
   
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
        title = "Payment Details"

        paymentMethodPicker.delegate = self
        paymentMethodPicker.dataSource = self
        statusPicker.delegate = self
        statusPicker.dataSource = self

        view.addSubview(amountTextField)
        view.addSubview(dateLabel)
        view.addSubview(paymentMethodPicker)
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

            paymentMethodPicker.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
            paymentMethodPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            paymentMethodPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            statusPicker.topAnchor.constraint(equalTo: paymentMethodPicker.bottomAnchor, constant: 20),
            statusPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            updateButton.topAnchor.constraint(equalTo: statusPicker.bottomAnchor, constant: 40),
            updateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            updateButton.widthAnchor.constraint(equalToConstant: 200),
            updateButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func setupActions() {
        updateButton.addTarget(self, action: #selector(updatePaymentTapped), for: .touchUpInside)
    }

    private func populateData() {
        amountTextField.text = String(payment.paymentAmount)
        dateLabel.text = "Payment Date: \(payment.paymentDate)"

        if let methodIndex = paymentMethods.firstIndex(of: payment.paymentMethod) {
            paymentMethodPicker.selectRow(methodIndex, inComponent: 0, animated: false)
        }

        if let statusIndex = paymentStatuses.firstIndex(of: payment.status) {
            statusPicker.selectRow(statusIndex, inComponent: 0, animated: false)
        }
    }

    // MARK: - Actions
    @objc private func updatePaymentTapped() {
        guard let amountText = amountTextField.text,
              let amount = Double(amountText) else {
            showAlert(message: "Please enter a valid amount")
            return
        }

        let paymentMethod = paymentMethods[paymentMethodPicker.selectedRow(inComponent: 0)]
        let status = paymentStatuses[statusPicker.selectedRow(inComponent: 0)]

        // Update the payment
        let updatedPayment = Payment(
            id: payment.id,
            policyId: payment.policyId,
            paymentAmount: amount,
            paymentDate: payment.paymentDate,
            paymentMethod: paymentMethod,
            status: status
        )

        if dataManager.updatePayment(updatedPayment) {
            delegate?.didUpdatePayment(updatedPayment)
            navigationController?.popViewController(animated: true)
        } else {
            showAlert(message: "Failed to update payment")
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

// MARK: - UIPickerView Extensions for PaymentDataViewController
extension PaymentDataViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == paymentMethodPicker {
            return paymentMethods.count
        } else {
            return paymentStatuses.count
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == paymentMethodPicker {
            return paymentMethods[row]
        } else {
            return paymentStatuses[row]
        }
    }
}

// MARK: - Protocols
protocol PaymentUpdateDelegate: AnyObject {
    func didUpdatePayment(_ payment: Payment)
    func didAddPayment(_ payment: Payment)
}

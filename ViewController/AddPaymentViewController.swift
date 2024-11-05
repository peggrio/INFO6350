import UIKit

class AddPaymentViewController: UIViewController {
    // MARK: - UI Elements
      private let amountTextField: UITextField = {
          let textField = UITextField()
          textField.placeholder = "Payment Amount"
          textField.borderStyle = .roundedRect
          textField.keyboardType = .decimalPad
          textField.translatesAutoresizingMaskIntoConstraints = false
          return textField
      }()
      
      private let datePicker: UIDatePicker = {
          let picker = UIDatePicker()
          picker.datePickerMode = .date
          picker.translatesAutoresizingMaskIntoConstraints = false
          return picker
      }()
      
      private let methodPicker: UIPickerView = {
          let picker = UIPickerView()
          picker.translatesAutoresizingMaskIntoConstraints = false
          return picker
      }()
    
    private let statusPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
      
      private let submitButton: UIButton = {
          let button = UIButton(type: .system)
          button.setTitle("Submit Payment", for: .normal)
          button.translatesAutoresizingMaskIntoConstraints = false
          return button
      }()
      
      // MARK: - Properties
      var policyId: Int!
      private let paymentMethods = ["Credit Card", "Bank Transfer", "Cash", "Check"]
      private let paymentStatuses = ["Pending","Failed", "Cancelled", "Processed"]
      private let dataManager = PaymentDataManager.shared
      weak var delegate: PaymentUpdateDelegate?
      
      // MARK: - Lifecycle
      override func viewDidLoad() {
          super.viewDidLoad()
          setupUI()
          setupActions()
      }
      
      // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "New Payment"
        
        methodPicker.delegate = self
        methodPicker.dataSource = self
        statusPicker.delegate = self
        statusPicker.dataSource = self
        
        // Create labels
        let dateLabel = UILabel()
        dateLabel.text = "Payment Date"
        dateLabel.font = .systemFont(ofSize: 16, weight: .medium)
        dateLabel.textColor = .label
        
        let amountLabel = UILabel()
        amountLabel.text = "Amount"
        amountLabel.font = .systemFont(ofSize: 16, weight: .medium)
        amountLabel.textColor = .label
        
        let methodLabel = UILabel()
        methodLabel.text = "Payment Method"
        methodLabel.font = .systemFont(ofSize: 16, weight: .medium)
        methodLabel.textColor = .label
        
        let statusLabel = UILabel()
        statusLabel.text = "Status"
        statusLabel.font = .systemFont(ofSize: 16, weight: .medium)
        statusLabel.textColor = .label
        
        // Add subviews
        view.addSubview(amountLabel)
        view.addSubview(amountTextField)
        view.addSubview(dateLabel)
        view.addSubview(datePicker)
        view.addSubview(methodLabel)
        view.addSubview(methodPicker)
        view.addSubview(statusLabel)
        view.addSubview(statusPicker)
        view.addSubview(submitButton)
        
        // Set up constraints
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        methodLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        amountTextField.translatesAutoresizingMaskIntoConstraints = false
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        methodPicker.translatesAutoresizingMaskIntoConstraints = false
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
            
            // Method label and picker
            methodLabel.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 20),
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
      
      // MARK: - Actions
      @objc private func submitPaymentTapped() {
          guard let amountText = amountTextField.text,
                let amount = Double(amountText) else {
              showAlert(message: "Please enter a valid amount")
              return
          }
          
          let dateFormatter = DateFormatter()
          dateFormatter.dateFormat = "yyyy-MM-dd"
          let dateString = dateFormatter.string(from: datePicker.date)
          let selectedmethod = paymentMethods[methodPicker.selectedRow(inComponent: 0)]
          let selectedStatus = paymentStatuses[statusPicker.selectedRow(inComponent: 0)]
          
          let payment = dataManager.addPayment(
              policyId: policyId,
              paymentAmount: amount,
              paymentDate: dateString,
              paymentMethod: selectedmethod,
              status: selectedStatus
          )
          
          delegate?.didAddPayment(payment)
          navigationController?.popViewController(animated: true)
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

// MARK: - Picker View Extensions
extension AddPaymentViewController: UIPickerViewDelegate, UIPickerViewDataSource {
   func numberOfComponents(in pickerView: UIPickerView) -> Int {
       return 1
   }
   
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == methodPicker {
            return paymentMethods.count
        } else if pickerView == statusPicker {
            return paymentStatuses.count
        }
        return 0
    }
    
   func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
       if pickerView == methodPicker {
           return paymentMethods[row]
       } else if pickerView == statusPicker {
           return paymentStatuses[row]
       }
       return nil
}
}

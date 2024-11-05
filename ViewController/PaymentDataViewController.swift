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
   
   // MARK: - Properties
   var payment: Payment!
   private let paymentMethods = ["Credit Card", "Bank Transfer", "Cash", "Check"]
   private let statusOptions = ["Pending","Failed", "Cancelled", "Processed"]
   private let dataManager = PaymentDataManager.shared
   weak var delegate: PaymentUpdateDelegate?
   
   // MARK: - Lifecycle & Setup methods similar to AddPaymentViewController
   // (Implementation details omitted for brevity but would include standard setup,
   // constraints, and update functionality)
}

// MARK: - Protocols
protocol PaymentUpdateDelegate: AnyObject {
   func didAddPayment(_ payment: Payment)
   func didUpdatePayment(_ payment: Payment)
}

extension PaymentDataViewController: UIPickerViewDelegate, UIPickerViewDataSource {
   func numberOfComponents(in pickerView: UIPickerView) -> Int {
       return 1
   }
   
   func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
       if pickerView == methodPicker {
           return paymentMethods.count
       } else {
           return statusOptions.count
       }
   }
   
   func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
       if pickerView == methodPicker {
           return paymentMethods[row]
       } else {
           return statusOptions[row]
       }
   }
}

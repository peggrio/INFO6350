import UIKit
import CoreData

class AddPolicyViewController: UIViewController {
    
    // MARK: Properties
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    weak var delegate: AddPolicyDelegate?
    var customer: Customer?
    
    private let datePicker = UIDatePicker()
    private var activeTextField: UITextField?
    
    // MARK: - UI Elements
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private let customerIdLabel: UILabel = {
        let label = UILabel()
        label.text = "Customer ID"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let customerIdTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Enter customer ID"
        textField.keyboardType = .numberPad
        return textField
    }()
    
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.text = "Policy Type"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let typeTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Enter policy type"
        return textField
    }()
    
    private let premiumLabel: UILabel = {
        let label = UILabel()
        label.text = "Premium Amount"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let premiumTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Enter premium amount"
        textField.keyboardType = .decimalPad
        return textField
    }()
    
    private let startDateLabel: UILabel = {
        let label = UILabel()
        label.text = "Start Date"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let startDateTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Select start date"
        return textField
    }()
    
    private let endDateLabel: UILabel = {
        let label = UILabel()
        label.text = "End Date"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let endDateTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Select end date"
        return textField
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Policy", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        setupDatePicker()
        setupKeyboardToolbar()
        
        if let customer = customer {
            customerIdTextField.text = String(customer.id)
            customerIdTextField.isEnabled = false
        }
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Add Policy"
        
        
        view.addSubview(scrollView)
        scrollView.addSubview(containerStackView)
        
        let customerIdStack = createFieldStack(label: customerIdLabel, field: customerIdTextField)
        let typeStack = createFieldStack(label: typeLabel, field: typeTextField)
        let premiumStack = createFieldStack(label: premiumLabel, field: premiumTextField)
        let startDateStack = createFieldStack(label: startDateLabel, field: startDateTextField)
        let endDateStack = createFieldStack(label: endDateLabel, field: endDateTextField)
        
        // Add fixed height to text fields for consistency
        [customerIdTextField, typeTextField, premiumTextField, startDateTextField, endDateTextField].forEach { textField in
            textField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        }

        
        containerStackView.addArrangedSubview(customerIdStack)
        containerStackView.addArrangedSubview(typeStack)
        containerStackView.addArrangedSubview(premiumStack)
        containerStackView.addArrangedSubview(startDateStack)
        containerStackView.addArrangedSubview(endDateStack)
        containerStackView.addArrangedSubview(addButton)
        
        containerStackView.setCustomSpacing(40, after: endDateStack)
    }
    
    private func setupDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(datePickerDonePressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(datePickerCancelPressed))
        
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        
        startDateTextField.inputView = datePicker
        startDateTextField.inputAccessoryView = toolbar
        
        endDateTextField.inputView = datePicker
        endDateTextField.inputAccessoryView = toolbar
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
        premiumTextField.inputAccessoryView = toolbar
        customerIdTextField.inputAccessoryView = toolbar
    }
    
    // MARK: - Actions
    @objc private func doneButtonTapped() {
        view.endEditing(true)
    }
    
    private func createFieldStack(label: UILabel, field: UITextField) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill
        stack.distribution = .fill
        
        // Set proper content hugging priorities
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        field.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        stack.addArrangedSubview(label)
        stack.addArrangedSubview(field)
        return stack
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // ScrollView constraints
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // ContainerStackView constraints
            containerStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            containerStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            containerStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            containerStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            
            // Fix the width of containerStackView relative to the scroll view
            containerStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
        
        // Ensure text fields have proper width constraints
        [customerIdTextField, typeTextField, premiumTextField, startDateTextField, endDateTextField].forEach { textField in
            textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
            textField.setContentCompressionResistancePriority(.required, for: .horizontal)
        }
    }
    
    private func setupActions() {
        addButton.addTarget(self, action: #selector(addPolicyTapped), for: .touchUpInside)
        startDateTextField.addTarget(self, action: #selector(dateFieldTapped), for: .editingDidBegin)
        endDateTextField.addTarget(self, action: #selector(dateFieldTapped), for: .editingDidBegin)
    }
    
    // MARK: - Helper Methods
    private func getNextPolicyId() -> Int64 {
        let fetchRequest: NSFetchRequest<Policy> = Policy.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        fetchRequest.fetchLimit = 1
        
        do {
            let policies = try context.fetch(fetchRequest)
            if let lastPolicy = policies.first {
                return lastPolicy.id + 1
            }
            return 1 // Start with 1 if no customers exist
        } catch {
            print("Error fetching last customer ID: \(error)")
            return 1
        }
    }
    
    // MARK: - Actions
    @objc private func addPolicyTapped() {
        guard let customerIdText = customerIdTextField.text, let customerId = Int64(customerIdText),
            let type = typeTextField.text, !type.isEmpty,
            let premiumText = premiumTextField.text, 
            let premium = Double(premiumText),
            let startDateText = startDateTextField.text, !startDateText.isEmpty,
            let endDateText = endDateTextField.text, !endDateText.isEmpty else {
          showAlert(message: "Please fill all fields correctly")
          return
        }
        
        // Validate dates
        guard let startDate = dateFormatter.date(from: startDateText),
              let endDate = dateFormatter.date(from: endDateText) else {
            showAlert(message: "Invalid date format")
            return
        }
        
        if endDate < startDate {
            showAlert(message: "End date must be after start date")
            return
        }
        
        // If we don't have a pre-selected customer, validate the customer ID
        if customer == nil {
//            guard let customerIdText = customerIdTextField.text,
//                  let customerId = Int64(customerIdText) else {
//                showAlert(message: "Invalid customer ID format")
//                return
//            }
//            
            let request = Customer.fetchRequest()
            request.predicate = NSPredicate(format: "id == %d", customerId)
            
            do {
                let results = try context.fetch(request)
                guard let fetchedCustomer = results.first else {
                    showAlert(message: "Customer not found")
                    return
                }
                customer = fetchedCustomer
            } catch {
                print("Error fetching customer: \(error)")
                showAlert(message: "Error validating customer")
                return
            }
        }
        
        // Create new policy
        let newPolicy = Policy(context: self.context)
        newPolicy.id = getNextPolicyId()
        newPolicy.type = type
        newPolicy.premium_amount = premium
        newPolicy.start_date = startDate
        newPolicy.end_date = endDate
        newPolicy.customer = customer
        newPolicy.customer_id = customer?.id ?? 0
        
        // Save the data
        do {
            try self.context.save()
            delegate?.didAddPolicy(newPolicy)
            navigationController?.popViewController(animated: true)
            print("Policy added for customer: \(customer?.name ?? "")")
        } catch {
            print("Error adding the policy: \(error)")
            showAlert(message: "Failed to add policy")
        }
    }
    
    @objc private func dateFieldTapped(_ textField: UITextField) {
        activeTextField = textField
        if let existingDate = dateFormatter.date(from: textField.text ?? "") {
            datePicker.date = existingDate
        } else {
            datePicker.date = Date()
        }
    }
    
    @objc private func datePickerDonePressed() {
        activeTextField?.text = dateFormatter.string(from: datePicker.date)
        view.endEditing(true)
    }
    
    @objc private func datePickerCancelPressed() {
        view.endEditing(true)
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    private func showAlert(message: String, style: AlertStyle = .error) {
        let customAlert = AlertView()
        customAlert.show(style: style, message: message, in: self, autoDismiss: style == .success)
    }
    
    // MARK: - Date Formatter
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}

import UIKit

// MARK: - Payment Table View Controller
class PaymentTableViewController: UITableViewController{
    
    // MARK: - Properties
    var policyId: Int!
    private var payments: [Payment] = []
    private let dataManager = PaymentDataManager.shared
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadPayments()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Payments"
        
        // Register cell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PaymentCell")
        
        // Add payment button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addPaymentTapped)
        )
    }
    
    private func loadPayments() {
        payments = dataManager.getAllPayments(forPolicyId: policyId)
        tableView.reloadData()
    }
    
    // MARK: - Actions
    @objc private func addPaymentTapped() {
        let addPaymentVC = AddPaymentViewController()
        addPaymentVC.policyId = policyId
        addPaymentVC.delegate = self
        navigationController?.pushViewController(addPaymentVC, animated: true)
    }
    
    // MARK: - UITableView DataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return payments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCell", for: indexPath)
        let payment = payments[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = "$\(payment.paymentAmount) - \(payment.paymentMethod)"
        content.secondaryText = "Date: \(payment.paymentDate) - Status: \(payment.status)"
        cell.contentConfiguration = content
        
        return cell
    }
    
    // MARK: - UITableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let payment = payments[indexPath.row]
        
        print("selected certain payment")
        let payment_dataVC = PaymentDataViewController()
        payment_dataVC.payment = payment
        payment_dataVC.delegate = self
        navigationController?.pushViewController(payment_dataVC, animated: true)
    }
    
    // MARK: - Swipe Actions
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
        -> UISwipeActionsConfiguration? {
        
        let payment = payments[indexPath.row]
        
        if payment.status == "Processed" {
            let disabledAction = UIContextualAction(style: .destructive, title: "Can't Delete") { [weak self] (_, _, completion) in
                self?.showAlert(message: "Processed payments cannot be deleted")
                completion(false)
            }
            disabledAction.backgroundColor = .gray
            return UISwipeActionsConfiguration(actions: [disabledAction])
        }
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completion) in
            let alert = UIAlertController(
                title: "Delete Payment",
                message: "Are you sure you want to delete this payment?",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                completion(false)
            })
            
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
                if self?.dataManager.deletePayment(payment.id) == true {
                    self?.payments.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    completion(true)
                } else {
                    self?.showAlert(message: "Failed to delete payment")
                    completion(false)
                }
            })
            
            self?.present(alert, animated: true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
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

// Add conformance to PaymentUpdateDelegate
extension PaymentTableViewController: PaymentUpdateDelegate {
    func didAddPayment(_ payment: Payment) {
        payments.append(payment)
        tableView.reloadData()
    }
    
    func didUpdatePayment(_ payment: Payment) {
        if let index = payments.firstIndex(where: { $0.id == payment.id }) {
            payments[index] = payment
            tableView.reloadData()
        }
    }
}

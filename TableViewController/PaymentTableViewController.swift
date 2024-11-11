import UIKit
import CoreData

class PaymentTableViewController: UITableViewController, PaymentUpdateDelegate, UISearchBarDelegate{
    
    // MARK: - Properties
    let cellIdentifier = "PaymentCell"
    let searchController = UISearchController(searchResultsController: nil)
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var policy: Policy?
    var policyId: Int?
   
    var payments: [Payment]? = [] // Initialize as empty array
    var filteredPayments: [Payment]? = [] // Initialize as empty array
    
    private var searchText: String = ""
    
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add debug print to check policy
        if let policy = policy {
            print("Policy is set with ID: \(policy.id)")
        } else {
            print("Warning: Policy is nil in viewDidLoad")
        }
        
        setupTableView()
        setupSearchController()
        fetchPayments()
    }
    
    // MARK: - Setup
    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        title = "Payments"
        
        // Add new Payment button
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addPaymentTapped)
        )
        navigationItem.rightBarButtonItem = addButton
    }
    
    func setupSearchController() {
        // Configure the search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search payments..."
        
        // Add the search controller to the navigation item
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // Define the scope bar
        definesPresentationContext = true
    }
    
    func fetchPayments() {
        // Safely unwrap policy ID
        guard let policyId = policy?.id else {
            print("Error: No policy ID available")
            return
        }
        
        do {
            let request = Payment.fetchRequest() as NSFetchRequest<Payment>
            
            // If searching, add the search predicate
            if isFiltering {
                let searchText = searchController.searchBar.text!
                let policyPredicate = NSPredicate(format: "policy_id == %@", NSNumber(value: policyId))
                let searchPredicate = NSPredicate(format: "id CONTAINS[cd] %@", searchText)
                let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [policyPredicate, searchPredicate])
                request.predicate = compoundPredicate
            } else {
                request.predicate = NSPredicate(format: "policy_id == %@", NSNumber(value: policyId))
            }
            
            request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
            
            let results = try context.fetch(request)
            
            if isFiltering {
                self.filteredPayments = results
            } else {
                self.payments = results
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print("Error fetching policies: \(error)")
        }
    }
    
    // MARK: - Actions
    //Add function
    @objc private func addPaymentTapped() {
        // Navigate to add policy view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let addPaymentVC = storyboard.instantiateViewController(withIdentifier: "AddPaymentViewController") as? AddPaymentViewController {
            addPaymentVC.delegate = self
            addPaymentVC.policyId = policyId
            navigationController?.pushViewController(addPaymentVC, animated: true)
        }
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredPayments?.count ?? 0
        }
        return payments?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        let paymentArray = isFiltering ? filteredPayments : payments
        
        guard let payments = paymentArray, indexPath.row < payments.count else {
            // Return empty cell if payments array is nil or index out of bounds
            var content = cell.defaultContentConfiguration()
            content.text = "No data available"
            cell.contentConfiguration = content
            return cell
        }
        
        let payment = payments[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = "Payment #\(payment.id)"
        if let status = payment.status{
            content.secondaryText = "Amount: $\(payment.payment_amount) - Status: \(status)"
        }
        cell.contentConfiguration = content
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let paymentArray = isFiltering ? filteredPayments : payments
        guard let payments = paymentArray, indexPath.row < payments.count else {
            return
        }
        
        let payment = payments[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let paymentVC = storyboard.instantiateViewController(withIdentifier: "PaymentViewController") as? PaymentViewController {
            paymentVC.payment = payment
            paymentVC.delegate = self
            navigationController?.pushViewController(paymentVC, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let paymentArray = isFiltering ? filteredPayments : payments
            guard let payments = paymentArray,
                  indexPath.row < payments.count,
                  var mutablePayments = self.payments else {
                return
            }
            
            let paymentToDelete = payments[indexPath.row]
            //Approved claims cannot be deleted
            if paymentToDelete.status!.lowercased() == "processed"{
                showDeleteFailedAlert()
                return // Exit the method without deleting
            }
            context.delete(paymentToDelete)
            
            do {
                try context.save()
                mutablePayments.remove(at: indexPath.row)
                self.payments = mutablePayments
                tableView.deleteRows(at: [indexPath], with: .fade)
                showDeleteSuccessAlert()
            } catch {
                print("Error deleting payment: \(error)")
            }
        }
    }
    
    private func showDeleteSuccessAlert() {
        let alert = UIAlertController(
            title: "Success",
            message: "Payment deleted successfully",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            // Pop back to previous view controller
            self?.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    private func showDeleteFailedAlert() {
        let alert = UIAlertController(
            title: "Error",
            message: "Proccessed payment cannot be deleted.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alert, animated: true)
    }
}


// MARK: - Protocols
protocol AddPaymentDelegate: AnyObject {
    func didAddPayment(_ payment: Payment)
}

protocol UpdatePaymentDelegate: AnyObject {
    func didUpdatePayment(_ payment: Payment)
}

// MARK: - Search Results Updating
extension PaymentTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        fetchPayments()
    }
}

// MARK: - Add Payment Delegate
extension PaymentTableViewController: AddPaymentDelegate {
    func didAddPayment(_ payment: Payment) {
        fetchPayments()
    }
}

// MARK: - Update Payment Delegate
extension PaymentTableViewController: UpdatePaymentDelegate {
    func didUpdatePayment(_ payment: Payment) {
        fetchPayments()
    }
}


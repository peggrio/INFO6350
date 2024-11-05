import UIKit

class CustomerTableViewController: UITableViewController, CustomerDataUpdateDelegate {

    
    // MARK: - Properties
    private var customers: [Customer] = []
    private let cellIdentifier = "CustomerCell"
    private let dataManager = CustomerDataManager.shared
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
//        fetchCustomers()
        setupTableView()
    }
    
    // MARK: - Setup
    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        title = "Customers"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addCustomerSegue" {
            if let addVC = segue.destination as? AddCustomerViewController {
                addVC.delegate = self
            }
        }
    }

    // Add this method to refresh table view
    public func refreshTableView() {
        customers = dataManager.getAllCustomers()
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let customer = customers[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = customer.name
        content.secondaryText = customer.email
        content.image = UIImage(systemName: "person.crop.circle.badge.fill")
        cell.contentConfiguration = content
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            let customer = customers[indexPath.row]
            
            print("Selected customer: \(customer.name)")
        
            // Create and configure the details view controller
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let detailsVC = storyboard.instantiateViewController(withIdentifier: "CustomerDataViewController") as? CustomerDataViewController {
                // Pass the data
                detailsVC.id = String(customer.id)
                detailsVC.name = customer.name
                detailsVC.age = String(customer.age)
                detailsVC.email = customer.email
                detailsVC.delegate = self
                
                // Push the view controller
                navigationController?.pushViewController(detailsVC, animated: true)
            }
        }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let customer = customers[indexPath.row]
            
            if dataManager.deleteCustomer(id: customer.id) {
                // Show success alert
                self.showDeleteSuccessAlert()
                customers.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } else {
                // Show error alert
                self.showDeleteFailedAlert()
            }

        }
    }
    private func showDeleteSuccessAlert() {
        let alert = UIAlertController(
            title: "Success",
            message: "Customer deleted successfully",
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
            message: "Failed to delete customer, customers with existing Insurance Policies cannot be deleted",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alert, animated: true)
    }
}

// MARK: - Add Delegate Protocol
protocol AddCustomerDelegate: AnyObject {
    func didAddCustomer(_ customer: Customer)
}

// MARK: - Update Delegate Protocol
protocol UpdateCustomerDelegate: AnyObject {
    func didUpdateCustomer(_ customer: Customer)
}



// MARK: - Add Extension for Delegate
extension CustomerTableViewController: AddCustomerDelegate {
    func didAddCustomer(_ customer: Customer) {
        // Refresh the table view data
        refreshTableView()
    }
}

extension CustomerTableViewController: UpdateCustomerDelegate {
    func didUpdateCustomer(_ updatedCustomer: Customer) {
        if let index = customers.firstIndex(where: { $0.id == updatedCustomer.id }) {
            customers[index] = updatedCustomer
            tableView.reloadData()
        }

    }
}

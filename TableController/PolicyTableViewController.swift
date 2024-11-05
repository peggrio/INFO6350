import UIKit

class PolicyTableViewController: UITableViewController, PolicyDataUpdateDelegate {

    // MARK: - Properties
    private var policies: [Policy] = []
    private let cellIdentifier = "PolicyCell"
    private let dataManager = PolicyDataManager.shared
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
//        fetchPolicies()
        setupTableView()
    }
    
    // MARK: - Setup
    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        title = "Policies"
    }

    // MARK: - Actions
    @IBAction func addPolicyTapped(_ sender: UIBarButtonItem) {
        print("Add policy tapped")
        
        // Create and present AddPolicyViewController
        if let addVC = storyboard?.instantiateViewController(withIdentifier: "AddPolicyViewController") as? AddPolicyViewController {
            // Set up delegate
            addVC.delegate = self
            present(addVC, animated: true)
        }
    }
    
    // Refresh table view data
    public func refreshTableView() {
        policies = dataManager.getAllPolicies()
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return policies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let policy = policies[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = "\(policy.id) : \(policy.policyType)"
        content.secondaryText = "Premium: $\(policy.premiumAmount)"
        content.image = UIImage(systemName: "doc.plaintext")
        cell.contentConfiguration = content
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let policy = policies[indexPath.row]
        
        print("Selected policy: \(policy.policyType)")
        
        // Create and configure the details view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailsVC = storyboard.instantiateViewController(withIdentifier: "PolicyDataViewController") as? PolicyDataViewController {
            // Pass the data
            detailsVC.policyId = String(policy.id)
            detailsVC.customerId = String(policy.customerId)
            detailsVC.policyType = String(policy.policyType)
            detailsVC.policyAmount = String(policy.premiumAmount)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd" // Use the appropriate format for your date string
            if let startDate = dateFormatter.date(from: policy.startDate), let endDate = dateFormatter.date(from: policy.endDate) {
                detailsVC.startDate = startDate
                detailsVC.endDate = endDate
            } else {
                print("Invalid date format")
            }
            detailsVC.delegate = self
            
            // Push the view controller
            navigationController?.pushViewController(detailsVC, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let policy = policies[indexPath.row]
            
            if dataManager.deletePolicy(id: policy.id) {
                // Show success alert
                self.showDeleteSuccessAlert()
                policies.remove(at: indexPath.row)
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
            message: "Policy deleted successfully",
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
            message: "Failed to delete policy, because it is still active.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alert, animated: true)
    }
}

// MARK: - Add Delegate Protocol
protocol AddPolicyDelegate: AnyObject {
    func didAddPolicy(_ policy: Policy)
}

// MARK: - Update Delegate Protocol
protocol UpdatePolicyDelegate: AnyObject {
    func didUpdatePolicy(_ policy: Policy)
}

// MARK: - Add Extension for Delegate
extension PolicyTableViewController: AddPolicyDelegate {
    func didAddPolicy(_ policy: Policy) {
        refreshTableView()
    }
}

extension PolicyTableViewController: UpdatePolicyDelegate {
    func didUpdatePolicy(_ updatedPolicy: Policy) {
        if let index = policies.firstIndex(where: { $0.id == updatedPolicy.id }) {
            policies[index] = updatedPolicy
            tableView.reloadData()
        }
    }
}


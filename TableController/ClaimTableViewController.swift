import UIKit

class ClaimTableViewController: UITableViewController {
    
    // MARK: - Properties
    var policyId: Int?
    var policyType: String?
    private var claims: [Claim] = []
    private let dataManager = ClaimDataManager.shared
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        loadClaims()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Claims"
        
        // Register cell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ClaimCell")
        
        // Add new claim button
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addClaimTapped)
        )
        navigationItem.rightBarButtonItem = addButton
    }
    
    private func loadClaims() {
        guard let policyId = policyId else { return }
        
        // Assuming ClaimDataManager has a method to fetch claims
        claims = dataManager.getAllClaims(forPolicyId: policyId)
        tableView.reloadData()
    }
    
    // MARK: - Actions
    @objc private func addClaimTapped() {
        let addClaimVC = AddClaimViewController()
        addClaimVC.policyId = policyId
        addClaimVC.delegate = self
        navigationController?.pushViewController(addClaimVC, animated: true)
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return claims.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClaimCell", for: indexPath)
        
        let claim = claims[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = "Claim #\(claim.id)"
        content.secondaryText = "Amount: $\(claim.claimAmount) - Status: \(claim.status)"
        cell.contentConfiguration = content
        
        return cell
    }
    
    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let claim = claims[indexPath.row]
        
        let detailVC = ClaimDataViewController()
        detailVC.claim = claim
        detailVC.delegate = self
        navigationController?.pushViewController(detailVC, animated: true)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let claim = claims[indexPath.row]
            
            // Show confirmation alert
            let alert = UIAlertController(
                title: "Delete Claim",
                message: "Are you sure you want to delete this claim?",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                // Delete the claim
                if self?.dataManager.deleteClaim(claim.id) == true {
                    // Remove from local array and update UI
                    self?.showDeleteSuccessAlert()
                    self?.claims.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                } else {
                    // Show error if deletion failed
                    self?.showDeleteFailedAlert()
                }
            })
            
            present(alert, animated: true)
        }
    }

    // Helper method for showing alerts
    private func showDeleteSuccessAlert() {
        let alert = UIAlertController(
            title: "Success",
            message: "Claim deleted successfully",
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
            message: "Failed to delete claim, cannot delete approved claims.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alert, animated: true)
    }
}

// Add conformance to ClaimUpdateDelegate
extension ClaimTableViewController: ClaimUpdateDelegate {
    func didAddClaim(_ claim: Claim) {
        claims.append(claim)
        tableView.reloadData()
    }
    
    func didUpdateClaim(_ claim: Claim) {
        if let index = claims.firstIndex(where: { $0.id == claim.id }) {
            claims[index] = claim
            tableView.reloadData()
        }
    }
}

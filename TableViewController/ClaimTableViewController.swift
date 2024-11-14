import UIKit
import CoreData

class ClaimTableViewController: UITableViewController, ClaimUpdateDelegate, UISearchBarDelegate{
    
    // MARK: - Properties
    let cellIdentifier = "ClaimCell"
    let searchController = UISearchController(searchResultsController: nil)
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var policy: Policy?
    var policyId: String?
   
    var claims: [Claim]? = [] // Initialize as empty array
    var filteredClaims: [Claim]? = [] // Initialize as empty array
    
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
        fetchClaims()
    }
    
    // MARK: - Setup
    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        title = "Claims"
        
        // Add new claim button
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addClaimTapped)
        )
        navigationItem.rightBarButtonItem = addButton
    }
    
    func setupSearchController() {
        // Configure the search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search claims..."
        
        // Add the search controller to the navigation item
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // Define the scope bar
        definesPresentationContext = true
    }
    
    func fetchClaims() {
        // Safely unwrap policy ID
        guard let policyId = policy?.id else {
            print("Error: No policy ID available")
            return
        }
        
        do {
            let request = Claim.fetchRequest() as NSFetchRequest<Claim>
            
            // If searching, add the search predicate
            if isFiltering {
                let searchText = searchController.searchBar.text!
                let policyPredicate = NSPredicate(format: "policy_id == %@", policyId)
                let searchPredicate = NSPredicate(format: "id CONTAINS[cd] %@", searchText)
                let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [policyPredicate, searchPredicate])
                request.predicate = compoundPredicate
            } else {
                request.predicate = NSPredicate(format: "policy_id == %@", policyId)
            }
            
            request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
            
            let results = try context.fetch(request)
            
            if isFiltering {
                self.filteredClaims = results
            } else {
                self.claims = results
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
    @objc private func addClaimTapped() {
        // Navigate to add policy view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let addClaimVC = storyboard.instantiateViewController(withIdentifier: "AddClaimViewController") as? AddClaimViewController {
            addClaimVC.delegate = self
            addClaimVC.policyId = policyId
            navigationController?.pushViewController(addClaimVC, animated: true)
        }
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredClaims?.count ?? 0
        }
        return claims?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        let claimArray = isFiltering ? filteredClaims : claims
        
        guard let claims = claimArray, indexPath.row < claims.count else {
            // Return empty cell if claims array is nil or index out of bounds
            var content = cell.defaultContentConfiguration()
            content.text = "No data available"
            cell.contentConfiguration = content
            return cell
        }
        
        let claim = claims[indexPath.row]
        var content = cell.defaultContentConfiguration()
        
        
        let id = claim.id ?? ""
        
        content.text = "Claim #\(id)"
        if let status = claim.status {
            content.secondaryText = "Amount: $\(claim.claim_amount) - Status: \(status)"
        }
        cell.contentConfiguration = content
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let claimArray = isFiltering ? filteredClaims : claims
        guard let claims = claimArray, indexPath.row < claims.count else {
            return
        }
        
        let claim = claims[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let claimVC = storyboard.instantiateViewController(withIdentifier: "ClaimViewController") as? ClaimViewController {
            claimVC.claim = claim
            claimVC.delegate = self
            navigationController?.pushViewController(claimVC, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let claimArray = isFiltering ? filteredClaims : claims
            guard let claims = claimArray,
                  indexPath.row < claims.count,
                  var mutableClaims = self.claims else {
                return
            }
            
            let claimToDelete = claims[indexPath.row]
            
            //Approved claims cannot be deleted
            if claimToDelete.status!.lowercased() == "approved"{
                showDeleteFailedAlert()
                return // Exit the method without deleting
            }
            context.delete(claimToDelete)
            
            do {
                try context.save()
                mutableClaims.remove(at: indexPath.row)
                self.claims = mutableClaims
                tableView.deleteRows(at: [indexPath], with: .fade)
                showDeleteSuccessAlert()
            } catch {
                print("Error deleting claim: \(error)")
            }
        }
    }
    
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
            message: "Approved claims cannot be deleted.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alert, animated: true)
    }
}


// MARK: - Protocols
protocol AddClaimDelegate: AnyObject {
    func didAddClaim(_ claim: Claim)
}

protocol UpdateClaimDelegate: AnyObject {
    func didUpdateClaim(_ claim: Claim)
}

// MARK: - Search Results Updating
extension ClaimTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        fetchClaims()
    }
}

// MARK: - Add Claim Delegate
extension ClaimTableViewController: AddClaimDelegate {
    func didAddClaim(_ claim: Claim) {
        fetchClaims()
    }
}

// MARK: - Update Claim Delegate
extension ClaimTableViewController: UpdateClaimDelegate {
    func didUpdateClaim(_ claim: Claim) {
        fetchClaims()
    }
}

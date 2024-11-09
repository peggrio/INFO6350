import UIKit
import CoreData

class ClaimTableViewController: UITableViewController, ClaimUpdateDelegate, UISearchBarDelegate{
    
    // MARK: - Properties
    let cellIdentifier = "ClaimCell"
    let searchController = UISearchController(searchResultsController: nil)
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var policyId: Int?
    var policyType: String?
    var claims: [Claim]?
    var policy: Policy? {
        didSet {
            fetchClaims()
        }
    }
    var filteredClaims: [Claim]?
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
        
        setupTableView()
        fetchClaims()
    }
    
    // MARK: - Setup
    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        title = "Claims"
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
        guard let policy = policy else { return }
        
        do {
            let request = Claim.fetchRequest() as NSFetchRequest<Claim>
            request.predicate = NSPredicate(format: "policy_id = %d", policyId!)
            request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
            // If searching, add the search predicate
            if isFiltering {
                let searchText = searchController.searchBar.text!
                let predicate = NSPredicate(format: "id CONTAINS[cd] %d", searchText)
                request.predicate = predicate
            }
            
            let results = try context.fetch(request)
            
            if isFiltering {
                self.filteredClaims = results
            } else {
                self.claims = results
                self.filteredClaims = results
            }
            
            filteredClaims = try context.fetch(request)
            
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
            addClaimVC.claim = claims
            addClaimVC.delegate = self
            navigationController?.pushViewController(addClaimVC, animated: true)
        }
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return claims?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        if let claim = claims?[indexPath.row] {
            // Configure cell with claim details
            var content = cell.defaultContentConfiguration()
            content.text = "Claim #\(claim.id)"
            content.secondaryText = "Amount: $\(claim.claim_amount) - Status: \(claim.status)"
            cell.contentConfiguration = content
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let claim = claims?[indexPath.row] {
            // Navigate to claim details view controller
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let claimVC = storyboard.instantiateViewController(withIdentifier: "ClaimViewController") as? ClaimViewController {
                claimVC.claim = claim
                claimVC.delegate = self
                navigationController?.pushViewController(claimVC, animated: true)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let claimToDelete = claims?[indexPath.row] else { return }
            
            context.delete(claimToDelete)
            
            do {
                try context.save()
                claims?.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                print("Error deleting claim: \(error)")
            }
        }
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

import UIKit
import CoreData

class PolicyTableViewController: UITableViewController, PolicyUpdateDelegate, UISearchBarDelegate{
    
    // MARK: - Properties
    let cellIdentifier = "PolicyCell"
    let searchController = UISearchController(searchResultsController: nil)
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var customer: Customer? // Reference to the selected customer
    var policies: [Policy]? // Array to hold the policies
    var filteredPolicies: [Policy]?
    private var searchText: String = ""
    
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupSearchController()
        fetchPolicies()
    }
    
    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        title = "Policies"
    }
    
    func setupSearchController() {
        // Configure the search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search policies..."
        
        // Add the search controller to the navigation item
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // Define the scope bar
        definesPresentationContext = true
    }
    
    //Add function
    //use segue to navigate the add
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addPolicySegue" {
            if let addVC = segue.destination as? AddPolicyViewController {
                addVC.delegate = self
            }
        }
    }

    func fetchPolicies() {

        do {
            let request = Policy.fetchRequest() as NSFetchRequest<Policy>
            
            // If searching, add the search predicate
            if isFiltering {
                let searchText = searchController.searchBar.text!
                let predicate = NSPredicate(format: "id CONTAINS[cd] %d", searchText)
                request.predicate = predicate
            }
            
            let results = try context.fetch(request)
                        
            if isFiltering {
                self.filteredPolicies = results
            } else {
                self.policies = results
                self.filteredPolicies = results
            }
            
            policies = try context.fetch(request)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print("Error fetching policies: \(error)")
        }
    }
    
    // MARK: - Table View Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return policies?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        if let policy = policies?[indexPath.row] {
            // Configure cell with policy details
            cell.textLabel?.text = "#\(policy.id) - \(policy.type ?? "")"
            cell.detailTextLabel?.text = "Premium: $\(policy.premium_amount)"
        }
        
        return cell
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let policy = policies?[indexPath.row] {
            // Navigate to policy details view controller
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let policyVC = storyboard.instantiateViewController(withIdentifier: "PolicyViewController") as? PolicyViewController {
                policyVC.policy = policy
                policyVC.delegate = self
                navigationController?.pushViewController(policyVC, animated: true)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let policyToDelete = policies?[indexPath.row] else { return }
            
            context.delete(policyToDelete)
            
            do {
                try context.save()
                policies?.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                print("Error deleting policy: \(error)")
            }
        }
    }
}


// MARK: - Protocols
protocol AddPolicyDelegate: AnyObject {
    func didAddPolicy(_ policy: Policy)
}

protocol UpdatePolicyDelegate: AnyObject {
    func didUpdatePolicy(_ policy: Policy)
}

// MARK: - Search Results Updating
extension PolicyTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        fetchPolicies()
    }
}

// MARK: - Add Policy Delegate
extension PolicyTableViewController: AddPolicyDelegate {
    func didAddPolicy(_ policy: Policy) {
        fetchPolicies()
    }
}

// MARK: - Update Policy Delegate
extension PolicyTableViewController: UpdatePolicyDelegate {
    func didUpdatePolicy(_ policy: Policy) {
        fetchPolicies()
    }
}

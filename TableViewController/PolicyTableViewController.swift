import UIKit
import CoreData

class PolicyTableViewController: UITableViewController, PolicyUpdateDelegate, UISearchBarDelegate{
    
    // MARK: - Properties
    let cellIdentifier = "PolicyCell"
    let searchController = UISearchController(searchResultsController: nil)
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private let apiService = APIService()
    
    var policy: Policy? // Reference to the selected customer
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
        
        // Create a Task to handle async work
        Task {
            await fetchPoliciesFromAPI()
        }
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
    
    func fetchLocalPolicies(){
        Task { @MainActor in
            do {
                let request = Policy.fetchRequest() as NSFetchRequest<Policy>
                
                // If searching, add the search predicate
                if isFiltering {
                    let searchText = searchController.searchBar.text!
                    let predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchText)
                    request.predicate = predicate
                }
                
                let results = try context.fetch(request)
                
                if isFiltering {
                    self.filteredPolicies = results
                } else {
                    self.policies = results
                    self.filteredPolicies = results
                }
                
                self.tableView.reloadData()
            } catch {
                print("Error fetching policys: \(error)")
            }
        }
    }
    
    func fetchPoliciesFromAPI() async {
        do {
            let dtos = try await apiService.populatePolicies()
            
            // Save to CoreData
            await MainActor.run {
                for dto in dtos {
                    let fetchRequest: NSFetchRequest<Policy> = Policy.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "id == %d", dto.id)
                    
                    do {
                        let existingPolicys = try context.fetch(fetchRequest)
                        if let existingPolicy = existingPolicys.first {
                            // Update existing policy
                            existingPolicy.type = dto.type
                            existingPolicy.start_date = dto.start_date
                            existingPolicy.end_date = dto.end_date
                            existingPolicy.premium_amount = dto.premium_amount
                            existingPolicy.customer_id = dto.customer_id

                        } else {
                            // Create new policy
                            _ = Policy.fromDTO(dto, context: context)
                        }
                        
                        try context.save()
                    } catch {
                        print("Error saving policy: \(error)")
                    }
                }
                
                fetchLocalPolicies()
            }
        } catch {
            print("Error fetching policys from API: \(error)")
        }
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
                let predicate = NSPredicate(format: "id CONTAINS[cd] %@", searchText)
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
            let id = policy.id ?? ""
            cell.textLabel?.text = "#\(id) - \(policy.type ?? "")"
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
            
            //Active policies cannot be deleted.
            if let endDate = policyToDelete.end_date, endDate > Date() {
                showDeleteFailedAlert()
                return  // Exit the method without deleting
            }
            
            context.delete(policyToDelete)
            
            do {
                try context.save()
                policies?.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                showDeleteSuccessAlert()
            } catch {
                print("Error deleting policy: \(error)")
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

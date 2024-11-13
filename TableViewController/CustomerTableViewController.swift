import UIKit
import CoreData

class CustomerTableViewController: UITableViewController, CustomerUpdateDelegate, CustomerUpdateProfileDelegate, UISearchBarDelegate {
    
    let cellIdentifier = "CustomerCell"
    let searchController = UISearchController(searchResultsController: nil)

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private let apiService = CustomerAPIService()
    
    var customers: [Customer]?
    var filteredCustomers: [Customer]?
    private var searchText: String = ""
    
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        setupTableView()
        setupSearchController()
        
        // Create a Task to handle async work
        Task {
            await fetchCustomersFromAPI()
        }
    }
    
    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        title = "Customers"
    }
    
    func setupSearchController() {
        // Configure the search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search customers..."
        
        // Add the search controller to the navigation item
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // Define the scope bar
        definesPresentationContext = true
    }
    
    func fetchLocalCustomers(){
        Task { @MainActor in
            do {
                let request = Customer.fetchRequest() as NSFetchRequest<Customer>
                
                // If searching, add the search predicate
                if isFiltering {
                    let searchText = searchController.searchBar.text!
                    let predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchText)
                    request.predicate = predicate
                }
                
                let results = try context.fetch(request)
                
                if isFiltering {
                    self.filteredCustomers = results
                } else {
                    self.customers = results
                    self.filteredCustomers = results
                }
                
                self.tableView.reloadData()
            } catch {
                print("Error fetching customers: \(error)")
            }
        }
    }
    
    func fetchCustomersFromAPI() async {
        do {
            let dtos = try await apiService.populateCustomers()
            
            // Save to CoreData
            await MainActor.run {
                for dto in dtos {
                    let fetchRequest: NSFetchRequest<Customer> = Customer.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "id == %d", dto.id)
                    
                    do {
                        let existingCustomers = try context.fetch(fetchRequest)
                        if let existingCustomer = existingCustomers.first {
                            // Update existing customer
                            existingCustomer.name = dto.name
                            existingCustomer.age = Int64(dto.age)
                            existingCustomer.email = dto.email
                            
                            if let imageData = try? Data(contentsOf: URL(string: dto.profilePictureUrl)!) {
                                existingCustomer.profilePicture = imageData
                            }
                        } else {
                            // Create new customer
                            _ = Customer.fromDTO(dto, context: context)
                        }
                        
                        try context.save()
                    } catch {
                        print("Error saving customer: \(error)")
                    }
                }
                
                fetchLocalCustomers()
            }
        } catch {
            print("Error fetching customers from API: \(error)")
        }
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        fetchLocalCustomers()
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Fetch results as user types
        fetchLocalCustomers()
    }
    
    //Add function
    //use segue to navigate the add
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addCustomerSegue" {
            if let addVC = segue.destination as? AddCustomerViewController {
                addVC.delegate = self
            }
        }
    }
    
    
    //Edit function
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let customer = self.customers![indexPath.row]

        // Create and configure the details view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let customerVC = storyboard.instantiateViewController(withIdentifier: "CustomerViewController") as? CustomerViewController {
            // Pass the data
            customerVC.customer = customer
            customerVC.delegate = self
            
            // Push the view controller
            navigationController?.pushViewController(customerVC, animated: true)
        }
    }
    
    //Delete function
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let customerToRemove: Customer?
            if isFiltering {
                customerToRemove = filteredCustomers?[indexPath.row]
            } else {
                customerToRemove = customers?[indexPath.row]
            }
            
            guard let customer = customerToRemove else { return }
            
            //Customers with existing Insurance Policies cannot be deleted.
            let fetchRequest: NSFetchRequest<Policy> = Policy.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "customer_id == %@", customer.id ?? "")
            
            do {
                let policies = try context.fetch(fetchRequest)
                
                if !policies.isEmpty {
                    // Show alert that customer cannot be deleted
                    showDeleteFailedAlert()
                    return  // Exit the method without deleting
                }
            
                self.context.delete(customer)
                
                try self.context.save()
                customers?.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                showDeleteSuccessAlert()
                
                //log
                print("\(customer.name ?? "") deleted")
            } catch {
                print("Error deleting customers: \(error)")
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
            message: "Failed to delete customer. Customers with existing Insurance Policies cannot be deleted",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alert, animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredCustomers?.count ?? 0
        }
        return customers?.count ?? 0
    }

    //present the detail
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerCell", for: indexPath)
        let customer: Customer?
        if isFiltering {
            customer = filteredCustomers?[indexPath.row]
        } else {
            customer = customers?[indexPath.row]
        }
        
        cell.textLabel?.text = customer?.name
        cell.imageView?.image = UIImage(systemName: "person.circle.fill")
        
        Task {
            do {
                var image: UIImage?
                
                // First try to load from Core Data
                 if let profilePictureData = customer?.profilePicture {
                     image = UIImage(data: profilePictureData)
                 }
                 
                 // If no image in Core Data, try to load from URL
                 if image == nil, let profilePictureUrl = customer?.profilePictureUrl {
                     image = try await apiService.populateCustomerImage(from: profilePictureUrl)
                     
                     // Save the image data to Core Data for future use
                     if let imageData = image?.jpegData(compressionQuality: 0.8) {
                         customer?.profilePicture = imageData
                         try? context.save()
                     }
                 }
                 
                 await MainActor.run {
                     if let currentCell = tableView.cellForRow(at: indexPath) {
                         if let finalImage = image {
                             currentCell.imageView?.image = finalImage
                         } else {
                             currentCell.imageView?.image = UIImage(systemName: "person.circle.fill")
                         }
                         currentCell.setNeedsLayout()
                     }
                 }
            } catch {
                print("Error loading image: \(error)")
                await MainActor.run {
                    if let currentCell = tableView.cellForRow(at: indexPath) {
                        currentCell.imageView?.image = UIImage(systemName: "person.circle.fill")
                        currentCell.setNeedsLayout()
                    }
                }
            }
        }
        
        return cell
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

// MARK: - Update Delegate Protocol
protocol UpdateCustomerProfileDelegate: AnyObject {
    func didUpdateCustomerProfile(_ customer: Customer)
}

// MARK: - Search Results Updating
extension CustomerTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        fetchLocalCustomers()
    }
}

// MARK: - Add Extension for Delegate
extension CustomerTableViewController: AddCustomerDelegate {
    func didAddCustomer(_ customer: Customer) {
        // Refresh the table view data
        self.fetchLocalCustomers()
    }
}

extension CustomerTableViewController: UpdateCustomerDelegate {
    func didUpdateCustomer(_ updatedCustomer: Customer) {
        if let index = customers?.firstIndex(where: { $0.id == updatedCustomer.id }) {
            customers?[index] = updatedCustomer
            tableView.reloadData()
        }

    }
}

extension CustomerTableViewController: UpdateCustomerProfileDelegate {
    func didUpdateCustomerProfile(_ updatedCustomer: Customer) {
        // Fetch fresh data from Core Data
        fetchLocalCustomers()
        
        // Force reload the specific row if we know the index
        if let index = customers?.firstIndex(where: { $0.id == updatedCustomer.id }) {
            let indexPath = IndexPath(row: index, section: 0)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}

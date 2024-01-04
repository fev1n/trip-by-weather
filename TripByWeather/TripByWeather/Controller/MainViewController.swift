//
//  MainViewController.swift
//  TripByWeather
//
//  Created by Fevin Patel on 2023-12-06.
//

import UIKit
import CoreData

class MainViewController: UIViewController {
    
    var cd : CoreDataStack!

    @IBOutlet weak var searchView: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    
    
    @IBAction func editBtn(_ sender: UIBarButtonItem) {
                self.tableView.isEditing = !self.tableView.isEditing
                sender.title = (self.tableView.isEditing) ? "Done" : "Edit"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    lazy var fetchResultController: NSFetchedResultsController<TripData> = {
        
        let fetchRequest: NSFetchRequest<TripData> = TripData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "city", ascending: true)]
        
        let fetchedRC = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: CoreDataStack.shared.persistentContainer.viewContext,
            sectionNameKeyPath: "city",
            cacheName: nil
        )
        fetchedRC.delegate = self
        return fetchedRC
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        try? fetchResultController.performFetch()
        
        searchView.text = ""
        tableView.reloadData()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "searchSegue" {
            let searchVC = segue.destination as? SearchViewController
            searchVC?.cd = cd
        } else if segue.identifier == "todoSegue" {
            let todoVC = segue.destination as? TodoListViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                todoVC?.city = fetchResultController.object(at: indexPath)
            }
        }
    }
}


// MARK: - Extended Delegations

extension MainViewController : NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        @unknown default:
            print("Unexpected NSFetchedResultsChangeType: \(type)")}
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let indexSet = IndexSet(integer: sectionIndex)
        
        switch type {
        case .insert:
            tableView.insertSections(indexSet, with: .fade)
        case .delete:
            tableView.deleteSections(indexSet, with: .fade)
        case .move, .update:
            print("Warning: Unexpected NSFetchedResultsChangeType for section: \(type)")
        @unknown default:
            print("Unexpected NSFetchedResultsChangeType for section: \(type)")}
    }
}

extension MainViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchResultController.sections?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchResultController.sections? [section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let citytbd = fetchResultController.object(at: indexPath)
            fetchResultController.managedObjectContext.delete(citytbd)
            try? fetchResultController.managedObjectContext.save()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath)
        let city = fetchResultController.object(at: indexPath)
        
        print(city)
        
        cell.textLabel?.text = city.city ?? "Not a city"
        cell.detailTextLabel?.text = String(format: "%.2f", city.temp)
        
        let tempIcon = "http://openweathermap.org/img/wn/\(fetchResultController.object(at: indexPath).icon ?? "10d")@2x.png"
        
        print(tempIcon)
        
        Service.fetchImage(urlstr: tempIcon){(image) in
            DispatchQueue.main.async {
                cell.imageView?.image = image
                cell.setNeedsLayout()
            }
        }
        return cell
    }
}

extension MainViewController : UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let predicate: NSPredicate?
        
        if !searchText.isEmpty {
            predicate = NSPredicate(format: "city BEGINSWITH[c] %@", searchText)
        } else {
            predicate = nil
        }
        fetchResultController.fetchRequest.predicate = predicate
        
        do {
            try fetchResultController.performFetch()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

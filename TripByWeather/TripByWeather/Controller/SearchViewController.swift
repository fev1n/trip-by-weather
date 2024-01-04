//
//  SearchViewController.swift
//  TripByWeather
//
//  Created by Fevin Patel on 2023-12-06.
//

import UIKit
import CoreData

class SearchViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    var fetchedResultController: NSFetchedResultsController<TripData>!
    
    var cd: CoreDataStack!
    var currentSessionTask: URLSessionTask?
    var cities: [String]?
    var city: TripData!
    
    @IBOutlet weak var searchView: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        searchView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        try? fetchResultController.performFetch()

    }
    
    func addCity(name: String) {
        let citytba = TripData(context: CoreDataStack.shared.persistentContainer.viewContext)
        citytba.city = name.components(separatedBy: ",")[0]

        let cityName = citytba.city ?? "DefaultCity"
        let url = "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=4f4630df97f956113585cc53d9e4f1a2"
        print(url)

        Service.shared.getDataFromAPI(url: url) { [unowned self] (data) in
            DispatchQueue.main.async {
                citytba.temp = data.main.temp 
                citytba.icon = data.weather.first?.icon
                CoreDataStack.shared.saveContext()
                self.tableView.reloadData()
            }
        }

        let alertVC = UIAlertController(title: "Successful", message: "\(citytba.city ?? "") is added to your list", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            self.navigationController?.popViewController(animated: true)
        }
        alertVC.addAction(okAction)
        alertVC.view.layoutIfNeeded()
        present(alertVC, animated: true, completion: nil)

    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    lazy var fetchResultController: NSFetchedResultsController<TripData> = {
        
        let fetchRequest: NSFetchRequest<TripData> = TripData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "city", ascending: false)]
        
        let fetchedRC = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: CoreDataStack.shared.persistentContainer.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedRC.delegate = self
        return fetchedRC
    }()
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "citiesCell", for: indexPath)
        
        let city = cities?[indexPath.row]
        cell.textLabel?.text = city?.components(separatedBy: ",")[0] ?? ""
        
        if let count = city?.count {
            guard count > 2 && cell.textLabel?.text != nil else {
                return cell
            }
            cell.detailTextLabel?.text = city?.components(separatedBy: ",")[2] ?? ""
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cityName = cities?[indexPath.row] {
            addCity(name: cityName)
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func handleSearchCityResponse(cities: [String]?, error: Error?) {
        if let error = error {
            print("Error: \(error.localizedDescription)")
            return
        }
        
        self.cities = cities
        tableView.reloadData()
    }

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentSessionTask?.cancel()
        guard searchText.count > 2 else {
            cities?.removeAll()
            tableView.reloadData()
            return
        }
        
        currentSessionTask = Service.fetchCities(from: Service.Endpoints.getCity(searchText).url, completion: handleSearchCityResponse(cities:error:))
    }
}

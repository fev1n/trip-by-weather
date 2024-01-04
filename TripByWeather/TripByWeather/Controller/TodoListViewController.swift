//
//  TodoListViewController.swift
//  TripByWeather
//
//  Created by Fevin Patel on 2023-12-07.
//

import UIKit
import CoreData

class TodoListViewController: UIViewController {

    var city: TripData!
    var todosList: [String] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var navbar: UINavigationItem!
        
    
    @IBAction func addBtn(_ sender: Any) {
        guard let todoTxt = textField.text,
              !todoTxt.isEmpty else {
            return
        }
        
        todosList.append(todoTxt)
        
        DispatchQueue.main.async {
                 self.tableView.reloadData()
             }
        
        
        print("Task added: \(todoTxt)")
        print("Updated todosList: \(todosList)")
        
        textField.text = ""

    }
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.dataSource = self
        navbar.title = city.city
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonTapped))
                let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
                navigationItem.rightBarButtonItem = saveButton
                navigationItem.leftBarButtonItem = cancelButton
        
        }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        print("Save button tapped")
        dismiss(animated: true, completion: nil)
    }
        
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        print("Cancel button tapped")
        dismiss(animated: true, completion: nil)
    }
    
    
    func handleCityWeatherResponse(response: Decodable?, error: Error?) {
        guard response is WeatherInfo else {
            print("Error: \(error?.localizedDescription ?? "Unknown error")")
            return
        };
        }
    }

extension TodoListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todosList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath)
        
        let todo = todosList[indexPath.row]
        
        cell.textLabel?.text = todo
        return cell
    }
    
}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */



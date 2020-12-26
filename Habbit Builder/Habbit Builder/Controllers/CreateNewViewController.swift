//
//  CreateNewViewController.swift
//  Habbit Builder
//
//  Created by Michael Hong on 2020-06-22.
//  Copyright © 2020 Junhyeok Hong. All rights reserved.
//

import UIKit
import RealmSwift

class CreateNewViewController: UIViewController {
    
    //MARK: - Initialization
    let realm = try! Realm()
    var data = HabbitData()
    
    let todaysDate = Date()
    let format = DateFormatter()
    var todaysDateString = ""
    
    @IBOutlet weak var newHabbitTableView: UITableView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var notesTextField: UITextField!
    
    let tableViewDatasource = [
        ["Repeat", "Everyday >"],
        ["Start Date", "Today >"],
        ["Notification", "9:00 AM >"],
    ]
    
    var repeatedDatesSelection = ""
    var startingDateSelection = Date()
    
    //MARK: - View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        format.dateFormat = "yyyy-MM-dd"
        todaysDateString = format.string(from: todaysDate)
        
        newHabbitTableView.dataSource = self
        newHabbitTableView.delegate = self
        newHabbitTableView.rowHeight = 70
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        if let text = titleTextField.text {
            if !text.trimmingCharacters(in: .whitespaces).isEmpty {
                data.name = text //Add name from the textfield
                
                if let notes = notesTextField.text {
                    data.notes = notes
                }
                
                if repeatedDatesSelection == "" {
                    repeatedDatesSelection =  "MonTueWedThuFriSatSun"
                }
                data.repeatingDates.append(repeatedDatesSelection)

                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let dateString = dateFormatter.string(from: startingDateSelection)
                startingDateSelection = dateFormatter.date(from: dateString)!
                data.startingDate = startingDateSelection
                
                
                do {
                    try realm.write {
                        realm.add(data)
                        let parentVC = UIViewController()
                        parentVC.viewWillAppear(true) //Update tableview in view controller
                        self.navigationController?.popToRootViewController(animated:true)
                    }
                } catch {
                    print("Error saving data \(error)")
                }
            }
        }
    }
}

//MARK: - UITableview Datasource Methods
extension CreateNewViewController: UITableViewDataSource {
    
    // Return the number of rows for the table.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewDatasource.count
    }
    
    // Provide a cell object for each row.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Fetch a cell of the appropriate type.
        let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath)
        
        // Configure the cell’s contents.
        cell.textLabel!.text = tableViewDatasource[indexPath.row][0]
        cell.detailTextLabel?.text = tableViewDatasource[indexPath.row][1]
        cell.detailTextLabel?.textColor = UIColor.init(white: 0.5, alpha: 1)
        
        return cell
    }
}

//MARK: - UITableview Delegate Methods
extension CreateNewViewController: UITableViewDelegate, SelectDatesViewControllerDelegate, DatePickerViewControllerDelegate {
    func sendStartingDate(startingDate: Date) {
        self.startingDateSelection = startingDate
    }
    
    func sendSelectedDates(selectedDays: String) {
        self.repeatedDatesSelection = selectedDays
    }
    
    // Perform segue
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            performSegue(withIdentifier: "repeatDates", sender: self)
        } else if indexPath.row == 1 {
            performSegue(withIdentifier: "pickDate", sender: self)
        }
    }
    
    // Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = newHabbitTableView.indexPathForSelectedRow {
            if indexPath.row == 0 {
                let destinationVC = segue.destination as! SelectDatesViewController
                destinationVC.delegate = self
            } else if indexPath.row == 1 {
                let destinationVC = segue.destination as! DatePickerViewController
                destinationVC.delegate = self
            }
        }
    }
}


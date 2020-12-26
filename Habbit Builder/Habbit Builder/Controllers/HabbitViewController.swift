//
//  HabbitViewController.swift
//  Habbit Builder
//
//  Created by Michael Hong on 2020-06-22.
//  Copyright © 2020 Junhyeok Hong. All rights reserved.
//

import UIKit
import DateScrollPicker
import RealmSwift
import SwipeCellKit

class HabbitViewController: UIViewController {
    
    //MARK: - Outlets & Initialization
    @IBOutlet weak var dateScrollPicker: DateScrollPicker!
    @IBOutlet weak var habbitTableView: UITableView!
    
    let realm = try! Realm()
    var habbitDatas: Results<HabbitData>?
    var currentData = HabbitData()
    var todaysDate = Date()
    var todaysDateString: String = ""
    var currentDate = Date()
    var currentDateString: String = ""
    var currentDateDatas = [HabbitData]()
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let todaysDateFormatter = DateFormatter()
        todaysDateFormatter.dateFormat = "yyyy-MM-dd"
        todaysDateString = todaysDateFormatter.string(from: todaysDate)
        todaysDate = todaysDateFormatter.date(from: todaysDateString)!
        currentDate = todaysDate
        
        formatDateScrollPicker()
        currentDateString = stringCurrentDate(currentDate)
        dateScrollPicker(dateScrollPicker, didSelectDate: currentDate)
        
        habbitDatas = realm.objects(HabbitData.self)
        habbitTableView.dataSource = self
        habbitTableView.delegate = self
        dateScrollPicker.delegate = self
        
        habbitTableView.rowHeight = 50.0
        habbitTableView.reloadData()
    }
    
    //MARK: - View will appear
    override func viewWillAppear(_ animated: Bool) {
        dateScrollPicker(dateScrollPicker, didSelectDate: currentDate)
        habbitTableView.reloadData()
    }
    
    
    //MARK: - View Controller Methods
    // Return the string of a date
    func stringCurrentDate(_ date: Date) -> String {
        let format = DateFormatter()
        format.dateFormat = "EEE"
        return format.string(from: date)
    }
    
    // Format the date scroll picker
    func formatDateScrollPicker() {
        var format = DateScrollPickerFormat()
        format.topDateFormat = "yyyy/MM/dd"
        format.mediumDateFormat = "EEE"
        format.bottomDateFormat = ""
        format.mediumFont = UIFont.systemFont(ofSize: 25, weight: .bold)
        format.dayBackgroundColor = UIColor.init(white: 0.9, alpha: 0.5)
        format.mediumTextColor = UIColor.init(white: 0.7, alpha: 0.8)
        format.topTextColor = UIColor.init(white: 0.7, alpha: 0.8)
        format.dayBackgroundSelectedColor = UIColor.init(white: 0.9, alpha: 0.5)
        format.mediumTextSelectedColor = UIColor.black
        format.topTextSelectedColor = UIColor.black
        format.separatorEnabled = false
        format.fadeEnabled = true
        format.animationScaleFactor = 1
        format.dayPadding = 3
        dateScrollPicker.format = format
        dateScrollPicker.selectToday()
    }
    
    
}

//MARK: - UI Tableview Datasource Methods
extension HabbitViewController: UITableViewDataSource {
    
    // Return the number of rows for the table.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentDateDatas.count
    }
    
    // Provide a cell object for each row.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Fetch a cell of the appropriate type.
        let cell = tableView.dequeueReusableCell(withIdentifier: "habbitCellTypeIdentifier", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        
        // Configure the cell’s contents.
        let data = currentDateDatas[indexPath.row]
        cell.textLabel!.text = data.name
        
        if data.isDoneDates.index(of: currentDate) != nil {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
}

//MARK: - UI Tableview Delegate Methods
extension HabbitViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = currentDateDatas[indexPath.row]
        if let index = data.isDoneDates.index(of: currentDate){ //If the habbit at that date is done
            do {
                try realm.write {
                    data.isDoneDates.remove(at: index)
                }
            } catch {
                print("Error updating data \(error)")
            }
        } else { //If the habbit at that date is not done
            do {
                try realm.write {
                    data.isDoneDates.append(currentDate)
                }
            } catch {
                print("Error updating data \(error)")
            }
        }
        habbitTableView.reloadData()
    }
}

//MARK: - Date scroll picker Delegate Methods
extension HabbitViewController: DateScrollPickerDelegate {
    func dateScrollPicker(_ dateScrollPicker: DateScrollPicker, didSelectDate date: Date) {
        currentDate = date
        currentDateString = stringCurrentDate(date)
        if let realmData = habbitDatas {
            currentDateDatas.removeAll()
            for data in realmData {
                let userCalendar = Calendar.current
                let timeDifference = userCalendar.dateComponents([.day], from: data.startingDate, to: currentDate)
                if data.repeatingDates.contains(currentDateString) && (timeDifference.day!) >= 0{
                    currentDateDatas.append(data)
                }
            }
        }
        habbitTableView.reloadData()
    }
}

extension HabbitViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            self.updateModel(at: indexPath)
        }
        
        let infoAction = SwipeAction(style: .default, title: "Info") { action, indexPath in
            // handle action by updating model with deletion
            self.currentData = self.currentDateDatas[indexPath.row]
            self.performSegue(withIdentifier: "info", sender: self)
        }
        
        // customize the action appearance
        return [deleteAction, infoAction]
    }
    
    func updateModel(at indexPath: IndexPath) {
        let habbitForDeletion = currentDateDatas[indexPath.row]
        do {
            try realm.write {
                realm.delete(habbitForDeletion)
                self.viewWillAppear(true)
            }
        } catch {
            print("Error deleting category, \(error)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is InfoViewController {
            let destinationVC = segue.destination as! InfoViewController
                destinationVC.data = currentData
        }
    }
}

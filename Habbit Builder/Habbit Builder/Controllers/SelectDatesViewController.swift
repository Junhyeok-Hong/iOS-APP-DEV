//
//  SelectDatesViewController.swift
//  Habbit Builder
//
//  Created by Michael Hong on 2020-06-29.
//  Copyright © 2020 Junhyeok Hong. All rights reserved.
//

import UIKit

protocol SelectDatesViewControllerDelegate {
    func sendSelectedDates(selectedDays: String)
}

class SelectDatesViewController: UITableViewController {
    
    var delegate: SelectDatesViewControllerDelegate?
    
    var daysSelected = ""
    var days = [
        ["Monday", true],
        ["Tuesday",  true],
        ["Wednesday",  true],
        ["Thursday",  true],
        ["Friday",  true],
        ["Saturday",  true],
        ["Sunday", true]]
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        for day in days {
            if (day[1] as! Bool) {
                daysSelected.append((day[0] as! String))
            }
        }
        delegate?.sendSelectedDates(selectedDays: daysSelected)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Fetch a cell of the appropriate type.
        let cell = tableView.dequeueReusableCell(withIdentifier: "dateSelectorCell", for: indexPath)
        
        // Configure the cell’s contents.
        cell.textLabel!.text = (days[indexPath.row][0] as! String)
        cell.accessoryType = .checkmark
        
        return cell
    }
    
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if !(days[indexPath.row][1] as! Bool) {
                tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                days[indexPath.row][1] = true
            } else {
                tableView.cellForRow(at: indexPath)?.accessoryType = .none
                days[indexPath.row][1] = false
            }
    }
}

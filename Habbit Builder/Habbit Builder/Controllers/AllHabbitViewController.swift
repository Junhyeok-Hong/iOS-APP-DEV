//
//  AllHabbitViewController.swift
//  Habbit Builder
//
//  Created by Michael Hong on 2020-07-20.
//  Copyright © 2020 Junhyeok Hong. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit
import PopupDialog

class AllHabbitViewController: UIViewController {
    
    @IBOutlet weak var allHabbitTableView: UITableView!
    
    let realm = try! Realm()
    var habbitDatas: Results<HabbitData>?
    var currentData = HabbitData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        habbitDatas = realm.objects(HabbitData.self)
        allHabbitTableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        allHabbitTableView.reloadData()
    }
    
    @IBAction func removeAllHabbitData(_ sender: UIButton) {
        showStandardDialog()
    }
    
    func showStandardDialog(animated: Bool = true) {

        // Prepare the popup
        let title = "WARNING"
        let message = "Are you sure you want to delete all Habbit items?"

        // Create the dialog
        let popup = PopupDialog(title: title,
                                message: message,
                                buttonAlignment: .horizontal,
                                transitionStyle: .zoomIn,
                                tapGestureDismissal: true,
                                panGestureDismissal: true,
                                hideStatusBar: true) {
        }

        // Create first button
        let buttonOne = CancelButton(title: "CANCEL") {
            
        }

        // Create second button
        let buttonTwo = DefaultButton(title: "DELETE") {
            if let habbitDatasCount = self.habbitDatas?.count {
                var indexPathCount = habbitDatasCount - 1
                while indexPathCount >= 0 {
                    print(indexPathCount)
                    if let habbitForDeletion = self.habbitDatas?[indexPathCount] {
                        print(habbitForDeletion.name)
                        do {
                            try self.realm.write {
                                self.realm.delete(habbitForDeletion)
                                indexPathCount -= 1
                            }
                        } catch {
                            print("Error deleting category, \(error)")
                        }
                    }
                }
                self.viewWillAppear(true)
            }
        }

        // Add buttons to dialog
        popup.addButtons([buttonOne, buttonTwo])

        // Present dialog
        self.present(popup, animated: animated, completion: nil)
    }
    
}


extension AllHabbitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return habbitDatas?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "allHabbitCellTypeIdentifier", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        
        if let data = habbitDatas?[indexPath.row] {
            cell.textLabel?.text = data.name
        }
        
        return cell
    }
    
    
}

extension AllHabbitViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            
            self.updateModel(at: indexPath)
        }
        
        let infoAction = SwipeAction(style: .default, title: "Info") { action, indexPath in
            
            if let habbitData = self.habbitDatas?[indexPath.row] {
                self.currentData = habbitData
                self.performSegue(withIdentifier: "allInfo", sender: self)
            }
        }
        
        // customize the action appearance
        return [deleteAction, infoAction]
    }
    
    func updateModel(at indexPath: IndexPath) {
        if let habbitForDeletion = habbitDatas?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(habbitForDeletion)
                    self.viewWillAppear(true)
                }
            } catch {
                print("Error deleting category, \(error)")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is InfoViewController {
            let destinationVC = segue.destination as! InfoViewController
            destinationVC.data = currentData
        }
    }
    
    
}

//
//  DatePickerViewController.swift
//  Habbit Builder
//
//  Created by Michael Hong on 2020-06-29.
//  Copyright © 2020 Junhyeok Hong. All rights reserved.
//

import UIKit

protocol DatePickerViewControllerDelegate {
    func sendStartingDate(startingDate: Date)
}

class DatePickerViewController: UIViewController {
    var delegate: DatePickerViewControllerDelegate?

    @IBOutlet weak var datePicker: UIDatePicker!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.datePickerMode = .date
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func datePicked(_ sender: UIDatePicker) {
        delegate?.sendStartingDate(startingDate: sender.date)
    }
}

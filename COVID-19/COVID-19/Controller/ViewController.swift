//
//  ViewController.swift
//  COVID-19
//
//  Created by Michael Hong on 2020-04-18.
//  Copyright © 2020 Junhyeok Hong. All rights reserved.
//

import UIKit

class ViewController: UIViewController {


    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var infectedLabel: UILabel!
    @IBOutlet weak var recoveredLabel: UILabel!
    @IBOutlet weak var deceasedLabel: UILabel!
    
    var covidManager = CovidManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        covidManager.delegate = self
        textField.delegate = self
    }


}

//MARK: - UITextFieldDelegate

extension ViewController: UITextFieldDelegate {
    
    @IBAction func searchPressed(_ sender: UIButton) {
        textField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "Search for a Country"
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if let country = textField.text {
            covidManager.fetchCovidData(countryName: country)
        }
        
        textField.text = ""
    }
}

//MARK: - CovidManagerDelegate

extension ViewController: CovidManagerDelegate {
    func didFailWithError(error: Error) {
        print(error)
    }
    
    func didUpdateCovidData(_ covidManager: CovidManager, covidData: CovidModel) {
        DispatchQueue.main.async {
            self.countryLabel.text = "Country : \(covidData.countryName)"
            self.infectedLabel.text = "Infected : \(covidData.infected)"
            self.recoveredLabel.text = "Recovered : \(covidData.recovered)"
            self.deceasedLabel.text = "Deceased: \(covidData.deceased)"
        }
    }
    

}

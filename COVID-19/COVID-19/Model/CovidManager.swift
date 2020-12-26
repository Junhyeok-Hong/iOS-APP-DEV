//
//  CovidManager.swift
//  COVID-19
//
//  Created by Michael Hong on 2020-04-25.
//  Copyright © 2020 Junhyeok Hong. All rights reserved.
//

import Foundation

protocol CovidManagerDelegate {
    func didUpdateCovidData(_ covidManager: CovidManager, covidData: CovidModel)
    func didFailWithError(error: Error)
}

struct CovidManager {
    let covidURL = "https://api.apify.com/v2/key-value-stores/tVaYRsPHLjNdNBu7S/records/LATEST?disableRedirect=true"
    
    var delegate: CovidManagerDelegate?
    
    func fetchCovidData(countryName: String) {
        performRequest(for: countryName)
    }
    
    func performRequest(for countryName: String) {
        //1. Create a URL
        if let url = URL(string: covidURL) {
            
            //2. Create a URLSession
            let session = URLSession(configuration: .default)
            
            //3. Give the session a task
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let covidData = self.parseJSON(safeData, countryName) {
                        self.delegate?.didUpdateCovidData(self, covidData: covidData)
                    }
                }
            }
            
            //4. Start the task
            task.resume()
        }
    }
    
    func parseJSON(_ covidData: Data, _ countryName: String) -> CovidModel? {
        let decoder = JSONDecoder()
        var covid: CovidModel?
        do {
            let decodedData = try decoder.decode([CovidData].self, from: covidData)
            for index in 0...decodedData.count - 1 {
                if decodedData[index].country == countryName {
                    let infected = decodedData[index].infected
                    let recovered = decodedData[index].recovered
                    let deceased = decodedData[index].deceased
                    covid = CovidModel(countryName: countryName, infected: infected, recovered: recovered, deceased: deceased)
                    return covid
                } else {
                    covid = CovidModel(countryName: "No country named \" \(countryName) \". Please Check the Country Name", infected: "Error", recovered: "Error", deceased: "Error")
                }
            }
            return covid
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}

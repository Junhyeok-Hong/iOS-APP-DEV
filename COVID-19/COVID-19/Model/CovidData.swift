//
//  CovidData.swift
//  COVID-19
//
//  Created by Michael Hong on 2020-04-25.
//  Copyright © 2020 Junhyeok Hong. All rights reserved.
//

import Foundation
import AnyCodable

struct CovidData: Codable {
    let country: String
    let infected: AnyCodable
    let recovered: AnyCodable
    let deceased: AnyCodable
    
}

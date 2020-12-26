//
//  HabbitData.swift
//  Habbit Builder
//
//  Created by Michael Hong on 2020-06-22.
//  Copyright © 2020 Junhyeok Hong. All rights reserved.
//

import Foundation
import RealmSwift

class HabbitData: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var notes: String = ""
    @objc dynamic var repeatingDates: String = ""
    @objc dynamic var startingDate: Date = Date()
    let isDoneDates = List<Date>()
}

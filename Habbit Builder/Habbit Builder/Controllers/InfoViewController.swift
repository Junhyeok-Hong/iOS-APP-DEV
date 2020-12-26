//
//  InfoViewController.swift
//  Habbit Builder
//
//  Created by Michael Hong on 2020-07-08.
//  Copyright © 2020 Junhyeok Hong. All rights reserved.
//

import UIKit
import RealmSwift
import JTAppleCalendar

class InfoViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var infoPageTitle: UILabel!
    @IBOutlet weak var monthView: JTACMonthView!
    
    let realm = try! Realm()
    var data = HabbitData()
    
    let descriptionSource: [String] = ["Start Date", "Progress Rate", "Success Rate", "Current Streak"]
    var dataSource: [String] = ["0", "0", "0", "0"]
    
    var todaysDate = Date()
    var doneDatesForMonth = [Date]()
    var doneDatesForMonthThatPassed = [Date]()
    var allDatesForMonth = [Date]()
    var mustDoneDatesForMonth = [Date]()
    var mustDoneDatesForMonthThatPassed = [Date]()
    var progressRatePercentage = 0.0
    var successRatePercentage = 0.0
    var startDate = Date().startOfMonth
    var lastDate = Date().endOfMonth
    
    override func viewWillAppear(_ animated: Bool) {
        monthView.scrollToDate(startDate)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        monthView.scrollingMode = .stopAtEachCalendarFrame
        monthView.scrollDirection = .horizontal
        
        monthView.calendarDataSource = self
        monthView.calendarDelegate = self
        monthView.allowsMultipleSelection = true
        monthView.allowsRangedSelection = true
        
        collectionView.dataSource = self
        let width = collectionView.frame.size.width / 2
        let height = collectionView.frame.size.height / 2
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: height)
        
        let format = DateFormatter()
        format.dateFormat = "yyyy/MM/dd"
        dataSource[0] = format.string(from: data.startingDate)
        
        var incrementMonthDaily = startDate
        doneDatesForMonth.removeAll()
        doneDatesForMonthThatPassed.removeAll()
        mustDoneDatesForMonth.removeAll()
        mustDoneDatesForMonthThatPassed.removeAll()
        allDatesForMonth.removeAll()
        
        while incrementMonthDaily <= lastDate { //Add all days of the month to the array
            allDatesForMonth.append(incrementMonthDaily)
            incrementMonthDaily = Calendar.current.date(byAdding: .day, value: 1, to: incrementMonthDaily)!
        }
        
        let doneDates = data.isDoneDates.sorted(by: <)
        
        for sortedData in doneDates { //Add all the done dates to the array
            if sortedData >= startDate && sortedData <= lastDate{
                doneDatesForMonth.append(sortedData)
                if sortedData <= todaysDate {
                    doneDatesForMonthThatPassed.append(sortedData)
                }
            }
        }
        
        for dateInMonthByDays in allDatesForMonth {
            format.dateFormat = "EEE"
            if data.repeatingDates.contains(format.string(from: dateInMonthByDays)) && dateInMonthByDays >= data.startingDate {
                mustDoneDatesForMonth.append(dateInMonthByDays)
                if dateInMonthByDays < todaysDate {
                    mustDoneDatesForMonthThatPassed.append(dateInMonthByDays)
                }
            }
        }
        
        progressRatePercentage = (Double(doneDatesForMonth.count) / Double(mustDoneDatesForMonth.count)) * 100
        dataSource[1] = "\(((progressRatePercentage*100).rounded() / 100))%"
        
        successRatePercentage = (Double(doneDatesForMonthThatPassed.count) / Double(mustDoneDatesForMonthThatPassed.count)) * 100
        if successRatePercentage > 100 {
            dataSource[2] = "100%"
        } else if successRatePercentage.isNaN {
            dataSource[2] = "0.0%"
        }
        else {
            dataSource[2] = "\(((successRatePercentage*100).rounded() / 100))%"
        }
    }
}

extension Date {
    var startOfMonth: Date {
        
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month], from: self)
        
        return  calendar.date(from: components)!
    }
    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfMonth)!
    }
}

extension InfoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        if let dataCell = collectionView.dequeueReusableCell(withReuseIdentifier: "InfoCell", for: indexPath) as? InfoCollectionViewCell {
            dataCell.configure(dataIs: dataSource[indexPath.row], descriptionIs: descriptionSource[indexPath.row])
            cell = dataCell
        }
        cell.layer.borderColor = CGColor.init(srgbRed: 0, green: 0, blue: 0, alpha: 1)
        cell.layer.borderWidth = 1
        return cell
    }
    
    
}

extension InfoViewController: JTACMonthViewDataSource {
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        let startDate = data.startingDate
        let endDate = Date(timeIntervalSinceReferenceDate: 6178140000)
        return ConfigurationParameters(startDate: startDate, endDate: endDate, numberOfRows: 6, generateInDates: .forAllMonths, generateOutDates: .tillEndOfRow,  hasStrictBoundaries: true)
    }
    
    
}

extension InfoViewController: JTACMonthViewDelegate {
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "dateCell", for: indexPath) as! DateCell
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        return cell
    }
    
    //THE HEADER
    func calendar(_ calendar: JTACMonthView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTACMonthReusableView {
        let header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "month", for: indexPath) as! DateHeader
        header.layer.borderWidth = 1
        header.layer.borderColor = CGColor.init(srgbRed: 0, green: 0, blue: 0, alpha: 0.2)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        infoPageTitle.text = formatter.string(from: range.start)
        
        startDate = range.start.startOfMonth
        lastDate = range.end.endOfMonth
        viewDidLoad()
        collectionView.reloadData()
        
        return header
    }
    
    //UPDATES THE HEADER
    func calendarSizeForMonths(_ calendar: JTACMonthView?) -> MonthSize? {
        return MonthSize(defaultSize: 50)
    }
    
    //CONFIGURE CELL
    func configureCell(view: JTACDayCell?, cellState: CellState) {
        guard let cell = view as? DateCell  else { return }
        cell.dateLabel.text = cellState.text
        handleCellSelected(cell: cell, cellState: cellState)
        handleCellTextColor(cell: cell, cellState: cellState)
    }
    
    func handleCellTextColor(cell: DateCell, cellState: CellState) {
        if cellState.dateBelongsTo == .thisMonth {
            cell.dateLabel.textColor = UIColor.black
        } else {
            cell.dateLabel.textColor = UIColor.gray
        }
    }
    
    func handleCellSelected(cell: DateCell, cellState: CellState) {
        cell.selectedView.isHidden = true
        cell.todayView.isHidden = true
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        let todaysDateString = formatter.string(from: todaysDate)
        todaysDate = formatter.date(from: todaysDateString)!
        
        if cellState.date == todaysDate {
            cell.todayView.isHidden = false
            cell.todayView.tintColor = UIColor.blue
        }
        
        if doneDatesForMonth.contains(cellState.date){
            cell.selectedView.isHidden = false
            cell.selectedView.tintColor = UIColor.red
        }
    }
}

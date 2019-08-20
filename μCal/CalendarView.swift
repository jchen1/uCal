//
//  CalendarView.swift
//  μCal
//
//  Created by Jeff Chen on 6/27/16.
//  Copyright © 2016 Jeff Chen. All rights reserved.
//

import Cocoa

class CalendarView: NSView {
    
    required init?(coder: NSCoder) {
        font = NSFont.systemFont(ofSize: 9.0)
        weekFont = NSFont.boldSystemFont(ofSize: 9.0)
        monthFont = NSFont.boldSystemFont(ofSize: NSFont.systemFontSize)
        yearFont = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        
        super.init(coder: coder)
        makeWeekdays()
        makeDays()
        makeButtons()
        makeMonthLabel()

        updateAppearance()
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(CalendarView.darkModeChanged), name: NSNotification.Name(rawValue: "AppleInterfaceThemeChangedNotification"), object: nil)
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(CalendarView.calendarUpdated), name: NSNotification.Name(rawValue: "NSCurrentLocaleDidChangeNotification"), object: nil)
    }
    
    override init(frame frameRect: NSRect) {
        font = NSFont.systemFont(ofSize: 9.0)
        weekFont = NSFont.boldSystemFont(ofSize: 9.0)
        monthFont = NSFont.boldSystemFont(ofSize: NSFont.systemFontSize)
        yearFont = NSFont.systemFont(ofSize: NSFont.systemFontSize)
    
        super.init(frame: frameRect)
        makeWeekdays()
        makeDays()
        makeButtons()
        makeMonthLabel()

        updateAppearance()
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(CalendarView.darkModeChanged), name: NSNotification.Name(rawValue: "AppleInterfaceThemeChangedNotification"), object: nil)
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(CalendarView.calendarUpdated), name: NSNotification.Name(rawValue: "NSCurrentLocaleDidChangeNotification"), object: nil)
    }
    
    var dateValue = Date()
    
    fileprivate var font: NSFont
    fileprivate var weekFont: NSFont
    fileprivate var monthFont: NSFont
    fileprivate var yearFont: NSFont
    
    fileprivate var monthLabel = NSTextField(frame: NSZeroRect)
    fileprivate var weekdayLabels: [NSTextField] = []
    fileprivate var days: [NSTextField] = []
    
    fileprivate var backButton = NSButton(frame: NSZeroRect)
    fileprivate var todayButton = NSButton(frame: NSZeroRect)
    fileprivate var forwardButton = NSButton(frame: NSZeroRect)
    fileprivate let buttonFont = NSFont.boldSystemFont(ofSize: NSFont.smallSystemFontSize)
    
    fileprivate let dateFormatter = DateFormatter()
    fileprivate let calendar = Calendar.autoupdatingCurrent
    fileprivate let dateUnitMask: NSCalendar.Unit =  [NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day, NSCalendar.Unit.weekday]
    fileprivate let dateTimeUnitMask: NSCalendar.Unit =  [NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day, NSCalendar.Unit.hour, NSCalendar.Unit.minute, NSCalendar.Unit.second, NSCalendar.Unit.weekday]
    
    class func lineHeightForFont(_ font: NSFont) -> CGFloat {
        let attribs = NSDictionary(object: font, forKey: NSAttributedString.Key.font as NSString)
        let size = "Aa".size(withAttributes: attribs as? [NSAttributedString.Key : AnyObject])
        return round(size.height)
    }
    
    fileprivate func getTitleString(_ month: String, year: String) -> NSAttributedString {
        let titleString = NSMutableAttributedString.init(string: month + " " + year)
        let monthAttribute = [NSAttributedString.Key.font: monthFont]
        let yearAttribute = [NSAttributedString.Key.font: yearFont]
        
        titleString.addAttributes(monthAttribute, range: (titleString.string as NSString).range(of: month))
        titleString.addAttributes(yearAttribute, range: (titleString.string as NSString).range(of: year))

        return titleString
    }
    
    fileprivate func makeMonthLabel() {
        monthLabel.isEditable = false
        monthLabel.isBordered = false
        monthLabel.backgroundColor = NSColor.clear
        
        let month = "ph"
        let year = "year"
        monthLabel.attributedStringValue = getTitleString(month, year: year)
        let height = monthLabel.attributedStringValue.size().height
        monthLabel.frame = NSRect(x: 5, y: NSMaxY(frame) - height - 1, width: 70, height: height)
        addSubview(monthLabel)
    }
    
    fileprivate func updateMonthLabel() {
        let month = self.calendar.shortMonthSymbols[(self.calendar as NSCalendar).component(NSCalendar.Unit.month, from: dateValue) - 1]
        let year = String((self.calendar as NSCalendar).component(NSCalendar.Unit.year, from: dateValue))
        monthLabel.textColor = getPrimaryColor()
        monthLabel.attributedStringValue = getTitleString(month, year: year)
    }
    
    fileprivate func makeButtons() {
        let attrs = [NSAttributedString.Key.foregroundColor: getPrimaryColor(), NSAttributedString.Key.font: buttonFont]
        
        let backString = NSMutableAttributedString(string: "◀", attributes: attrs)
        let todayString = NSMutableAttributedString(string: "●", attributes: [
            NSAttributedString.Key.foregroundColor: getPrimaryColor(),
            NSAttributedString.Key.font: NSFont.boldSystemFont(ofSize: 11.0)
            ])
        let forwardString = NSMutableAttributedString(string: "▶", attributes: attrs)
        
        backButton.attributedTitle = backString
        todayButton.attributedTitle = todayString
        forwardButton.attributedTitle = forwardString
        
        let alternateAttrs = [NSAttributedString.Key.foregroundColor: getSelectedColor(), NSAttributedString.Key.font: buttonFont]
        
        let backAltString = NSMutableAttributedString(string: "◀", attributes: alternateAttrs)
        let todayAltString = NSMutableAttributedString(string: "●", attributes: [
            NSAttributedString.Key.foregroundColor: getSelectedColor(),
            NSAttributedString.Key.font: NSFont.boldSystemFont(ofSize: 11.0)
            ])
        let forwardAltString = NSMutableAttributedString(string: "▶", attributes: alternateAttrs)
        
        backButton.attributedAlternateTitle = backAltString
        todayButton.attributedAlternateTitle = todayAltString
        forwardButton.attributedAlternateTitle = forwardAltString
        
        backButton.alignment = NSTextAlignment.center
        todayButton.alignment = NSTextAlignment.center
        forwardButton.alignment = NSTextAlignment.center
        
        backButton.setButtonType(NSButton.ButtonType.momentaryChange)
        todayButton.setButtonType(NSButton.ButtonType.momentaryChange)
        forwardButton.setButtonType(NSButton.ButtonType.momentaryChange)
        
        backButton.isBordered = false
        todayButton.isBordered = false
        forwardButton.isBordered = false
        
        backButton.target = self;
        todayButton.target = self;
        forwardButton.target = self;
        
        backButton.action = #selector(CalendarView.monthBackAction(_:))
        todayButton.action = #selector(CalendarView.todayAction(_:))
        forwardButton.action = #selector(CalendarView.monthForwardAction(_:))
        
        let height = CalendarView.lineHeightForFont(buttonFont)
        
        let startY = NSMaxY(frame) - height - 3
        
        backButton.frame = NSRect(x: 150 - 3*height - 4, y: startY, width: height, height: height)
        todayButton.frame = NSRect(x: (150 - 2*height - 1) - 1, y: startY, width: height, height: height)
        forwardButton.frame = NSRect(x: 150 - height, y: startY - 0.5, width: height, height: height)
        
        self.addSubview(backButton)
        self.addSubview(todayButton)
        self.addSubview(forwardButton)
    }
    
    fileprivate func updateButtonColor(_ title: NSAttributedString, color: NSColor) -> NSMutableAttributedString {
        let oneCharRange = NSRange(location: 0, length: 1)
        
        let mutableTitle = NSMutableAttributedString(attributedString: title)
        mutableTitle.removeAttribute(NSAttributedString.Key.foregroundColor, range: oneCharRange)
        mutableTitle.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: oneCharRange)
        
        return mutableTitle
    }
    
    @objc fileprivate func updateButtons() {
        let primaryColor = getPrimaryColor()
        let selectedColor = getSelectedColor()
        let grayColor = getGrayColor()
        
        let enableButton = (calendar as NSCalendar).compare(dateValue, to: Date(), toUnitGranularity: NSCalendar.Unit.month) != ComparisonResult.orderedSame
        
        backButton.attributedTitle = updateButtonColor(backButton.attributedTitle, color: primaryColor)
        todayButton.attributedTitle = updateButtonColor(todayButton.attributedTitle, color: enableButton ? primaryColor : grayColor)
        forwardButton.attributedTitle = updateButtonColor(forwardButton.attributedTitle, color: primaryColor)
        
        backButton.attributedAlternateTitle = updateButtonColor(backButton.attributedAlternateTitle, color: selectedColor)
        todayButton.attributedAlternateTitle = updateButtonColor(todayButton.attributedAlternateTitle, color: enableButton ? selectedColor : grayColor)
        forwardButton.attributedAlternateTitle = updateButtonColor(forwardButton.attributedAlternateTitle, color: selectedColor)
    }
    
    fileprivate func oneMonthLaterDayForDay(_ dateComponents: DateComponents) -> Date {
        var newDateComponents = DateComponents()
        newDateComponents.day = dateComponents.day
        newDateComponents.month = dateComponents.month! + 1
        newDateComponents.year = dateComponents.year
        return self.calendar.date(from: newDateComponents)!
    }
    
    fileprivate func oneMonthEarlierDayForDay(_ dateComponents: DateComponents) -> Date {
        var newDateComponents = DateComponents()
        newDateComponents.day = dateComponents.day
        newDateComponents.month = dateComponents.month! - 1
        newDateComponents.year = dateComponents.year
        return self.calendar.date(from: newDateComponents)!
    }
    
    @objc func monthBackAction(_ sender: NSButton) {
        dateValue = oneMonthEarlierDayForDay((self.calendar as NSCalendar).components(self.dateUnitMask, from: dateValue))
        updateMonth()
        updateMonthLabel()
        updateButtons()
    }
    
    @objc func monthForwardAction(_ sender: NSButton) {
        dateValue = oneMonthLaterDayForDay((self.calendar as NSCalendar).components(self.dateUnitMask, from: dateValue))
        updateMonth()
        updateMonthLabel()
        updateButtons()
    }
    
    @objc func todayAction(_ sender: NSButton) {
        dateValue = Date()
        updateMonth()
        updateMonthLabel()
        updateButtons()
    }
    
    fileprivate func getPrimaryColor() -> NSColor {
        let appearance = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light"
        if appearance == "Light" {
            return NSColor.black
        }
        else {
            return NSColor.init(white: 1.0, alpha: 1.0)
        }
    }
    
    fileprivate func getSelectedColor() -> NSColor {
        let appearance = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light"
        if appearance == "Light" {
            return NSColor.alternateSelectedControlColor
        }
        else {
            return NSColor.selectedControlColor
        }
    }
    
    fileprivate func getGrayColor() -> NSColor {
        let appearance = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light"
        if appearance == "Light" {
            return NSColor.gray
        }
        else {
            return NSColor.lightGray
        }
    }
    
    fileprivate func firstDayOfMonthForDate(_ date: Date) -> DateComponents {
        var dateComponents = (self.calendar as NSCalendar).components(self.dateUnitMask, from: date)
        let weekday = dateComponents.weekday
        let day = dateComponents.day
        let weekOffset = day! % 7
        
        dateComponents.day = 1
        dateComponents.weekday = weekday! - weekOffset + 1
        if dateComponents.weekday! <= 0 {
            dateComponents.weekday! += 7
        }
        
        return dateComponents
    }
    
    fileprivate func daysCountInMonthForDay(_ dateComponents: DateComponents) -> Int {
        let date = self.calendar.date(from: dateComponents)!
        let days = (self.calendar as NSCalendar).range(of: NSCalendar.Unit.day, in: NSCalendar.Unit.month, for: date)
        return days.length
    }
    
    fileprivate func makeDay(_ day: String, color: NSColor, font: NSFont) -> NSTextField {
        let view = NSTextField(frame: NSZeroRect)
        view.textColor = color
        view.font = font
        view.isEditable = false
        view.drawsBackground = false
        view.alignment = NSTextAlignment.right
        view.stringValue = day
        view.isBordered = false
        
        return view
    }
    
    fileprivate func makeDays() {
        var curX = CGFloat(0), curY = NSMaxY(frame) - 60
        let width = floor(self.frame.width / 7), height = CalendarView.lineHeightForFont(font)
        for _ in 0..<42 {
            let day = makeDay("T", color: NSColor.black, font: font)
            day.frame = NSRect(x: curX, y: curY, width: width, height: height)
            curX += width
            if curX + width >= self.frame.width {
                curX = 0
                curY -= (height + 5)
            }
            
            self.addSubview(day)
            days.append(day)
        }
    }
    
    @objc func darkModeChanged() {
        updateAppearance()
    }
    
    @objc func calendarUpdated() {
        updateAppearance()
    }
    
    func menuWillOpen() {
        dateValue = Date()
        updateAppearance()
    }
    
    fileprivate func updateMonth() {
        let firstOfMonth = firstDayOfMonthForDate(dateValue)
        
        var lastMonth = firstDayOfMonthForDate(dateValue)
        let dateComponents = (calendar as NSCalendar).components(dateUnitMask, from: dateValue)
        let currentDate = Date()
        let currentComponents = (calendar as NSCalendar).components(dateUnitMask, from: currentDate)
        
        let grayColor = getGrayColor()
        let selectedColor = getSelectedColor()
        let primaryColor = getPrimaryColor()
        
        lastMonth.month! -= 1
        if lastMonth.month == 0 {
            lastMonth.month = 12
        }
        
        var curDayIdx = 0
        
        var curDay : Int = daysCountInMonthForDay(lastMonth)
        for i in 2..<firstOfMonth.weekday!+1 {
            let day = days[firstOfMonth.weekday! - i]
            day.stringValue = String(curDay)
            day.textColor = grayColor
            day.font = font
            
            if (dateComponents.year! == currentComponents.year &&
                dateComponents.month == currentComponents.month! + 1 &&
                curDay == currentComponents.day!) {
                day.font = weekFont
                day.textColor = selectedColor
            }
            
            curDay -= 1
        }
        curDay = 1
        curDayIdx = firstOfMonth.weekday! - 2
        for _ in 0..<daysCountInMonthForDay(firstOfMonth) {
            let day = days[curDay + curDayIdx]
            day.stringValue = String(curDay)
            day.textColor = primaryColor
            day.font = font
            
            if (dateComponents.year == currentComponents.year &&
                dateComponents.month == currentComponents.month &&
                curDay == currentComponents.day) {
                day.font = weekFont
                day.textColor = selectedColor
            }
            
            curDay += 1
        }
        curDayIdx += (curDay - 1)
        curDay = 1
        for i in (firstOfMonth.weekday! + daysCountInMonthForDay(firstOfMonth))..<43 {
            let day = days[i - 1]
            day.stringValue = String(curDay)
            day.textColor = grayColor
            day.font = font
            
            if (dateComponents.year! == currentComponents.year &&
                dateComponents.month == currentComponents.month! - 1 &&
                curDay == currentComponents.day!) {
                day.font = weekFont
                day.textColor = selectedColor
            }
            
            curDay += 1
        }
    }
    
    fileprivate func makeWeekdays() {
        let color = getPrimaryColor()
        let lineHeight = CalendarView.lineHeightForFont(weekFont), width = floor(self.frame.width / 7)
        var curX = CGFloat(0)
        let curY = NSMaxY(frame) - 40
        for i in 0..<7 {
            let label = makeDay(calendar.veryShortWeekdaySymbols[i], color: color, font: weekFont)
            label.frame = NSRect(x: curX, y: curY, width: width, height: lineHeight)
            
            curX += width
            weekdayLabels.append(label)
            addSubview(label)
        }
    }
    
    fileprivate func updateWeekdays() {
        let primaryColor = getPrimaryColor()
        for weekdayLabel in weekdayLabels {
            weekdayLabel.textColor = primaryColor
            weekdayLabel.font = weekFont
        }
    }
    
    fileprivate func updateAppearance() {
        updateMonthLabel()
        updateButtons()
        updateMonth()
        updateWeekdays()
    }
    
}

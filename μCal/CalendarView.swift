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
        font = NSFont.systemFontOfSize(9.0)
        weekFont = NSFont.boldSystemFontOfSize(9.0)
        monthFont = NSFont.boldSystemFontOfSize(NSFont.systemFontSize())
        yearFont = NSFont.systemFontOfSize(NSFont.systemFontSize())
        
        super.init(coder: coder)
        makeWeekdays()
        makeDays()
        makeButtons()
        makeMonthLabel()

        updateAppearance()
        NSDistributedNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CalendarView.darkModeChanged), name: "AppleInterfaceThemeChangedNotification", object: nil)
        NSDistributedNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CalendarView.calendarUpdated), name: "NSCurrentLocaleDidChangeNotification", object: nil)
    }
    
    override init(frame frameRect: NSRect) {
        font = NSFont.systemFontOfSize(9.0)
        weekFont = NSFont.boldSystemFontOfSize(9.0)
        monthFont = NSFont.boldSystemFontOfSize(NSFont.systemFontSize())
        yearFont = NSFont.systemFontOfSize(NSFont.systemFontSize())
    
        super.init(frame: frameRect)
        makeWeekdays()
        makeDays()
        makeButtons()
        makeMonthLabel()

        updateAppearance()
        NSDistributedNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CalendarView.darkModeChanged), name: "AppleInterfaceThemeChangedNotification", object: nil)
        NSDistributedNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CalendarView.calendarUpdated), name: "NSCurrentLocaleDidChangeNotification", object: nil)
    }
    
    var dateValue = NSDate()
    
    private var font: NSFont
    private var weekFont: NSFont
    private var monthFont: NSFont
    private var yearFont: NSFont
    
    private var monthLabel = NSTextField(frame: NSZeroRect)
    private var weekdayLabels: [NSTextField] = []
    private var days: [NSTextField] = []
    
    private var backButton = NSButton(frame: NSZeroRect)
    private var todayButton = NSButton(frame: NSZeroRect)
    private var forwardButton = NSButton(frame: NSZeroRect)
    private let buttonFont = NSFont.boldSystemFontOfSize(NSFont.smallSystemFontSize())
    
    private let dateFormatter = NSDateFormatter()
    private let calendar = NSCalendar.autoupdatingCurrentCalendar()
    private let dateUnitMask: NSCalendarUnit =  [NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Weekday]
    private let dateTimeUnitMask: NSCalendarUnit =  [NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second, NSCalendarUnit.Weekday]
    
    class func lineHeightForFont(font: NSFont) -> CGFloat {
        let attribs = NSDictionary(object: font, forKey: NSFontAttributeName)
        let size = "Aa".sizeWithAttributes(attribs as? [String : AnyObject])
        return round(size.height)
    }
    
    private func getTitleString(month: String, year: String) -> NSAttributedString {
        let titleString = NSMutableAttributedString.init(string: month + " " + year)
        let monthAttribute = [NSFontAttributeName: monthFont]
        let yearAttribute = [NSFontAttributeName: yearFont]
        
        titleString.addAttributes(monthAttribute, range: (titleString.string as NSString).rangeOfString(month))
        titleString.addAttributes(yearAttribute, range: (titleString.string as NSString).rangeOfString(year))

        return titleString
    }
    
    private func makeMonthLabel() {
        monthLabel.editable = false
        monthLabel.bordered = false
        monthLabel.backgroundColor = NSColor.clearColor()
        
        let month = "ph"
        let year = "year"
        monthLabel.attributedStringValue = getTitleString(month, year: year)
        let height = monthLabel.attributedStringValue.size().height
        monthLabel.frame = NSRect(x: 5, y: NSMaxY(frame) - height - 1, width: 100, height: height)
        addSubview(monthLabel)
    }
    
    private func updateMonthLabel() {
        let month = self.calendar.shortMonthSymbols[self.calendar.component(NSCalendarUnit.Month, fromDate: dateValue) - 1]
        let year = String(self.calendar.component(NSCalendarUnit.Year, fromDate: dateValue))
        monthLabel.textColor = getPrimaryColor()
        monthLabel.attributedStringValue = getTitleString(month, year: year)
    }
    
    private func makeButtons() {
        let attrs = [NSForegroundColorAttributeName: getPrimaryColor(), NSFontAttributeName: buttonFont]
        
        let backString = NSMutableAttributedString(string: "◀", attributes: attrs)
        let todayString = NSMutableAttributedString(string: "●", attributes: [
            NSForegroundColorAttributeName: getPrimaryColor(),
            NSFontAttributeName: NSFont.boldSystemFontOfSize(18.0)
            ])
        let forwardString = NSMutableAttributedString(string: "▶", attributes: attrs)
        
        backButton.attributedTitle = backString
        todayButton.attributedTitle = todayString
        forwardButton.attributedTitle = forwardString
        
        let alternateAttrs = [NSForegroundColorAttributeName: getSelectedColor(), NSFontAttributeName: buttonFont]
        
        let backAltString = NSMutableAttributedString(string: "◀", attributes: alternateAttrs)
        let todayAltString = NSMutableAttributedString(string: "●", attributes: [
            NSForegroundColorAttributeName: getSelectedColor(),
            NSFontAttributeName: NSFont.boldSystemFontOfSize(18.0)
            ])
        let forwardAltString = NSMutableAttributedString(string: "▶", attributes: alternateAttrs)
        
        backButton.attributedAlternateTitle = backAltString
        todayButton.attributedAlternateTitle = todayAltString
        forwardButton.attributedAlternateTitle = forwardAltString
        
        backButton.alignment = NSTextAlignment.Center
        todayButton.alignment = NSTextAlignment.Center
        forwardButton.alignment = NSTextAlignment.Center
        
        backButton.setButtonType(NSButtonType.MomentaryChangeButton)
        todayButton.setButtonType(NSButtonType.MomentaryChangeButton)
        forwardButton.setButtonType(NSButtonType.MomentaryChangeButton)
        
        todayButton.enabled = calendar.compareDate(dateValue, toDate: NSDate(), toUnitGranularity: NSCalendarUnit.Month) != NSComparisonResult.OrderedSame
        
        backButton.bordered = false
        todayButton.bordered = false
        forwardButton.bordered = false
        
        backButton.target = self;
        todayButton.target = self;
        forwardButton.target = self;
        
        backButton.action = #selector(CalendarView.monthBackAction(_:))
        todayButton.action = #selector(CalendarView.todayAction(_:))
        forwardButton.action = #selector(CalendarView.monthForwardAction(_:))
        
        let height = CalendarView.lineHeightForFont(buttonFont)
        
        let startY = NSMaxY(frame) - height - 3
        
        backButton.frame = NSRect(x: 140 - 3*height - 4, y: startY, width: height, height: height)
        todayButton.frame = NSRect(x: (140 - 2*height - 1) - 2, y: startY + 1, width: height, height: height)
        forwardButton.frame = NSRect(x: 140 - height, y: startY - 0.5, width: height, height: height)
        
        self.addSubview(backButton)
        self.addSubview(todayButton)
        self.addSubview(forwardButton)
    }
    
    private func updateButtonColor(title: NSAttributedString, color: NSColor) -> NSMutableAttributedString {
        let oneCharRange = NSRange(location: 0, length: 1)
        
        let mutableTitle = NSMutableAttributedString(attributedString: title)
        mutableTitle.removeAttribute(NSForegroundColorAttributeName, range: oneCharRange)
        mutableTitle.addAttribute(NSForegroundColorAttributeName, value: color, range: oneCharRange)
        
        return mutableTitle
    }
    
    @objc private func updateButtons() {
        let primaryColor = getPrimaryColor()
        let selectedColor = getSelectedColor()
        
        backButton.attributedTitle = updateButtonColor(backButton.attributedTitle, color: primaryColor)
        todayButton.attributedTitle = updateButtonColor(todayButton.attributedTitle, color: primaryColor)
        forwardButton.attributedTitle = updateButtonColor(forwardButton.attributedTitle, color: primaryColor)
        
        backButton.attributedAlternateTitle = updateButtonColor(backButton.attributedAlternateTitle, color: selectedColor)
        todayButton.attributedAlternateTitle = updateButtonColor(todayButton.attributedAlternateTitle, color: selectedColor)
        forwardButton.attributedAlternateTitle = updateButtonColor(forwardButton.attributedAlternateTitle, color: selectedColor)
        
        todayButton.enabled = calendar.compareDate(dateValue, toDate: NSDate(), toUnitGranularity: NSCalendarUnit.Month) != NSComparisonResult.OrderedSame
    }
    
    private func oneMonthLaterDayForDay(dateComponents: NSDateComponents) -> NSDate {
        let newDateComponents = NSDateComponents()
        newDateComponents.day = dateComponents.day
        newDateComponents.month = dateComponents.month + 1
        newDateComponents.year = dateComponents.year
        return self.calendar.dateFromComponents(newDateComponents)!
    }
    
    private func oneMonthEarlierDayForDay(dateComponents: NSDateComponents) -> NSDate {
        let newDateComponents = NSDateComponents()
        newDateComponents.day = dateComponents.day
        newDateComponents.month = dateComponents.month - 1
        newDateComponents.year = dateComponents.year
        return self.calendar.dateFromComponents(newDateComponents)!
    }
    
    func monthBackAction(sender: NSButton) {
        dateValue = oneMonthEarlierDayForDay(self.calendar.components(self.dateUnitMask, fromDate: dateValue))
        updateMonth()
        updateMonthLabel()
        updateButtons()
    }
    
    func monthForwardAction(sender: NSButton) {
        dateValue = oneMonthLaterDayForDay(self.calendar.components(self.dateUnitMask, fromDate: dateValue))
        updateMonth()
        updateMonthLabel()
        updateButtons()
    }
    
    func todayAction(sender: NSButton) {
        dateValue = NSDate()
        updateMonth()
        updateMonthLabel()
        updateButtons()
    }
    
    private func getPrimaryColor() -> NSColor {
        let appearance = NSUserDefaults.standardUserDefaults().stringForKey("AppleInterfaceStyle") ?? "Light"
        if appearance == "Light" {
            return NSColor.blackColor()
        }
        else {
            return NSColor.init(white: 1.0, alpha: 1.0)
        }
    }
    
    private func getSelectedColor() -> NSColor {
        let appearance = NSUserDefaults.standardUserDefaults().stringForKey("AppleInterfaceStyle") ?? "Light"
        if appearance == "Light" {
            return NSColor.alternateSelectedControlColor()
        }
        else {
            return NSColor.selectedControlColor()
        }
    }
    
    private func getGrayColor() -> NSColor {
        let appearance = NSUserDefaults.standardUserDefaults().stringForKey("AppleInterfaceStyle") ?? "Light"
        if appearance == "Light" {
            return NSColor.grayColor()
        }
        else {
            return NSColor.lightGrayColor()
        }
    }
    
    private func firstDayOfMonthForDate(date: NSDate) -> NSDateComponents {
        let dateComponents = self.calendar.components(self.dateUnitMask, fromDate: date)
        let weekday = dateComponents.weekday
        let day = dateComponents.day
        let weekOffset = day % 7
        
        dateComponents.day = 1
        dateComponents.weekday = weekday - weekOffset + 1
        if dateComponents.weekday <= 0 {
            dateComponents.weekday += 7
        }
        
        return dateComponents
    }
    
    private func daysCountInMonthForDay(dateComponents: NSDateComponents) -> Int {
        let date = self.calendar.dateFromComponents(dateComponents)!
        let days = self.calendar.rangeOfUnit(NSCalendarUnit.Day, inUnit: NSCalendarUnit.Month, forDate: date)
        return days.length
    }
    
    private func makeDay(day: String, color: NSColor, font: NSFont) -> NSTextField {
        let view = NSTextField(frame: NSZeroRect)
        view.textColor = color
        view.font = font
        view.editable = false
        view.drawsBackground = false
        view.alignment = NSTextAlignment.Right
        view.stringValue = day
        view.bordered = false
        
        return view
    }
    
    private func makeDays() {
        var curX = CGFloat(0), curY = NSMaxY(frame) - 60
        let width = floor(self.frame.width / 7), height = CalendarView.lineHeightForFont(font)
        for _ in 0..<42 {
            let day = makeDay("T", color: NSColor.blackColor(), font: font)
            day.frame = NSRect(x: curX, y: curY, width: width, height: height)
            curX += width
            if curX >= self.frame.width {
                curX = 0
                curY -= (height + 5)
            }
            
            self.addSubview(day)
            days.append(day)
        }
    }
    
    func getDayViewsForDate(date: NSDate) -> [NSTextField] {
        var dayViews: [NSTextField] = []
        let firstOfMonth = firstDayOfMonthForDate(date)
        
        let lastMonth = firstDayOfMonthForDate(date)
        let dateComponents = calendar.components(dateUnitMask, fromDate: dateValue)
        let currentDate = NSDate()
        let currentComponents = calendar.components(dateUnitMask, fromDate: currentDate)
        
        lastMonth.month -= 1
        if lastMonth.month == 0 {
            lastMonth.month = 12
        }
        
        var curDay : Int = daysCountInMonthForDay(lastMonth)
        for _ in 1..<firstOfMonth.weekday {
            let view = makeDay(String(curDay), color: getGrayColor(), font: font)
            
            if (dateComponents.year == currentComponents.year &&
                dateComponents.month == currentComponents.month + 1 &&
                curDay == currentComponents.day) {
                view.font = weekFont
                view.textColor = getSelectedColor()
            }
            
            curDay -= 1
            dayViews.insert(view, atIndex: 0)
        }
        curDay = 1
        for _ in 0..<daysCountInMonthForDay(firstOfMonth) {
            let view = makeDay(String(curDay), color: getPrimaryColor(), font: font)
            
            if (dateComponents.year == currentComponents.year &&
                dateComponents.month == currentComponents.month &&
                curDay == currentComponents.day) {
                view.font = weekFont
                view.textColor = getSelectedColor()
            }
            
            curDay += 1
            dayViews.append(view)
        }
        curDay = 1
        for _ in (firstOfMonth.weekday + daysCountInMonthForDay(firstOfMonth))..<43 {
            let view = makeDay(String(curDay), color: getGrayColor(), font: font)
            
            if (dateComponents.year == currentComponents.year &&
                dateComponents.month == currentComponents.month - 1 &&
                curDay == currentComponents.day) {
                view.font = weekFont
                view.textColor = getSelectedColor()
            }
            
            curDay += 1
            dayViews.append(view)
        }
        
        return dayViews
    }
    
    func darkModeChanged() {
        updateAppearance()
    }
    
    func calendarUpdated() {
        updateAppearance()
    }
    
    func menuWillOpen() {
        dateValue = NSDate()
        updateAppearance()
    }
    
    private func updateMonth() {
        let firstOfMonth = firstDayOfMonthForDate(dateValue)
        
        let lastMonth = firstDayOfMonthForDate(dateValue)
        let dateComponents = calendar.components(dateUnitMask, fromDate: dateValue)
        let currentDate = NSDate()
        let currentComponents = calendar.components(dateUnitMask, fromDate: currentDate)
        
        let grayColor = getGrayColor()
        let selectedColor = getSelectedColor()
        let primaryColor = getPrimaryColor()
        
        lastMonth.month -= 1
        if lastMonth.month == 0 {
            lastMonth.month = 12
        }
        
        var curDayIdx = 0
        
        var curDay : Int = daysCountInMonthForDay(lastMonth)
        for i in 2..<firstOfMonth.weekday+1 {
            let day = days[firstOfMonth.weekday - i]
            day.stringValue = String(curDay)
            day.textColor = grayColor
            day.font = font
            
            if (dateComponents.year == currentComponents.year &&
                dateComponents.month == currentComponents.month + 1 &&
                curDay == currentComponents.day) {
                day.font = weekFont
                day.textColor = selectedColor
            }
            
            curDay -= 1
        }
        curDay = 1
        curDayIdx = firstOfMonth.weekday - 2
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
        for i in (firstOfMonth.weekday + daysCountInMonthForDay(firstOfMonth))..<43 {
            let day = days[i - 1]
            day.stringValue = String(curDay)
            day.textColor = grayColor
            day.font = font
            
            if (dateComponents.year == currentComponents.year &&
                dateComponents.month == currentComponents.month - 1 &&
                curDay == currentComponents.day) {
                day.font = weekFont
                day.textColor = selectedColor
            }
            
            curDay += 1
        }
    }
    
    private func makeWeekdays() {
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
    
    private func updateWeekdays() {
        let primaryColor = getPrimaryColor()
        for weekdayLabel in weekdayLabels {
            weekdayLabel.textColor = primaryColor
            weekdayLabel.font = weekFont
        }
    }
    
    private func updateAppearance() {
        updateMonthLabel()
        updateButtons()
        updateMonth()
        updateWeekdays()
    }
    
}

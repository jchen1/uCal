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
        updateAppearance()
        NSDistributedNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CalendarView.darkModeChanged), name: "AppleInterfaceThemeChangedNotification", object: nil)
        NSDistributedNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CalendarView.calendarUpdated), name: "NSCurrentLocaleDidChangeNotification", object: nil)
    }

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
    var dateValue = NSDate()
    var font: NSFont {
        didSet {
            updateAppearance()
        }
    }
    var weekFont: NSFont {
        didSet {
            updateAppearance()
        }
    }
    var monthFont: NSFont {
        didSet {
            updateAppearance()
        }
    }
    var yearFont: NSFont {
        didSet {
            updateAppearance()
        }
    }
    
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
    
    private func updateMonthLabel() {
        let month = self.calendar.shortMonthSymbols[self.calendar.component(NSCalendarUnit.Month, fromDate: dateValue) - 1]
        let year = String(self.calendar.component(NSCalendarUnit.Year, fromDate: dateValue))
        monthLabel.attributedStringValue = getTitleString(month, year: year)
        monthLabel.editable = false
        monthLabel.bordered = false
        monthLabel.backgroundColor = NSColor.clearColor()
        monthLabel.textColor = getPrimaryColor()
        let height = monthLabel.attributedStringValue.size().height
        monthLabel.frame = NSRect(x: 5, y: NSMaxY(frame) - height - 1, width: 100, height: height)
        self.addSubview(monthLabel)
    }
    
    @objc private func updateButtons() {
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
        updateAppearance()
    }
    
    func monthForwardAction(sender: NSButton) {
        dateValue = oneMonthLaterDayForDay(self.calendar.components(self.dateUnitMask, fromDate: dateValue))
        updateAppearance()
    }
    
    func todayAction(sender: NSButton) {
        dateValue = NSDate()
        updateAppearance()
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
    
    func getDayViewsForDate(date: NSDate) -> [NSTextField] {
        // find current
        var dayViews: [NSTextField] = []
        let firstOfMonth = firstDayOfMonthForDate(date)
        
        let lastMonth = firstDayOfMonthForDate(date)
        lastMonth.month -= 1
        if lastMonth.month == 0 {
            lastMonth.month = 12
        }
        
        var curDay = daysCountInMonthForDay(lastMonth)
        for _ in 1..<firstOfMonth.weekday {
            let view = NSTextField(frame: NSZeroRect)
            
            view.textColor = NSColor.lightGrayColor()
            view.font = font
            view.editable = false
            view.backgroundColor = NSColor.clearColor()
            view.bordered = false
            view.alignment = NSTextAlignment.Right
            view.shadow = nil
            view.stringValue = String(curDay)
            
            curDay -= 1
            dayViews.insert(view, atIndex: 0)
        }
        curDay = 1
        for _ in 0..<daysCountInMonthForDay(firstOfMonth) {
            let view = NSTextField(frame: NSZeroRect)
            view.textColor = getPrimaryColor()
            view.font = font
            view.editable = false
            view.backgroundColor = NSColor.clearColor()
            view.bordered = false
            view.alignment = NSTextAlignment.Right
            view.shadow = nil
            view.stringValue = String(curDay)
            
            if (self.calendar.component(NSCalendarUnit.Month, fromDate: date) == self.calendar.component(NSCalendarUnit.Month, fromDate: NSDate()) &&
                self.calendar.component(NSCalendarUnit.Year, fromDate: date) ==
                self.calendar.component(NSCalendarUnit.Year, fromDate: NSDate()) && curDay == self.calendar.component(NSCalendarUnit.Day, fromDate: NSDate())) {
                view.font = weekFont
                view.textColor = getSelectedColor()
            }
            
            curDay += 1
            dayViews.append(view)
        }
        curDay = 1
        for _ in (firstOfMonth.weekday + daysCountInMonthForDay(firstOfMonth))..<43 {
            let view = NSTextField(frame: NSZeroRect)
            
            view.textColor = NSColor.lightGrayColor()
            view.font = font
            view.editable = false
            view.backgroundColor = NSColor.clearColor()
            view.bordered = false
            view.alignment = NSTextAlignment.Right
            view.shadow = nil
            view.stringValue = String(curDay)
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
    
    func menuWillClose() {
        dateValue = NSDate()
        updateAppearance()
    }
    
    private func updateAppearance() {
        updateMonthLabel()
        updateButtons()
        
        for weekdayLabel in weekdayLabels {
            weekdayLabel.removeFromSuperview()
        }
        weekdayLabels.removeAll(keepCapacity: true)
        
        var curX = 0
        for i in 0..<7 {
            let label = NSTextField(frame: NSZeroRect)
            label.font = weekFont
            label.textColor = getPrimaryColor()
            label.editable = false
            label.backgroundColor = NSColor.clearColor()
            label.bordered = false
            label.alignment = NSTextAlignment.Right
            label.stringValue = calendar.veryShortWeekdaySymbols[i]
            
            label.frame = NSRect(x: CGFloat(curX), y: NSMaxY(frame) - 40, width: floor(self.frame.width / 7), height: CalendarView.lineHeightForFont(weekFont))
            
            curX += Int(floor(self.frame.width / 7))
            
            weekdayLabels.append(label)
            self.addSubview(label)
        }
        
        curX = 0
        var curY = NSMaxY(frame) - 60
        for view in days {
            view.removeFromSuperview()
        }
        days.removeAll()
        days = getDayViewsForDate(dateValue)
        for view in days {
            view.frame = NSRect(x: CGFloat(curX), y: curY, width: floor(self.frame.width / 7), height: CalendarView.lineHeightForFont(font))
            
            curX += Int(floor(self.frame.width / 7))
            if curX >= Int(self.frame.width) {
                curX = 0
                curY -= (CalendarView.lineHeightForFont(font) + 5)
            }
            
            self.addSubview(view)
        }
    }
    
}

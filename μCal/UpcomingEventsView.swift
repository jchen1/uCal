//
//  UpcomingEventsView.swift
//  μCal
//
//  Created by Jeff Chen on 6/28/16.
//  Copyright © 2016 Jeff Chen. All rights reserved.
//

import Cocoa
import EventKit

class UpcomingEventsView: NSView {
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        let authorizationStatus = EKEventStore.authorizationStatusForEntityType(EKEntityType.Event)
        if authorizationStatus == EKAuthorizationStatus.Authorized {
            clear()
            getEvents()
        }
        else {
            //error
        }
    }
    
    override func mouseUp(theEvent: NSEvent) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "ical://")!)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func clear() {
        for subview in subviews {
            subview.removeFromSuperview()
        }
    }
    
    func getEvents() {
        let components = calendar.components(timeMask, fromDate: NSDate())
        let nextWeek = oneWeekLaterDayForDay(components)
        
        let pred = eventStore.predicateForEventsWithStartDate(calendar.dateFromComponents(components)!, endDate: nextWeek, calendars: nil)
        
        events = eventStore.eventsMatchingPredicate(pred)
        drawEvents()
    }
    
    private func getSeparator(date: NSDate) -> NSView {
        let separator = NSTextField(frame: NSRect(x: 0, y: 0, width: NSMaxX(bounds), height: 17))
        separator.bordered = false
        separator.drawsBackground = false
        separator.editable = false
        var firstPart = ""
        
        if calendar.isDateInToday(date) {
            firstPart = "Today"
        }
        else if calendar.isDateInTomorrow(date) {
            firstPart = "Tomorrow"
        }
        else {
            firstPart = calendar.weekdaySymbols[calendar.components(dateUnitMask, fromDate: date).weekday - 1]
        }
        
        firstPart += " • "
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "M-dd-yy"
        let secondPart = dateFormatter.stringFromDate(date)
        
        let separatorString = NSMutableAttributedString(string: firstPart + secondPart)
        let bFont = NSFont.boldSystemFontOfSize(NSFont.smallSystemFontSize() - 2)
        let font = NSFont.systemFontOfSize(NSFont.smallSystemFontSize() - 2)
        separatorString.addAttributes([NSFontAttributeName: bFont], range: (separatorString.string as NSString).rangeOfString(firstPart))
        separatorString.addAttributes([NSFontAttributeName: font], range: (separatorString.string as NSString).rangeOfString(secondPart))
        
        separator.attributedStringValue = separatorString
        return separator
    }
    
    private func drawEvents() {
        var curY = NSMaxY(bounds)
        events = Array((NSArray(array: events).sortedArrayUsingSelector(#selector(EKEvent.compareStartDateWithEvent)) as! [EKEvent]).prefix(Int(maxEventsToDisplay)))
        
        if events.count > 0 {
            var curDay = events[0].startDate
            var sep = getSeparator(events[0].startDate)
            sep.setFrameOrigin(NSPoint(x: 5, y: curY - 19))
            curY -= 17
            addSubview(sep)
            for event in events {
                if !calendar.isDate(curDay, inSameDayAsDate: event.startDate) {
                    sep = getSeparator(event.startDate)
                    sep.setFrameOrigin(NSPoint(x: 5, y: curY - 19))
                    curY -= 17
                    addSubview(sep)
                    curDay = event.startDate
                }
                let height = EventView.getRequiredHeight(event)
                let evt = EventView(frame: NSRect(x: 0, y: curY - height, width: NSMaxX(bounds) - 5, height: height), event: event)
                
                curY -= height
                addSubview(evt)
            }
        }
        desiredHeight = NSMaxY(bounds) - curY
    }
    
    private func oneWeekLaterDayForDay(dateComponents: NSDateComponents) -> NSDate {
        let newDateComponents = NSDateComponents()
        newDateComponents.day = dateComponents.day + 7
        newDateComponents.month = dateComponents.month
        newDateComponents.year = dateComponents.year
        return self.calendar.dateFromComponents(newDateComponents)!
    }
    
    private var events: [EKEvent] = []
    private var eventViews: [EventView] = []
    private let eventStore = EKEventStore()
    private let calendar = NSCalendar.currentCalendar()
    
    private var maxEventsToDisplay: UInt = 3
    
    private(set) var desiredHeight: CGFloat = 0
    
    
    private let dateUnitMask: NSCalendarUnit = [NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Weekday]
    
    private let timeMask: NSCalendarUnit = [NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Weekday, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second]
    
}

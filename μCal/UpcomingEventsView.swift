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
    
    init(frame frameRect: NSRect, hideAllDayEvents: Bool) {
        super.init(frame: frameRect)
        let authorizationStatus = EKEventStore.authorizationStatus(for: EKEntityType.event)
        if authorizationStatus == EKAuthorizationStatus.authorized {
            clear()
            getEvents(hideAllDayEvents: hideAllDayEvents)
        }
        else {
            //error
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func clear() {
        for subview in subviews {
            subview.removeFromSuperview()
        }
    }
    
    func getEvents(hideAllDayEvents: Bool) {
        let components = (calendar as NSCalendar).components(timeMask, from: Date())
        let nextWeek = oneWeekLaterDayForDay(components)
        
        let pred = eventStore.predicateForEvents(withStart: calendar.date(from: components)!, end: nextWeek, calendars: nil)
        
        events = eventStore.events(matching: pred).filter({ !hideAllDayEvents || !$0.isAllDay })
        drawEvents()
    }
    
    fileprivate func getSeparator(_ date: Date) -> NSView {
        let separator = NSTextField(frame: NSRect(x: 0, y: 0, width: NSMaxX(bounds), height: 17))
        separator.isBordered = false
        separator.drawsBackground = false
        separator.isEditable = false
        var firstPart = " • "
        
        if calendar.isDateInToday(date) {
            firstPart = "Today" + firstPart
        }
        else if calendar.isDateInTomorrow(date) {
            firstPart = "Tomorrow" + firstPart
        }
        else {
            firstPart = calendar.weekdaySymbols[(calendar as NSCalendar).component(NSCalendar.Unit.weekday, from: date) - 1] + firstPart
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M-dd-yy"
        let secondPart = dateFormatter.string(from: date)
        
        let separatorString = NSMutableAttributedString(string: firstPart + secondPart)
        let bFont = NSFont.boldSystemFont(ofSize: NSFont.smallSystemFontSize() - 2)
        let font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize() - 2)

        separatorString.addAttributes([NSFontAttributeName: bFont], range: (separatorString.string as NSString).range(of: firstPart))
        separatorString.addAttributes([NSFontAttributeName: font], range: (separatorString.string as NSString).range(of: secondPart))

        separator.attributedStringValue = separatorString
        return separator
    }
    
    fileprivate func drawEvents() {
        var curY = NSMaxY(bounds)
        events = NSArray(array: events).sortedArray(using: #selector(EKEvent.compareStartDate(with:))) as! [EKEvent]
        
        if events.count > 0 {
            var curDay = events[0].startDate
            var sep = getSeparator(events[0].startDate)
            sep.setFrameOrigin(NSPoint(x: 5, y: curY - 19))
            curY -= 17
            addSubview(sep)
            for event in events {
                if !calendar.isDate(curDay, inSameDayAs: event.startDate) {
                    sep = getSeparator(event.startDate)
                    sep.setFrameOrigin(NSPoint(x: 5, y: curY - 19))
                    curY -= 17
                    addSubview(sep)
                    curDay = event.startDate
                }
                let height = EventView.getRequiredHeight(event)
                let evt = EventView(frame: NSRect(x: 0, y: curY - height, width: NSMaxX(bounds), height: height), event: event)
            
                if curY - height < 0 {
                    break
                }
                
                curY -= height
                addSubview(evt)
            }
        }
        desiredHeight = NSMaxY(bounds) - curY
    }
    
    fileprivate func oneWeekLaterDayForDay(_ dateComponents: DateComponents) -> Date {
        var newDateComponents = DateComponents()
        newDateComponents.day = dateComponents.day! + 7
        newDateComponents.month = dateComponents.month
        newDateComponents.year = dateComponents.year
        return self.calendar.date(from: newDateComponents)!
    }
    
    fileprivate var events: [EKEvent] = []
    fileprivate var eventViews: [EventView] = []
    fileprivate let eventStore = EKEventStore()
    fileprivate let calendar = Calendar.current
        
    fileprivate(set) var desiredHeight: CGFloat = 0
    
    fileprivate let dateUnitMask: NSCalendar.Unit = [NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day, NSCalendar.Unit.weekday]
    fileprivate let timeMask: NSCalendar.Unit = [NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day, NSCalendar.Unit.weekday, NSCalendar.Unit.hour, NSCalendar.Unit.minute, NSCalendar.Unit.second]
    
}

//
//  EventView.swift
//  μCal
//
//  Created by Jeff Chen on 6/28/16.
//  Copyright © 2016 Jeff Chen. All rights reserved.
//

import Cocoa
import EventKit

class EventView: NSView {
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func getRequiredHeight(_ event: EKEvent) -> CGFloat {
        var height = CalendarView.lineHeightForFont(NSFont.systemFont(ofSize: NSFont.smallSystemFontSize()))
        if (event.location) != nil {
            height += CalendarView.lineHeightForFont(NSFont.systemFont(ofSize: NSFont.smallSystemFontSize() - 1))
        }
        return height
    }
    
    init(frame frameRect: NSRect, event: EKEvent) {
        self.event = event
        super.init(frame: frameRect)
        
        let font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize(), weight: NSFontWeightLight)
        let bFont = NSFont.boldSystemFont(ofSize: NSFont.smallSystemFontSize())
        let lFont = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize() - 1)
        let bubbleFont = NSFont.boldSystemFont(ofSize: NSFont.systemFontSize())
        let height = CalendarView.lineHeightForFont(font)
        let smallHeight = CalendarView.lineHeightForFont(lFont)
        let bubbleHeight = CalendarView.lineHeightForFont(bubbleFont)
        
        titleField = NSTextField(frame: NSRect(x: height*3/2, y: NSMaxY(bounds) - height, width: NSMaxX(bounds) * 3/5 - height*3/2, height: height))
        bubbleField = NSTextField(frame: NSRect(x: 0, y: NSMaxY(bounds) - (bubbleHeight - 2), width: height*3/2, height: bubbleHeight))
        locationField = NSTextField(frame: NSRect(x: height*3/2, y: NSMaxY(bounds) - 2*height, width: NSMaxX(bounds) - height*3/2, height: smallHeight))
        timeField = NSTextField(frame: NSRect(x: NSMaxX(bounds) * 3/5, y: NSMaxY(bounds) - height, width: NSMaxX(bounds) * 2/5, height: smallHeight))
        
        titleField.cell!.lineBreakMode = NSLineBreakMode.byTruncatingTail
        locationField.cell!.lineBreakMode = NSLineBreakMode.byTruncatingTail
        
        self.height = height + 5
        
        bubbleField.textColor = event.calendar.color
        bubbleField.stringValue = "◉"
        bubbleField.isEditable = false
        bubbleField.isBordered = false
        bubbleField.drawsBackground = false
        bubbleField.alignment = NSTextAlignment.right
        bubbleField.font = bubbleFont
        
        titleField.textColor = NSColor.textColor
        titleField.stringValue = event.title
        titleField.isEditable = false
        titleField.isBordered = false
        titleField.drawsBackground = false
        titleField.alignment = NSTextAlignment.left
        titleField.font = bFont
        titleField.toolTip = event.title
        
        if let loc = event.location {
            locationField.textColor = NSColor.secondaryLabelColor
            locationField.stringValue = loc
            locationField.isEditable = false
            locationField.isBordered = false
            locationField.drawsBackground = false
            locationField.alignment = NSTextAlignment.left
            locationField.font = NSFontManager.shared().convert(lFont, toHaveTrait: NSFontTraitMask.italicFontMask)
            self.height += height
            locationField.toolTip = loc
            addSubview(locationField)
        }

        if !event.isAllDay {
            timeField.textColor = NSColor.secondaryLabelColor
            timeField.stringValue = getTime(event.startDate)
            timeField.isEditable = false
            timeField.isBordered = false
            timeField.drawsBackground = false
            timeField.alignment = NSTextAlignment.right
            timeField.font = lFont
            addSubview(timeField)
        }
        else {
            titleField.frame.size.width = NSMaxX(bounds) - height * 3/2
        }

        addSubview(titleField)
        addSubview(bubbleField)
    }
    
    fileprivate(set) var height: CGFloat = 0
    
    fileprivate func getTime(_ startDate: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mmaa"
        return dateFormatter.string(from: startDate)
    }
    
    fileprivate var bubbleField: NSTextField = NSTextField(frame: NSZeroRect)
    fileprivate var titleField: NSTextField = NSTextField(frame: NSZeroRect)
    fileprivate var locationField: NSTextField = NSTextField(frame: NSZeroRect)
    fileprivate var timeField: NSTextField = NSTextField(frame: NSZeroRect)
    fileprivate var event: EKEvent
}

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

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func getRequiredHeight(event: EKEvent) -> CGFloat {
        var height = CalendarView.lineHeightForFont(NSFont.systemFontOfSize(NSFont.smallSystemFontSize()))
        if (event.location) != nil {
            height += CalendarView.lineHeightForFont(NSFont.systemFontOfSize(NSFont.smallSystemFontSize() - 1))
        }
        return height
    }
    
    init(frame frameRect: NSRect, event: EKEvent) {
        self.event = event
        super.init(frame: frameRect)
        
        let font = NSFont.systemFontOfSize(NSFont.smallSystemFontSize(), weight: NSFontWeightLight)
        let bFont = NSFont.boldSystemFontOfSize(NSFont.smallSystemFontSize())
        let lFont = NSFont.systemFontOfSize(NSFont.smallSystemFontSize() - 1)
        let bubbleFont = NSFont.boldSystemFontOfSize(NSFont.systemFontSize())
        let height = CalendarView.lineHeightForFont(font)
        let bubbleHeight = CalendarView.lineHeightForFont(bubbleFont)
        
        titleField = NSTextField(frame: NSRect(x: height*3/2, y: NSMaxY(bounds) - height, width: NSMaxX(bounds) * 3/5 - height*3/2, height: height))
        bubbleField = NSTextField(frame: NSRect(x: 0, y: NSMaxY(bounds) - (bubbleHeight - 2), width: height*3/2, height: bubbleHeight))
        locationField = NSTextField(frame: NSRect(x: height*3/2, y: NSMaxY(bounds) - 2*height, width: NSMaxX(bounds) - height*3/2, height: CalendarView.lineHeightForFont(lFont)))
        timeField = NSTextField(frame: NSRect(x: NSMaxX(bounds) * 3/5, y: NSMaxY(bounds) - height, width: NSMaxX(bounds) * 2/5, height: height))
        
        titleField.cell!.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        locationField.cell!.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        
        self.height = height + 5
        
        bubbleField.textColor = event.calendar.color
        bubbleField.stringValue = "◉"
        bubbleField.editable = false
        bubbleField.bordered = false
        bubbleField.drawsBackground = false
        bubbleField.alignment = NSTextAlignment.Right
        bubbleField.font = bubbleFont
        
        titleField.textColor = NSColor.textColor()
        titleField.stringValue = event.title
        titleField.editable = false
        titleField.bordered = false
        titleField.drawsBackground = false
        titleField.alignment = NSTextAlignment.Left
        titleField.font = bFont
        titleField.toolTip = event.title
        
        if let loc = event.location {
            locationField.textColor = NSColor.secondaryLabelColor()
            locationField.stringValue = loc
            locationField.editable = false
            locationField.bordered = false
            locationField.drawsBackground = false
            locationField.alignment = NSTextAlignment.Left
            locationField.font = NSFontManager.sharedFontManager().convertFont(lFont, toHaveTrait: NSFontTraitMask.ItalicFontMask)
            self.height += height
            locationField.toolTip = loc
            addSubview(locationField)
        }

        if !event.allDay {
            timeField.textColor = NSColor.secondaryLabelColor()
            timeField.stringValue = getTime(event.startDate)
            timeField.editable = false
            timeField.bordered = false
            timeField.drawsBackground = false
            timeField.alignment = NSTextAlignment.Right
            timeField.font = font
            addSubview(timeField)
        }
        else {
            titleField.frame.size.width = NSMaxX(bounds) - height * 3/2
        }

        addSubview(titleField)
        addSubview(bubbleField)
    }
    
    private(set) var height: CGFloat = 0
    
    private func getTime(startDate: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "h:mmaa"
        return dateFormatter.stringFromDate(startDate)
    }
    
    private var bubbleField: NSTextField = NSTextField(frame: NSZeroRect)
    private var titleField: NSTextField = NSTextField(frame: NSZeroRect)
    private var locationField: NSTextField = NSTextField(frame: NSZeroRect)
    private var timeField: NSTextField = NSTextField(frame: NSZeroRect)
    private var event: EKEvent
}

//
//  CalendarDayView.swift
//  μCal
//
//  Created by Jeff Chen on 6/27/16.
//  Copyright © 2016 Jeff Chen. All rights reserved.
//

import Cocoa

class CalendarDayView: NSView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
//    init(dateComponents: NSDateComponents) {
//        self.dateComponents = dateComponents
//        self.font = NSFont.systemFontOfSize(12.0)
//        self.lineHeight = NMDatePicker.lineHeightForFont(self.font)
//        super.init(frame: NSZeroRect)
//        
//        
//        // Get day component
//        let day = self.dateComponents.day
//        
//        // Configure label
//        self.label = NSTextField(frame: NSZeroRect)
//        self.label.editable = false
//        self.label.backgroundColor = NSColor.clearColor()
//        self.label.bordered = false
//        self.label.alignment = NSTextAlignment.Center
//        self.label.textColor = NSColor.blackColor()
//        self.label.font = self.font
//        self.label.stringValue = "\(day)"
//        self.addSubview(self.label)
//        
//    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
    private let textField = NSTextField()
    
}

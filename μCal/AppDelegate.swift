//
//  AppDelegate.swift
//  μCal
//
//  Created by Jeff Chen on 6/25/16.
//  Copyright © 2016 Jeff Chen. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusBar = NSStatusBar.systemStatusBar();
    var statusItem: NSStatusItem?;
    var menu = NSMenu();
//    var menuItem = NSMenuItem();
    let datePicker = NSDatePicker();
    
    let dateFormatter = NSDateFormatter();
    var timer = NSTimer();

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        statusItem = statusBar.statusItemWithLength(NSVariableStatusItemLength);
        statusItem?.button?.image = NSImage(named: "switchIcon.png");
        statusItem?.button?.image?.template = true;
        statusItem?.button?.imagePosition = NSCellImagePosition.ImageLeft;
        
        dateFormatter.dateFormat = "EEE h:mm:ss aa";
        
        datePicker.calendar = NSCalendar.autoupdatingCurrentCalendar();
        datePicker.datePickerMode = NSDatePickerMode.SingleDateMode;
        datePicker.datePickerStyle = NSDatePickerStyle.ClockAndCalendarDatePickerStyle;
        datePicker.datePickerElements = NSDatePickerElementFlags.YearMonthDayDatePickerElementFlag;
        datePicker.bezeled = false;
        datePicker.dateValue = NSDate();
        
        updateTime();
        
        statusItem?.menu = menu;
        
        let menuItem: NSMenuItem! = menu.addItemWithTitle("item", action: nil, keyEquivalent: "");
        print(datePicker.frame.size.width, datePicker.frame.size.height);
        
        menuItem.view = datePicker;
        var f = datePicker.frame;
        f.size.width = 140;
        f.size.height = 150;
        datePicker.frame = f;
        print(datePicker.frame.size.width, datePicker.frame.size.height);
        
        let secondItem = NSMenuItem();
        secondItem.title = "hello";
        menu.addItem(secondItem);
        
        let time = NSDate();
        
        let currentSecond = time.timeIntervalSinceReferenceDate;
        let timeToAdd = ceil(currentSecond) - currentSecond + 0.1;
        
        timer = NSTimer.init(fireDate: NSDate.init(timeInterval: timeToAdd, sinceDate: time), interval: 1.0, target: self, selector: #selector(AppDelegate.updateTime), userInfo: nil, repeats: true);
        
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode);
        
        //todo: listen to NSSystemClockDidChangeNotification
    }
    
    func updateTime() {
        let currentTime = NSDate();
        let timeString = dateFormatter.stringFromDate(currentTime);
        
        statusItem?.button?.title = timeString;
        statusItem?.button?.alternateTitle = timeString;
        datePicker.dateValue = currentTime;
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}


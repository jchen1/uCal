//
//  PrefsViewController.swift
//  μCal
//
//  Created by Jeff Chen on 6/26/16.
//  Copyright © 2016 Jeff Chen. All rights reserved.
//

import Cocoa

class PrefsViewController: NSViewController, NSTextFieldDelegate {

    @IBOutlet weak var sampleDate: NSTextField!
    @IBOutlet weak var dateFormat: NSTextField!
    @IBOutlet weak var iconCheckbox: NSButton!
    @IBOutlet weak var loginCheckbox: NSButton!
    @IBOutlet weak var upcomingCheckbox: NSButton!
    
    let prefs = NSUserDefaults.standardUserDefaults()
    let dateFormatter = NSDateFormatter()
    var timer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormat.stringValue = prefs.stringForKey("dateFormat")!
        
        dateFormatter.dateFormat = prefs.stringForKey("dateFormat")!
        dateFormatter.lenient = false;
        
        sampleDate.stringValue = dateFormatter.stringFromDate(NSDate())
        
        iconCheckbox.state = prefs.boolForKey("showIcon") ? NSOnState : NSOffState
        loginCheckbox.state = prefs.boolForKey("startAtLogin") ? NSOnState : NSOffState
        upcomingCheckbox.state = prefs.boolForKey("showEvents") ? NSOnState : NSOffState
        
        dateFormat.delegate = self
        setupTimer()
    }
    
    override func controlTextDidChange(notification: NSNotification){
        dateFormatter.dateFormat = dateFormat.stringValue;
        sampleDate.stringValue = dateFormatter.stringFromDate(NSDate())
    }
    
    @IBAction func checkboxPressed(sender: NSButton) {
        var key : String? = nil
        switch sender.title {
        case "Show icon":
            key = "showIcon"
            break
        case "Start at login":
            key = "startAtLogin"
            break
        case "Show upcoming events":
            key = "showEvents"
            break
        default: break
        }
        
        if let key = key {
            prefs.setBool(sender.state == NSOnState, forKey: key)
        }
    }
    
    @IBAction func dateFormatChanged(sender: AnyObject) {
        prefs.setObject(dateFormat.stringValue, forKey: "dateFormat")
    }
    @IBAction func helpButtonPressed(sender: AnyObject) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "http://unicode.org/reports/tr35/tr35-10.html#Date_Format_Patterns")!)
    }
    
    func setupTimer() {
        let time = NSDate();
        
        let currentSecond = time.timeIntervalSinceReferenceDate
        let timeToAdd = ceil(currentSecond) - currentSecond + 0.1
        
        timer = NSTimer.init(fireDate: NSDate.init(timeInterval: timeToAdd, sinceDate: time), interval: 1.0, target: self, selector: #selector(PrefsViewController.updateTime), userInfo: nil, repeats: true)
        
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
    }
    
    func updateTime() {
        sampleDate.stringValue = dateFormatter.stringFromDate(NSDate())
    }
    
    override func viewWillDisappear() {
        prefs.setObject(dateFormat.stringValue, forKey: "dateFormat")
    }
    
}

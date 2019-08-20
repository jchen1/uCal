//
//  PrefsViewController.swift
//  μCal
//
//  Created by Jeff Chen on 6/26/16.
//  Copyright © 2016 Jeff Chen. All rights reserved.
//

import Cocoa

class PrefsViewController: NSViewController, NSTextFieldDelegate, NSTextDelegate {

    @IBOutlet weak var sampleDate: NSTextField!
    @IBOutlet weak var dateFormat: NSTextField!
    @IBOutlet weak var calendarRegex: NSTextField!
    @IBOutlet weak var iconCheckbox: NSButton!
    @IBOutlet weak var loginCheckbox: NSButton!
    @IBOutlet weak var hideAllDayCheckbox: NSButton!
    @IBOutlet weak var upcomingCheckbox: NSButton!
    
    let prefs = UserDefaults.standard
    let dateFormatter = DateFormatter()
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormat.stringValue = prefs.string(forKey: "dateFormat")!
        calendarRegex.stringValue = prefs.string(forKey: "calendarRegex")!
        
        dateFormatter.dateFormat = prefs.string(forKey: "dateFormat")!
        dateFormatter.isLenient = false;
        
        sampleDate.stringValue = dateFormatter.string(from: Date())
        
        iconCheckbox.state = prefs.bool(forKey: "showIcon") ? NSControl.StateValue.on : NSControl.StateValue.off
        loginCheckbox.state = prefs.bool(forKey: "startAtLogin") ? NSControl.StateValue.on : NSControl.StateValue.off
        upcomingCheckbox.state = prefs.bool(forKey: "showEvents") ? NSControl.StateValue.on : NSControl.StateValue.off
        hideAllDayCheckbox.state = prefs.bool(forKey: "hideAllDayEvents") ? NSControl.StateValue.on : NSControl.StateValue.off

        dateFormat.delegate = self
        calendarRegex.delegate = self
        setupTimer()
    }
    
    func textDidChange(_ notification: Notification){
        dateFormatter.dateFormat = dateFormat.stringValue;
        sampleDate.stringValue = dateFormatter.string(from: Date())
    }
    
    @IBAction func checkboxPressed(_ sender: NSButton) {
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
        case "Hide all day events":
            key = "hideAllDayEvents"
            break
        default: break
        }
        
        if let key = key {
            prefs.set(sender.state == NSControl.StateValue.on, forKey: key)
        }
    }
    
    @IBAction func dateFormatChanged(_ sender: AnyObject) {
        prefs.set(dateFormat.stringValue, forKey: "dateFormat")
    }
    
    @IBAction func calendarRegexChanged(_ sender: AnyObject) {
        prefs.set(calendarRegex.stringValue, forKey: "calendarRegex")
    }
    
    
    @IBAction func helpButtonPressed(_ sender: AnyObject) {
        NSWorkspace.shared.open(URL(string: "http://unicode.org/reports/tr35/tr35-10.html#Date_Format_Patterns")!)
    }
    
    func setupTimer() {
        let time = Date();
        
        let currentSecond = time.timeIntervalSinceReferenceDate
        let timeToAdd = ceil(currentSecond) - currentSecond + 0.1
        
        timer = Timer.init(fireAt: Date.init(timeInterval: timeToAdd, since: time), interval: 1.0, target: self, selector: #selector(PrefsViewController.updateTime), userInfo: nil, repeats: true)
        
        RunLoop.current.add(timer, forMode: RunLoop.Mode.default)
    }
    
    @objc func updateTime() {
        sampleDate.stringValue = dateFormatter.string(from: Date())
    }
    
    override func viewWillDisappear() {
        prefs.set(dateFormat.stringValue, forKey: "dateFormat")
        prefs.set(calendarRegex.stringValue, forKey: "calendarRegex")
    }
    
}

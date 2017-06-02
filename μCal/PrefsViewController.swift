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
    @IBOutlet weak var hideAllDayCheckbox: NSButton!
    @IBOutlet weak var upcomingCheckbox: NSButton!
    
    let prefs = UserDefaults.standard
    let dateFormatter = DateFormatter()
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormat.stringValue = prefs.string(forKey: "dateFormat")!
        
        dateFormatter.dateFormat = prefs.string(forKey: "dateFormat")!
        dateFormatter.isLenient = false;
        
        sampleDate.stringValue = dateFormatter.string(from: Date())
        
        iconCheckbox.state = prefs.bool(forKey: "showIcon") ? NSOnState : NSOffState
        loginCheckbox.state = prefs.bool(forKey: "startAtLogin") ? NSOnState : NSOffState
        upcomingCheckbox.state = prefs.bool(forKey: "showEvents") ? NSOnState : NSOffState
        hideAllDayCheckbox.state = prefs.bool(forKey: "hideAllDayEvents") ? NSOnState : NSOffState

        dateFormat.delegate = self
        setupTimer()
    }
    
    override func controlTextDidChange(_ notification: Notification){
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
            prefs.set(sender.state == NSOnState, forKey: key)
        }
    }
    
    @IBAction func dateFormatChanged(_ sender: AnyObject) {
        prefs.set(dateFormat.stringValue, forKey: "dateFormat")
    }
    @IBAction func helpButtonPressed(_ sender: AnyObject) {
        NSWorkspace.shared().open(URL(string: "http://unicode.org/reports/tr35/tr35-10.html#Date_Format_Patterns")!)
    }
    
    func setupTimer() {
        let time = Date();
        
        let currentSecond = time.timeIntervalSinceReferenceDate
        let timeToAdd = ceil(currentSecond) - currentSecond + 0.1
        
        timer = Timer.init(fireAt: Date.init(timeInterval: timeToAdd, since: time), interval: 1.0, target: self, selector: #selector(PrefsViewController.updateTime), userInfo: nil, repeats: true)
        
        RunLoop.current.add(timer, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    func updateTime() {
        sampleDate.stringValue = dateFormatter.string(from: Date())
    }
    
    override func viewWillDisappear() {
        prefs.set(dateFormat.stringValue, forKey: "dateFormat")
    }
    
}

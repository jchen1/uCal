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
    
    let prefs = NSUserDefaults.standardUserDefaults()
    let dateFormatter = NSDateFormatter()
    var timer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormat.stringValue = prefs.stringForKey("dateFormat")!
        
        dateFormatter.dateFormat = prefs.stringForKey("dateFormat")!
        dateFormatter.lenient = false;
        
        sampleDate.stringValue = dateFormatter.stringFromDate(NSDate())
        
        dateFormat.delegate = self
        setupTimer()
    }
    
    override func controlTextDidChange(notification: NSNotification){
        dateFormatter.dateFormat = dateFormat.stringValue;
        sampleDate.stringValue = dateFormatter.stringFromDate(NSDate())
    }
    
    @IBAction func dateFormatChanged(sender: AnyObject) {
        prefs.setObject(dateFormat.stringValue, forKey: "dateFormat")
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

//
//  AppDelegate.swift
//  μCal
//
//  Created by Jeff Chen on 6/25/16.
//  Copyright © 2016 Jeff Chen. All rights reserved.
//

// 1x, bottom align at 16px, ft size 9px
// 2x, bottom align at 32px, ft size 12px

//      About page?

import Cocoa
import EventKit
import ServiceManagement

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    
    var statusBar = NSStatusBar.systemStatusBar()
    var statusItem: NSStatusItem?
    var menu = NSMenu()
    var calendarItem = NSMenuItem()
    var eventsItem = NSMenuItem()
    
    let dateFormatter = NSDateFormatter()
    var timer = NSTimer()
    let prefs = NSUserDefaults.standardUserDefaults()
    var lastDay:UInt8 = 0
    var prefsWindowController: NSWindowController?
    let launcherAppId = "com.jchen.uCalHelper"

    func applicationDidFinishLaunching(aNotification: NSNotification) {        
        setupPreferences()
        lastDay = getDay(NSDate())
        
        statusItem = statusBar.statusItemWithLength(NSVariableStatusItemLength, priority: NSStatusBarItemPriority.System)
        statusItem?.button?.image = getNumberedIcon()
        statusItem?.button?.image?.template = true
        statusItem?.button?.imagePosition = prefs.boolForKey("showIcon") ? NSCellImagePosition.ImageLeft : NSCellImagePosition.NoImage
        statusItem?.button?.setFrameOrigin(NSPoint(x: 0, y: 1))
        
        dateFormatter.dateFormat = prefs.stringForKey("dateFormat")
                
        updateTime()
        setupMenu()
        setupTimer()
        setupHelper()
        
        checkAndRequestEventStoreAccess()
        
        prefs.addObserver(self, forKeyPath: "dateFormat", options: NSKeyValueObservingOptions.New, context: nil)
        prefs.addObserver(self, forKeyPath: "showIcon", options: NSKeyValueObservingOptions.New, context: nil)
        prefs.addObserver(self, forKeyPath: "startAtLogin", options: NSKeyValueObservingOptions.New, context: nil)
        prefs.addObserver(self, forKeyPath: "showEvents", options: NSKeyValueObservingOptions.New, context: nil)
        
        //todo: listen to NSSystemClockDidChangeNotification
        // maybe not - we update every second anyways
    }
    
    func setupHelper() {
        for app in NSWorkspace.sharedWorkspace().runningApplications {
            if app.bundleIdentifier == launcherAppId {
                NSDistributedNotificationCenter.defaultCenter().postNotificationName("uCalHelperKillNotification", object: NSBundle.mainBundle().bundleIdentifier!)
            }
        }
        
        SMLoginItemSetEnabled(launcherAppId, prefs.boolForKey("startAtLogin"))

    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let keyPath = keyPath, change = change {
            switch keyPath {
            case "dateFormat":
                dateFormatter.dateFormat = change["new"] as! String
                break
            case "showIcon":
                let newValue = change["new"] as! Bool
                toggleIcon(newValue)
                break
            case "startAtLogin":
                let newValue = change["new"] as! Bool
                toggleAutostart(newValue)
                break
            case "showEvents":
                let newValue = change["new"] as! Bool
                toggleEV(newValue)
                break
            default:
                break
            }
        }
    }
    
    func setupTimer() {
        let time = NSDate()
        
        let currentSecond = time.timeIntervalSinceReferenceDate
        let timeToAdd = ceil(currentSecond) - currentSecond + 0.1
        
        timer = NSTimer.init(fireDate: NSDate.init(timeInterval: timeToAdd, sinceDate: time), interval: 1.0, target: self, selector: #selector(AppDelegate.updateTime), userInfo: nil, repeats: true)
        
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
    }
    
    func setupPreferences() {
        if !prefs.boolForKey("setupDone") {
            prefs.setBool(true, forKey: "showIcon")
            prefs.setBool(false, forKey: "startAtLogin")
            prefs.setBool(true, forKey: "showEvents")
            prefs.setObject("EEE h:mm aa", forKey: "dateFormat")
            
            prefs.setBool(true, forKey: "setupDone")
        }
    }
    
    func setupMenu() {
        statusItem?.menu = menu
        menu.minimumWidth = 160
        
        calendarItem = menu.addItemWithTitle("cal", action: nil, keyEquivalent: "")!
        calendarItem.view = getCV()
        
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(NSMenuItem.separatorItem())
        
        menu.addItemWithTitle("Preferences...", action: #selector(AppDelegate.openFmtWindow), keyEquivalent: "")

        menu.addItem(NSMenuItem.separatorItem())
        menu.addItemWithTitle("Open Calendar...", action: #selector(AppDelegate.openCalendar), keyEquivalent: "")
        menu.addItemWithTitle("Date & Time...", action: #selector(AppDelegate.openTimeSettings), keyEquivalent: "")
        
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItemWithTitle("Quit μCal", action: #selector(AppDelegate.quit), keyEquivalent: "")
        
        menu.delegate = self
    }
    
    func openTimeSettings() {
        NSWorkspace.sharedWorkspace().openURL(NSURL.fileURLWithPath("/System/Library/PreferencePanes/DateAndTime.prefPane"))
    }
    
    func openCalendar() {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "ical://")!)
    }
    
    func menuWillOpen(menu: NSMenu) {
        (calendarItem.view?.subviews[0] as! CalendarView).menuWillOpen()
        
        let authorizationStatus = EKEventStore.authorizationStatusForEntityType(EKEntityType.Event)
        if authorizationStatus == EKAuthorizationStatus.Authorized {
            eventsItem.view = getEV()
            eventsItem.view?.display()
        }
    }
    
    func openFmtWindow() {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateControllerWithIdentifier("prefsViewController") as? PrefsViewController
        {
            let myWindow = NSWindow(contentViewController: vc)
            myWindow.title = "µCal Preferences"
            myWindow.makeKeyAndOrderFront(self)
            myWindow.styleMask &= ~NSResizableWindowMask
            prefsWindowController = NSWindowController(window: myWindow)
            
            prefsWindowController!.showWindow(self)
            NSApp.activateIgnoringOtherApps(true)
        }
    }
    
    func checkAndRequestEventStoreAccess() {
        let authorizationStatus = EKEventStore.authorizationStatusForEntityType(EKEntityType.Event)
        switch authorizationStatus {
        case EKAuthorizationStatus.Denied:
            break
        case EKAuthorizationStatus.Restricted:
            break
        case EKAuthorizationStatus.Authorized:
            setupEventView(true, error: nil)
            break
        case EKAuthorizationStatus.NotDetermined:
            EKEventStore().requestAccessToEntityType(EKEntityType.Event, completion: self.setupEventView)
            break
        }
    }
    
    func setupEventView(shouldSetup: Bool, error: NSError?) {
        if shouldSetup && prefs.boolForKey("showEvents") {
            eventsItem = NSMenuItem()
            eventsItem.view = getEV()
            menu.insertItem(eventsItem, atIndex: 2)
        }
    }
    
    func getDay(date : NSDate) -> UInt8 {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "d"
        return UInt8(formatter.stringFromDate(date))!
    }
    
    func toggleIcon(showIcon: Bool) {
        if showIcon {
            statusItem?.button?.imagePosition = NSCellImagePosition.ImageLeft
        }
        else {
            statusItem?.button?.imagePosition = NSCellImagePosition.NoImage
        }
    }
    
    func toggleAutostart(autoStart: Bool) {
        let autostartItem = menu.itemAtIndex(menu.indexOfItemWithTitle("Start at login"))
        if autoStart {
            autostartItem?.state = NSOnState
        }
        else {
            autostartItem?.state = NSOffState
        }
        SMLoginItemSetEnabled(launcherAppId, autoStart)
    }
    
    func toggleEV(showEvents: Bool) {
        if showEvents {
            checkAndRequestEventStoreAccess()
        }
        else {
            menu.removeItem(eventsItem)
            
        }
    }
    
    func quit() {
        NSApplication.sharedApplication().terminate(self)
    }
    
    func getEV() -> NSView {
        let view = NSView()
        view.setFrameSize(NSSize(width: 160, height: 150))
        
        let uev = UpcomingEventsView(frame: NSRect(x: 5, y: 0, width: 150, height: 150))
        uev.frame.origin.y = uev.desiredHeight - 150
        view.frame.size.height = uev.desiredHeight
        
        uev.needsDisplay = true
        view.addSubview(uev)
        
        return view
    }
    
    func getCV() -> NSView {
        let view = NSView()
        view.setFrameSize(NSSize(width: 160, height: 150))
        
        view.addSubview(CalendarView(frame: NSRect(x: 5, y: -2, width: 150, height: 150)))
        
        return view
    }

    func getNumberedIcon() -> NSImage {
        let icon = NSImage(named: "calendar")
        let numberedIcon = NSImage(size: (icon?.size)!)
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.Center
        let attrs = [NSParagraphStyleAttributeName: style, NSFontAttributeName: NSFont.menuBarFontOfSize(9)]
        let dayString = String(getDay(NSDate()))
        
        numberedIcon.lockFocus();
        icon?.drawAtPoint(NSZeroPoint, fromRect: NSZeroRect, operation: NSCompositingOperation.CompositeSourceOver, fraction: 1.0)
        dayString.drawInRect(NSRect(origin: NSPoint(x: 0, y: -7), size: numberedIcon.size), withAttributes: attrs)
            
        numberedIcon.unlockFocus()
        
        return numberedIcon
    }
    
    func updateTime() {
        let currentTime = NSDate()
        let timeString = dateFormatter.stringFromDate(currentTime)
        
        statusItem?.button?.title = timeString
        //TODO: make this work
        statusItem?.button?.alternateTitle = timeString
        
        if (lastDay != getDay(currentTime)) {
            lastDay = getDay(currentTime)
            statusItem?.button?.image = getNumberedIcon()
            statusItem?.button?.image?.template = true
        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        prefs.removeObserver(self, forKeyPath: "dateFormat")
        prefs.removeObserver(self, forKeyPath: "showIcon")
        prefs.removeObserver(self, forKeyPath: "startAtLogin")
        prefs.removeObserver(self, forKeyPath: "showEvents")
    }


}


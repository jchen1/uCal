//
//  AppDelegate.swift
//  μCal
//
//  Created by Jeff Chen on 6/25/16.
//  Copyright © 2016 Jeff Chen. All rights reserved.
//

// 1x, bottom align at 16px, ft size 9px
// 2x, bottom align at 32px, ft size 12px

//TODO: autostart at login
//      About page?

import Cocoa
import ServiceManagement

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    
    var statusBar = NSStatusBar.systemStatusBar()
    var statusItem: NSStatusItem?
    var menu = NSMenu()
    var calendarItem = NSMenuItem()
    
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
        
        dateFormatter.dateFormat = prefs.stringForKey("dateFormat")
                
        updateTime()
        setupMenu()
        setupTimer()
        setupHelper()
        
        prefs.addObserver(self, forKeyPath: "dateFormat", options: NSKeyValueObservingOptions.New, context: nil)
        
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
        switch keyPath! {
        case "dateFormat":
            dateFormatter.dateFormat = change!["new"] as! String
            break
        default: break
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
            prefs.setObject("EEE h:mm aa", forKey: "dateFormat")
            
            prefs.setBool(true, forKey: "setupDone")
        }
    }
    
    func setupMenu() {
        statusItem?.menu = menu
        menu.minimumWidth = 160
        
        calendarItem = menu.addItemWithTitle("item", action: nil, keyEquivalent: "")!
        calendarItem.view = getCV()
        
        menu.addItem(NSMenuItem.separatorItem())
        
        let loginItem = menu.addItemWithTitle("Start at login", action: #selector(AppDelegate.toggleAutostart), keyEquivalent: "")
        loginItem!.state = prefs.boolForKey("startAtLogin") ? NSOnState : NSOffState
        
        let iconItem = menu.addItemWithTitle("Show icon", action: #selector(AppDelegate.toggleIcon), keyEquivalent: "")
        iconItem!.state = prefs.boolForKey("showIcon") ? NSOnState : NSOffState
        
        menu.addItemWithTitle("Format clock...", action: #selector(AppDelegate.openFmtWindow), keyEquivalent: "")

        menu.addItem(NSMenuItem.separatorItem())
        menu.addItemWithTitle("Date & Time...", action: #selector(AppDelegate.openTimeSettings), keyEquivalent: "")
        
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItemWithTitle("Quit μCal", action: #selector(AppDelegate.quit), keyEquivalent: "")
        
        menu.delegate = self
    }
    
    func openTimeSettings() {
        NSWorkspace.sharedWorkspace().openURL(NSURL.fileURLWithPath("/System/Library/PreferencePanes/DateAndTime.prefPane"))
    }
    
    func menuWillOpen(menu: NSMenu) {
        (calendarItem.view?.subviews[0] as! CalendarView).menuWillOpen()
    }
    
    func openFmtWindow() {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateControllerWithIdentifier("prefsViewController") as? PrefsViewController
        {
            let myWindow = NSWindow(contentViewController: vc)
            myWindow.title = "Format clock..."
            myWindow.makeKeyAndOrderFront(self)
            myWindow.styleMask &= ~NSResizableWindowMask
            prefsWindowController = NSWindowController(window: myWindow)
            
            prefsWindowController!.showWindow(self)
            NSApp.activateIgnoringOtherApps(true)
        }
    }
    
    func getDay(date : NSDate) -> UInt8 {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "d"
        return UInt8(formatter.stringFromDate(date))!
    }
    
    func toggleIcon() {
        let showIcon = !prefs.boolForKey("showIcon")
        let iconItem = menu.itemAtIndex(menu.indexOfItemWithTitle("Show icon"))
        if showIcon {
            statusItem?.button?.imagePosition = NSCellImagePosition.ImageLeft
            iconItem?.state = NSOnState
        }
        else {
            statusItem?.button?.imagePosition = NSCellImagePosition.NoImage
            iconItem?.state = NSOffState
        }
        prefs.setBool(showIcon, forKey: "showIcon")
    }
    
    func toggleAutostart() {
        let autoStart = !prefs.boolForKey("startAtLogin")
        let autostartItem = menu.itemAtIndex(menu.indexOfItemWithTitle("Start at login"))
        if autoStart {
            autostartItem?.state = NSOnState
        }
        else {
            autostartItem?.state = NSOffState
        }
        prefs.setBool(autoStart, forKey: "startAtLogin")
        SMLoginItemSetEnabled(launcherAppId, autoStart)
    }
    
    func quit() {
        NSApplication.sharedApplication().terminate(self)
    }
    
    func getCV() -> NSView {
        let view = NSView()
        view.setFrameSize(NSSize(width: 160, height: 150))
        
        view.addSubview(CalendarView(frame: NSRect(x: 5, y: -2, width: 140, height: 150)))
        
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
        dayString.drawInRect(NSRect(origin: NSPoint(x: 0, y: -6), size: numberedIcon.size), withAttributes: attrs)
            
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
    }


}


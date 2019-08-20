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
    
    var statusBar = NSStatusBar.system
    let statusItem: NSStatusItem
    var menu = NSMenu()
    var calendarItem = NSMenuItem()
    var eventsItem = NSMenuItem()
    var eventsView: UpcomingEventsView?
    
    let dateFormatter = DateFormatter()
    var timer = Timer()
    let prefs = UserDefaults.standard
    var lastDay:UInt8 = 0
    var prefsWindowController: NSWindowController?
    let launcherAppId = "com.jchen.uCalHelper"
    
    override init() {
        statusItem = statusBar.statusItem(withLength: NSStatusItem.variableLength, priority: NSStatusBarItemPriority.system)
        super.init()
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupPreferences()
        lastDay = getDay(Date())

        statusItem.button?.image = getNumberedIcon()
        statusItem.button?.image?.isTemplate = true
        statusItem.button?.imagePosition = prefs.bool(forKey: "showIcon") ? NSControl.ImagePosition.imageLeft : NSControl.ImagePosition.noImage
        statusItem.button?.setFrameOrigin(NSPoint(x: 0, y: 1))
        
        dateFormatter.dateFormat = prefs.string(forKey: "dateFormat")
                
        updateTime()
        setupMenu()
        setupTimer()
        setupHelper()

        checkAndRequestEventStoreAccess()
        //todo: listen to NSSystemClockDidChangeNotification
        // maybe not - we update every second anyways
    }
    
    func setupHelper() {
        for app in NSWorkspace.shared.runningApplications {
            if app.bundleIdentifier == launcherAppId {
                DistributedNotificationCenter.default().post(name: Notification.Name(rawValue: "uCalHelperKillNotification"), object: Bundle.main.bundleIdentifier!)
            }
        }
        
        SMLoginItemSetEnabled(launcherAppId as CFString, prefs.bool(forKey: "startAtLogin"))

    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let keyPath = keyPath, let newVal = change?[.newKey] {
            switch keyPath {
            case "dateFormat":
                dateFormatter.dateFormat = (newVal as! String)
                break
            case "showIcon":
                let newValue = newVal as! Bool
                toggleIcon(newValue)
                break
            case "startAtLogin":
                let newValue = newVal as! Bool
                toggleAutostart(newValue)
                break
            case "showEvents":
                let newValue = newVal as! Bool
                toggleEV(newValue)
                break
            case "hideAllDayEvents":
                toggleEV(prefs.bool(forKey: "showEvents"))
                break
            default:
                break
            }
        }
    }
    
    func setupTimer() {
        let time = Date()
        
        let currentSecond = time.timeIntervalSinceReferenceDate
        let timeToAdd = ceil(currentSecond) - currentSecond + 0.1
        
        timer = Timer.init(fireAt: Date.init(timeInterval: timeToAdd, since: time), interval: 1.0, target: self, selector: #selector(AppDelegate.updateTime), userInfo: nil, repeats: true)
        
        RunLoop.current.add(timer, forMode: RunLoop.Mode.default)
    }
    
    func setupPreferences() {
        if !prefs.bool(forKey: "setupDone") {
            prefs.set(true, forKey: "showIcon")
            prefs.set(false, forKey: "startAtLogin")
            prefs.set(true, forKey: "showEvents")
            prefs.set("EEE h:mm aa", forKey: "dateFormat")
            prefs.set(true, forKey: "hideAllDayEvents")
            
            prefs.set(true, forKey: "setupDone")
        }
        prefs.addObserver(self, forKeyPath: "dateFormat", options: NSKeyValueObservingOptions.new, context: nil)
        prefs.addObserver(self, forKeyPath: "showIcon", options: NSKeyValueObservingOptions.new, context: nil)
        prefs.addObserver(self, forKeyPath: "startAtLogin", options: NSKeyValueObservingOptions.new, context: nil)
        prefs.addObserver(self, forKeyPath: "showEvents", options: NSKeyValueObservingOptions.new, context: nil)
        prefs.addObserver(self, forKeyPath: "hideAllDayEvents", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    func setupMenu() {
        statusItem.menu = menu
        menu.minimumWidth = 160
        
        calendarItem = menu.addItem(withTitle: "cal", action: nil, keyEquivalent: "")
        calendarItem.view = getCV()
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem.separator())
        
        menu.addItem(withTitle: "Preferences...", action: #selector(AppDelegate.openFmtWindow), keyEquivalent: "")

        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Open Calendar...", action: #selector(AppDelegate.openCalendar), keyEquivalent: "")
        menu.addItem(withTitle: "Date & Time...", action: #selector(AppDelegate.openTimeSettings), keyEquivalent: "")
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Quit μCal", action: #selector(AppDelegate.quit), keyEquivalent: "")
        
        menu.delegate = self
    }
    
    @objc func openTimeSettings() {
        NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Library/PreferencePanes/DateAndTime.prefPane"))
    }
    
    @objc func openCalendar() {
        NSWorkspace.shared.open(URL(string: "ical://")!)
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        (calendarItem.view?.subviews[0] as! CalendarView).menuWillOpen()
        
        let authorizationStatus = EKEventStore.authorizationStatus(for: EKEntityType.event)
        if authorizationStatus == EKAuthorizationStatus.authorized && prefs.bool(forKey: "showEvents"){
            getEV()
//            eventsItem.view = getEV()
            eventsItem.view?.display()
        }
    }
    
    @objc func openFmtWindow() {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateController(withIdentifier: "prefsViewController") as? PrefsViewController
        {
            let myWindow = NSWindow(contentViewController: vc)
            myWindow.title = "µCal Preferences"
            myWindow.makeKeyAndOrderFront(self)
            myWindow.styleMask.remove(.resizable)
            prefsWindowController = NSWindowController(window: myWindow)
            prefsWindowController!.showWindow(self)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    func checkAndRequestEventStoreAccess() {
        let authorizationStatus = EKEventStore.authorizationStatus(for: EKEntityType.event)
        switch authorizationStatus {
        case EKAuthorizationStatus.denied:
            print("authorizationStatus denied")
            break
        case EKAuthorizationStatus.restricted:
            print("authorizationStatus restricted")
            break
        case EKAuthorizationStatus.authorized:
            print("authorizationStatus authorized")
            setupEventView(true, error: nil)
            break
        case EKAuthorizationStatus.notDetermined:
            print("authorizationStatus not determined")
            EKEventStore().requestAccess(to: EKEntityType.event, completion: self.setupEventView)
            break
        }
    }
    
    func setupEventView(_ shouldSetup: Bool, error: Error?) {
        if shouldSetup && prefs.bool(forKey: "showEvents") {
            eventsItem = NSMenuItem()
            eventsView = getEV()
            let view = NSView()
            view.setFrameSize(NSSize(width: 160, height: 150))
            eventsView!.frame.origin.y = eventsView!.desiredHeight - 150
            view.frame.size.height = eventsView!.desiredHeight
            eventsView!.needsDisplay = true
            view.addSubview(eventsView!)
            
            eventsItem.view = view
            menu.insertItem(eventsItem, at: 2)
        }
    }
    
    func getDay(_ date : Date) -> UInt8 {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return UInt8(formatter.string(from: date))!
    }
    
    func toggleIcon(_ showIcon: Bool) {
        if showIcon {
            statusItem.button?.imagePosition = NSControl.ImagePosition.imageLeft
        }
        else {
            statusItem.button?.imagePosition = NSControl.ImagePosition.noImage
        }
    }
    
    func toggleAutostart(_ autoStart: Bool) {
        SMLoginItemSetEnabled(launcherAppId as CFString, autoStart)
    }
    
    func toggleEV(_ showEvents: Bool) {
        if showEvents {
            checkAndRequestEventStoreAccess()
        } else {
            menu.removeItem(eventsItem)
        }
    }
    
    @objc func quit() {
        NSApplication.shared.terminate(self)
    }
    
    func getEV() -> UpcomingEventsView {
        let hideAllDayEvents = prefs.bool(forKey: "hideAllDayEvents")

        if (eventsView == nil) {
            let uev = UpcomingEventsView(frame: NSRect(x: 5, y: 0, width: 150, height: 150), hideAllDayEvents: hideAllDayEvents)
            uev.frame.origin.y = uev.desiredHeight - 150
            uev.needsDisplay = true
            return uev
        } else {
            if (eventsView!.needsRefresh()) {
                eventsView!.getEvents(hideAllDayEvents: hideAllDayEvents)
                eventsView!.clear()
                eventsView!.drawEvents()
            }
            return eventsView!
        }
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
        style.alignment = NSTextAlignment.center
        let attrs = [NSAttributedString.Key.paragraphStyle: style, NSAttributedString.Key.font: NSFont.menuBarFont(ofSize: 9)]
        let dayString = String(getDay(Date()))
        
        numberedIcon.lockFocus();
        icon?.draw(at: NSZeroPoint, from: NSZeroRect, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
        dayString.draw(in: NSRect(origin: NSPoint(x: 0, y: -7), size: numberedIcon.size), withAttributes: attrs)
            
        numberedIcon.unlockFocus()
        
        return numberedIcon
    }
    
    @objc func updateTime() {
        let currentTime = Date()
        let timeString = dateFormatter.string(from: currentTime)
        
        statusItem.button?.title = timeString
        //TODO: make this work
        statusItem.button?.alternateTitle = timeString
        
        if (lastDay != getDay(currentTime)) {
            lastDay = getDay(currentTime)
            statusItem.button?.image = getNumberedIcon()
            statusItem.button?.image?.isTemplate = true
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        prefs.removeObserver(self, forKeyPath: "dateFormat")
        prefs.removeObserver(self, forKeyPath: "showIcon")
        prefs.removeObserver(self, forKeyPath: "startAtLogin")
        prefs.removeObserver(self, forKeyPath: "showEvents")
        prefs.removeObserver(self, forKeyPath: "hideAllDayEvents")
    }
}


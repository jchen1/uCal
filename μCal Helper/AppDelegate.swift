//
//  AppDelegate.swift
//  μCal Helper
//
//  Created by Jeff Chen on 6/26/16.
//  Copyright © 2016 Jeff Chen. All rights reserved.
//

import Cocoa
import ServiceManagement

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let mainAppId = "com.jchen.uCal"
        let running = NSWorkspace.shared.runningApplications
        var alreadyRunning = false
        
        for app in running {
            if app.bundleIdentifier == mainAppId {
                alreadyRunning = true
            }
        }
        
        if alreadyRunning {
            self.quit()
        }
        else {
            DistributedNotificationCenter.default().addObserver(self, selector: #selector(AppDelegate.quit), name: Notification.Name(rawValue: "uCalHelperKillNotification"), object: mainAppId)
            
            let path = Bundle.main.bundlePath as NSString
            var components = path.pathComponents
            components.removeLast()
            components.removeLast()
            components.removeLast()
            components.append("MacOS")
            components.append("μCal")
            
            let newPath = NSString.path(withComponents: components)
            NSWorkspace.shared.launchApplication(newPath)
        }
    }
    
    @objc func quit() {
        NSApplication.shared.terminate(self);
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}


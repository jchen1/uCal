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

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let mainAppId = "com.jchen.uCal"
        let running = NSWorkspace.sharedWorkspace().runningApplications
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
            NSDistributedNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.quit), name: "UCalHelperKillNotification", object: mainAppId)
            
            let path = NSBundle.mainBundle().bundlePath as NSString
            var components = path.pathComponents
            components.removeLast()
            components.removeLast()
            components.removeLast()
            components.append("MacOS")
            components.append("μCal")
            
            let newPath = NSString.pathWithComponents(components)
            NSWorkspace.sharedWorkspace().launchApplication(newPath)
        }
    }
    
    func quit() {
        NSApplication.sharedApplication().terminate(self);
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}


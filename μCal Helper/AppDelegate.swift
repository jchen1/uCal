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
        let launcherAppIdentifier = "com.jchen.μCalHelper"
        
        SMLoginItemSetEnabled(launcherAppIdentifier, true)
        
        var startedAtLogin = false
        for app in NSWorkspace.sharedWorkspace().runningApplications {
            if app.bundleIdentifier == launcherAppIdentifier {
                startedAtLogin = true
            }
        }
        
//        if startedAtLogin
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}


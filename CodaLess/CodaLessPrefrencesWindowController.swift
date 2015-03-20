//
//  CodaLessPrefrencesWindowController.swift
//  CodaLess
//
//  Created by Theo on 05/12/14.
//  Copyright (c) 2014 Theo Weidmann. All rights reserved.
//

import Cocoa
import AppKit

class CodaLessPrefrencesWindowController: NSWindowController, NSTextFieldDelegate {
  
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var minifyButton: NSButton!
    @IBOutlet weak var pathField: NSTextField!
    @IBOutlet weak var version: NSTextField!
    @IBOutlet weak var progress: NSProgressIndicator!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        minifyButton.state = userDefaults.boolForKey("cleanCSS") ? 1 : 0
        
        if let format = userDefaults.stringForKey("cssPath") {
            pathField.stringValue = format
        }
        
        if !NSFileManager.defaultManager().fileExistsAtPath("/usr/local/bin/node") {
            version.stringValue = "Node not in place"
        }
        else if !NSFileManager.defaultManager().fileExistsAtPath("/usr/local/lib/node_modules/less/bin/lessc"){
            version.stringValue = "Less not in place"
        }
        else {
            progress.startAnimation(self)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                let task = NSTask()
                task.launchPath = "/usr/local/bin/node"
                task.arguments = ["/usr/local/lib/node_modules/less/bin/lessc", "-v"]
                
                let outputPipe = NSPipe()
                
                task.standardOutput = outputPipe
                task.terminationHandler = { (task: NSTask!) in
                    let string = NSString(data: outputPipe.fileHandleForReading.readDataToEndOfFile(), encoding: NSUTF8StringEncoding)
                    
                    if string != nil && string!.length != 0 {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            let version = string!.substringWithRange(NSRange(location: 6,length: 5))
                            
                            self.progress.stopAnimation(self)
                            
                            if EDSemver(string: version).isLessThan(EDSemver(string: "2.2.0")) {
                                self.version.textColor = NSColor.redColor()
                                self.version.stringValue = "Less Version: \(version). Please update or click the ?."
                            }
                            else {
                                self.version.stringValue = "Less Version: " + version
                            }
                            
                            return
                            
                        })
                    }
                    else {
                        self.progress.stopAnimation(self)
                        self.version.stringValue = "Less version could not be determined"
                        return
                    }
                }
                
                task.launch()
            })
        }
    }

    @IBAction func minifyChanged(sender: AnyObject) {
        userDefaults.setBool(minifyButton.state == 1, forKey: "cleanCSS")
    }
    
    @IBAction func openHelp(sender: AnyObject) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://github.com/idmean/CodaLess")!)
    }
    
    override func controlTextDidChange(obj: NSNotification) {
         userDefaults.setObject(pathField.stringValue, forKey: "cssPath")
    }
}

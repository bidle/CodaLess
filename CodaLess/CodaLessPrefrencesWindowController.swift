//
//  CodaLessPrefrencesWindowController.swift
//  CodaLess
//
//  Created by Theo on 05/12/14.
//  Copyright (c) 2014 Theo Weidmann. All rights reserved.
//

import Cocoa

class CodaLessPrefrencesWindowController: NSWindowController, NSTextFieldDelegate {
  
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var minifyButton: NSButton!
    @IBOutlet weak var pathField: NSTextField!
    @IBOutlet weak var version: NSTextField!
    @IBOutlet weak var progress: NSProgressIndicator!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        minifyButton.state = userDefaults.boolForKey("minify") ? 1 : 0
        
        if let format = userDefaults.stringForKey("cssPath") {
            pathField.stringValue = format
        }
        
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
                        
                        self.progress.stopAnimation(self)
                        self.version.stringValue = "Less Version: " + string!.substringWithRange(NSRange(location: 6,length: 5))
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

    @IBAction func minifyChanged(sender: AnyObject) {
        userDefaults.setBool(minifyButton.state == 1, forKey: "minify")
    }
    
    override func controlTextDidChange(obj: NSNotification) {
         userDefaults.setObject(pathField.stringValue, forKey: "cssPath")
    }
}

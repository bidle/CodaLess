//
//  CodaLess.swift
//  CodaLess
//
//  Created by Theo on 05/12/14.
//  Copyright (c) 2014 Theo Weidmann. All rights reserved.
//

import AppKit
import Foundation

class CodaLess: NSObject, CodaPlugIn {
   
    var bundle: CodaPlugInBundle
    var preferences: CodaLessPrefrencesWindowController?
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    required init!(plugInController aController: CodaPlugInsController!, plugInBundle: CodaPlugInBundle!) {
        bundle = plugInBundle
        
        userDefaults.registerDefaults([
            "cssPath": "{path}/{basename}.css",
            "cleanCSS": false
            ])
        
        super.init()
        
        aController.registerActionWithTitle("CodaLess Preferences", underSubmenuWithTitle: nil, target: self, selector: "showPreferences", representedObject: nil, keyEquivalent: nil, pluginName: name())
        
        if !NSFileManager.defaultManager().fileExistsAtPath("/usr/local/bin/node") {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let alert = NSAlert()
                alert.messageText = "CodaLess: Node not found"
                alert.informativeText = "Node could not be found at /usr/local/bin/node."
                alert.runModal()
            })
        }
        else if !NSFileManager.defaultManager().fileExistsAtPath("/usr/local/lib/node_modules/less/bin/lessc") {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let alert = NSAlert()
                alert.messageText = "CodaLess: Less not found"
                alert.informativeText = "The less compiler could not be found at /usr/local/lib/node_modules/less/bin/lessc."
                alert.runModal()
            })
        }
        
        if userDefaults.boolForKey("minify") {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let alert = NSAlert()
                alert.messageText = "CodaLess: Less minify deprecation"
                alert.informativeText = "The less developers deprecated the minify option. Therefore the minify option was removed, however you can now choose to enable the Clean CSS plugin in the preferences."
                alert.runModal()
            })
            userDefaults.removeObjectForKey("minify")
        }
    }

    func name() -> String! {
        return "CodaLess"
    }
    
    func textViewWillSave(textView: CodaTextView!) {
        let path = textView.path()
        
        if path == nil {
            return
        }

        let components = path.pathComponents.reverse()
        
        if path.pathExtension != "less" || (components[2] == "Coda 2" && components[3] == "Caches") {
            return
        }
        
        let destination = path.stringByDeletingLastPathComponent
        let basename = path.lastPathComponent.stringByDeletingPathExtension
        
        if let format = userDefaults.stringForKey("cssPath") {
            let cssPath = format.stringByReplacingOccurrencesOfString("{path}", withString: destination, options: NSStringCompareOptions.LiteralSearch, range: nil).stringByReplacingOccurrencesOfString("{basename}", withString: basename, options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            let task = NSTask()
            task.launchPath = "/usr/local/bin/node"
            
            var args = ["/usr/local/lib/node_modules/less/bin/lessc", path, cssPath, "--no-color"]
            if userDefaults.boolForKey("cleanCSS") {
                args.append("--clean-css")
            }
            
            task.arguments = args
            
            let outputPipe = NSPipe()
            
            task.standardError = outputPipe
            
            task.terminationHandler = { (task: NSTask!) in
                let string = NSString(data: outputPipe.fileHandleForReading.readDataToEndOfFile(), encoding: NSUTF8StringEncoding)
                
                if string != nil && string!.length > 0 {
                    let alert = NSAlert()
                    alert.messageText = "LESS Compilation Error"
                    alert.informativeText = string as? String
                    alert.addButtonWithTitle("OK")
                    
                    var err: NSError?
                    let regex = NSRegularExpression(pattern: "line (\\d+), column (\\d+)", options: NSRegularExpressionOptions.CaseInsensitive, error: &err)
                    
                    var errLine: Int?
                    var errCol: Int?
                    
                    if regex != nil {
                        
                        let match = regex!.firstMatchInString(string as! String, options: NSMatchingOptions.allZeros, range: NSRange(location: 0, length: string!.length))
                        
                        if match != nil {
                            
                            errLine = string!.substringWithRange(match!.rangeAtIndex(1)).toInt()
                            errCol = string!.substringWithRange(match!.rangeAtIndex(2)).toInt()
                            
                            alert.addButtonWithTitle("Jump to error")
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        if alert.runModal() == NSAlertSecondButtonReturn {
                            if errLine != nil && errCol != nil {
                                textView.goToLine(errLine!, column: errCol!)
                            }
                            else {
                                let alert = NSAlert()
                                alert.messageText = "Could not determine error position"
                                alert.informativeText = "CodaLess was not able to determine the position of the error. Please submit an issue on https://github.com/idmean/CodaLess/issues including your less version!"
                                alert.runModal()
                            }
                        }
                        return
                        
                    }
                }
            }
            
            task.launch()
        }
    }
    
    func showPreferences(){
        
        if preferences == nil {
            preferences = CodaLessPrefrencesWindowController(windowNibName: "CodaLessPreferencesWindowController")
        }
        preferences!.showWindow(self)
        
    }
    
}

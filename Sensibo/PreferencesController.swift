//
//  PreferencesController.swift
//  Sensibo
//
//  Created by Colin Harris on 12/2/19.
//  Copyright © 2019 Colin Harris. All rights reserved.
//

import Cocoa

class PreferencesController: NSViewController {
    
    @IBOutlet var apiKeyField: NSTextField!
    
    @IBAction func saveClicked(_ sender: Any) {
        print("saveClicked")
        UserDefaults.standard.set(apiKeyField.stringValue, forKey: "APIKey")
        appDelegate()?.initMenu()
        closeWindow()
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        print("cancelClicked")
        closeWindow()
    }
    
    func closeWindow() {
        self.view.window?.windowController?.close()
    }
    
    func appDelegate() -> AppDelegate? {
        return NSApplication.shared.delegate as? AppDelegate
    }
}

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
    @IBOutlet var mainPodField: NSTextField!
    @IBOutlet var versionLabel: NSTextField!
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        if let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String,
            let buildNumber = Bundle.main.infoDictionary!["CFBundleVersion"] as? String {
            versionLabel.stringValue = "v\(appVersion) (\(buildNumber))"
        }
        
        apiKeyField.stringValue = UserDefaults.standard.string(forKey: "APIKey") ?? ""
        mainPodField.stringValue = UserDefaults.standard.string(forKey: "MainPod") ?? ""
        
        self.view.window?.orderFrontRegardless()
    }
    
    @IBAction func saveClicked(_ sender: Any) {
        print("saveClicked")
        UserDefaults.standard.set(apiKeyField.stringValue, forKey: "APIKey")
        UserDefaults.standard.set(mainPodField.stringValue, forKey: "MainPod")
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

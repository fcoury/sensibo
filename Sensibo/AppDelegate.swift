//
//  AppDelegate.swift
//  Sensibo
//
//  Created by Colin Harris on 12/2/19.
//  Copyright © 2019 Colin Harris. All rights reserved.
//

import Cocoa
import SensiboClient

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var sensiboClient: SensiboClient?
    var pods: [Pod] = []
    
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    var preferencesWindow: NSWindowController?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("StatusBarButtonImage"))
        }
        initMenu()
    }
    
    func initMenu() {
        loadConfig()
        
        if let client = sensiboClient {
            client.getPods() { (pods, error) in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
                self.pods = pods ?? []
                self.constructMenu()
            }
        } else {
            self.constructMenu()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func loadConfig() {
        if let apiKey = UserDefaults.standard.string(forKey: "APIKey") {
            self.sensiboClient = SensiboClient(apiKey: apiKey)
        }
    }
    
    func togglePod(pod: Pod) {
        print("togglePod")
        sensiboClient?.getPodState(podId: pod.id) { (state, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            if let state = state {
                state.on = !state.on
                self.sensiboClient?.setPodState(podId: pod.id, podState: state) { (success, error) in
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                    }
                    print("Success: \(success)")
                }
            }
        }
    }
    
    @objc func selectPod(_ sender: Any?) {
        print("selectPod")
        if let menuItem = sender as? NSMenuItem {
            let pod = pods[Int(menuItem.keyEquivalent)!-1]
            togglePod(pod: pod)
        }
    }
    
    @objc func switchAllOn(_ sender: Any?) {
        print("switchAllOn")
    }
    
    @objc func switchAllOff(_ sender: Any?) {
        print("switchAllOff")
    }
    
    @objc func showPreferences(_ sender: Any?) {
        print("showPreferences")
        if preferencesWindow == nil {
            preferencesWindow = NSStoryboard.init(name: NSStoryboard.Name("Preferences"), bundle: nil).instantiateInitialController() as? NSWindowController
        }
        
        if let window = preferencesWindow {
            window.showWindow(sender)
        }
    }
    
    func constructMenu() {
        let menu = NSMenu()
        
        if pods.count > 0 {
            var count = 0
            for pod in pods {
                count += 1
                menu.addItem(
                    NSMenuItem(
                        title: pod.id,
                        action: #selector(AppDelegate.selectPod(_:)),
                        keyEquivalent: "\(count)"
                    )
                )
            }
        } else {
            menu.addItem(NSMenuItem(title: "No A/C found", action: nil, keyEquivalent: ""))
        }
        
//        menu.addItem(NSMenuItem.separator())
//        menu.addItem(NSMenuItem(title: "All On", action: #selector(AppDelegate.switchAllOn(_:)), keyEquivalent: "o"))
//        menu.addItem(NSMenuItem(title: "All Off", action: #selector(AppDelegate.switchAllOff(_:)), keyEquivalent: "f"))
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Preferences...", action: #selector(AppDelegate.showPreferences(_:)), keyEquivalent: ","))
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
}


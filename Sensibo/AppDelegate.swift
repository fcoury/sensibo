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
        print("togglePod - Pod ID: \(pod.id), Name: \(pod.name())")
        sensiboClient?.getPodState(podId: pod.id) { (state, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            if let state = state {
                state.on = !state.on
                self.sensiboClient?.setPodState(podId: pod.id, podState: state) { (podState, error) in
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                    } else {
                        print("Success: true, Pod State: \(podState.debugDescription)")
                        pod.state = podState
                        self.constructMenu()
                    }
                }
            }
        }
    }
    
    func setFanLevel(pod: Pod, fanLevel: FanLevel) {
        print("setFanLevel - pod: \(pod.name()), fanLevel: \(fanLevel.description)")
        sensiboClient?.getPodState(podId: pod.id) { (state, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            if let state = state {
                state.fanLevel = fanLevel
                self.sensiboClient?.setPodState(podId: pod.id, podState: state) { (podState, error) in
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                    } else {
                        print("Success: true, Pod State: \(podState.debugDescription)")
                        pod.state = podState
                        self.constructMenu()
                    }
                }
            }
        }
    }
    
    func setTemp(pod: Pod, temp: Int) {
        print("setTemp - pod: \(pod.name()), temp: \(temp.description)")
        sensiboClient?.getPodState(podId: pod.id) { (state, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            if let state = state {
                state.targetTemperature = temp
                self.sensiboClient?.setPodState(podId: pod.id, podState: state) { (podState, error) in
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                    } else {
                        print("Success: true, Pod State: \(podState.debugDescription)")
                        pod.state = podState
                        self.constructMenu()
                    }
                }
            }
        }
    }
    
    func setMode(pod: Pod, mode: ACMode) {
        print("setMode - pod: \(pod.name()), mode: \(mode.description)")
        sensiboClient?.getPodState(podId: pod.id) { (state, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            if let state = state {
                state.mode = mode
                self.sensiboClient?.setPodState(podId: pod.id, podState: state) { (podState, error) in
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                    } else {
                        print("Success: true, Pod State: \(podState.debugDescription)")
                        pod.state = podState
                        self.constructMenu()
                    }
                }
            }
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
        let menuGenerator = PodMenuGenerator(delegate: self)
        
        if pods.count > 0 {
            for pod in pods {
                menu.addItem(menuGenerator.menuItem(for: pod))
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

extension AppDelegate: PodMenuDelegate {
    
    @objc func selectPod(_ sender: Any?) {
        print("selectPod")
        guard let sender = sender as? NSMenuItem, let pod = sender.representedObject as? Pod else {
            return
        }
        togglePod(pod: pod)
    }
    
    @objc func fanLevelMenuAction(_ sender: Any?) {
        print("fanLevelMenuAction")
        guard let sender = sender as? NSMenuItem, let fanChange = sender.representedObject as? FanChange else {
            return
        }
        setFanLevel(pod: fanChange.pod, fanLevel: fanChange.fanLevel)
    }
    
    @objc func tempMenuAction(_ sender: Any?) {
        print("tempMenuAction")
        guard let sender = sender as? NSMenuItem, let tempChange = sender.representedObject as? TempChange else {
            return
        }
        setTemp(pod: tempChange.pod, temp: tempChange.temp)
    }
    
    @objc func modeMenuAction(_ sender: Any?) {
        print("modeMenuAction")
        guard let sender = sender as? NSMenuItem, let modeChange = sender.representedObject as? ModeChange else {
            return
        }
        setMode(pod: modeChange.pod, mode: modeChange.mode)
    }
}

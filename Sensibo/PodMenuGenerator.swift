//
//  PodMenuGenerator.swift
//  Sensibo
//
//  Created by Colin Harris on 16/6/19.
//  Copyright © 2019 Colin Harris. All rights reserved.
//

import SensiboClient

@objc protocol PodMenuDelegate: class {
    func selectPod(_ sender: Any?)
    func fanLevelMenuAction(_ sender: Any?)
    func modeMenuAction(_ sender: Any?)
    func tempMenuAction(_ sender: Any?)
}

public struct FanChange {
    var pod: Pod
    var fanLevel: FanLevel
}

public struct ModeChange {
    var pod: Pod
    var mode: ACMode
}

public struct TempChange {
    var pod: Pod
    var temp: Int
}

class PodMenuGenerator {
    
    let delegate: PodMenuDelegate
    
    init(delegate: PodMenuDelegate) {
        self.delegate = delegate
    }
    
    public func menuItem(for pod: Pod) -> NSMenuItem {
        let podMenuItem = NSMenuItem(
            title: pod.name(),
            action: #selector(PodMenuDelegate.selectPod(_:)),
            keyEquivalent: ""
        )
        podMenuItem.representedObject = pod
        podMenuItem.target = self.delegate
        podMenuItem.submenu = subMenu(for: pod)
        return podMenuItem
    }
    
    func subMenu(for pod: Pod) -> NSMenu {
        let menu = NSMenu()
        
        for menuItem in subMenuItems(for: pod) {
            menu.addItem(menuItem)
        }
        
        return menu
    }
    
    func subMenuItems(for pod: Pod) -> [NSMenuItem] {
        let onOffMenuItem = NSMenuItem(title: pod.state?.on ?? false ? "Turn Off" : "Turn On", action: #selector(PodMenuDelegate.selectPod(_:)), keyEquivalent: "")
        onOffMenuItem.representedObject = pod
        onOffMenuItem.target = delegate

        let tempMenuItem = NSMenuItem()
        tempMenuItem.title = "Temp - \(pod.state?.targetTemperature.description ?? "Unknown")"
        tempMenuItem.submenu = tempSubMenu(for: pod)

        let fanMenuItem = NSMenuItem()
        fanMenuItem.title = "Fan - \(pod.state?.fanLevel.description ?? "Unknown")"
        fanMenuItem.submenu = fanSubMenu(for: pod)

        let modeItem = NSMenuItem()
        modeItem.title = "Mode - \(pod.state?.mode.description ?? "Unknown")"
        modeItem.submenu = modeSubMenu(for: pod)
        
        return [tempMenuItem, fanMenuItem, modeItem, onOffMenuItem]
    }
    
    func tempSubMenu(for pod: Pod) -> NSMenu {
        let menu = NSMenu()
        for temp in 16...24 {
            menu.addItem(tempMenuItem(pod: pod, temp: temp))
        }
        return menu
    }
    
    func fanSubMenu(for pod: Pod) -> NSMenu {
        let menu = NSMenu()
        for fanLevel in FanLevel.allCases {
            menu.addItem(fanLevelMenuItem(pod: pod, fanLevel: fanLevel))
        }
        return menu
    }
    
    func modeSubMenu(for pod: Pod) -> NSMenu {
        let menu = NSMenu()
        for mode in ACMode.allCases {
            menu.addItem(modeMenuItem(pod: pod, mode: mode))
        }
        return menu
    }
    
    func tempMenuItem(pod: Pod, temp: Int) -> NSMenuItem {
        let item = NSMenuItem(title: temp.description, action: #selector(PodMenuDelegate.tempMenuAction(_:)), keyEquivalent: "")
        item.target = delegate
        item.representedObject = TempChange(pod: pod, temp: temp)
        item.state = pod.state?.targetTemperature == temp ? .on : .off
        return item
    }

    func fanLevelMenuItem(pod: Pod, fanLevel: FanLevel) -> NSMenuItem {
        let item = NSMenuItem(title: fanLevel.description, action: #selector(PodMenuDelegate.fanLevelMenuAction(_:)), keyEquivalent: "")
        item.target = delegate
        item.representedObject = FanChange(pod: pod, fanLevel: fanLevel)
        item.state = pod.state?.fanLevel == fanLevel ? .on : .off
        return item
    }
    
    func modeMenuItem(pod: Pod, mode: ACMode) -> NSMenuItem {
        let item = NSMenuItem(title: mode.description, action: #selector(PodMenuDelegate.modeMenuAction(_:)), keyEquivalent: "")
        item.target = delegate
        item.representedObject = ModeChange(pod: pod, mode: mode)
        item.state = pod.state?.mode == mode ? .on : .off
        return item
    }
}

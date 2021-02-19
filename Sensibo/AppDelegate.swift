//
//  AppDelegate.swift
//  Sensibo
//
//  Created by Colin Harris on 12/2/19.
//  Copyright © 2019 Colin Harris. All rights reserved.
//

import Cocoa
import HotKey
import SensiboClient

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var sensiboClient: SensiboClient?
    var mainPod: String?
    var pods: [Pod] = []
    var timer: Timer?
    var loading: Bool = false
    var plusHotKey: HotKey? {
        didSet {
            guard let plusHotKey = plusHotKey else { return }
            plusHotKey.keyDownHandler = { [weak self] in
                self?.plusHandler()
            }
        }
    }
    var lessHotKey: HotKey? {
        didSet {
            guard let lessHotKey = lessHotKey else { return }
            lessHotKey.keyDownHandler = { [weak self] in
                self?.lessHandler()
            }
        }
    }
    var plusFanHotKey: HotKey? {
        didSet {
            guard let plusFanHotKey = plusFanHotKey else { return }
            plusFanHotKey.keyDownHandler = { [weak self] in
                self?.plusFanHandler()
            }
        }
    }
    var lessFanHotKey: HotKey? {
        didSet {
            guard let lessFanHotKey = lessFanHotKey else { return }
            lessFanHotKey.keyDownHandler = { [weak self] in
                self?.lessFanHandler()
            }
        }
    }

    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.variableLength)
    var preferencesWindow: NSWindowController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("StatusBarButtonImage"))
            button.title = "..."
            button.imagePosition = NSControl.ImagePosition.imageLeft
        }
        initMenu()
        initHotKey()
        initRefresh()
    }

    func initRefresh() {
        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { (_) in
            print("Refresh \(self.loading)")
            if self.loading { return }
            if let pod = self.getMainPod() {
                self.sensiboClient?.getPodState(podId: pod.id) { (podState, error) in
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                    } else {
                        print("Success: true, Pod State: \(podState.debugDescription)")
                        pod.state = podState
                        self.constructMenu()
                        self.displayMain()
                    }
                }
            }
        }
    }

    func initHotKey() {
        self.lessFanHotKey = HotKey(key: .minus, modifiers: [.command, .option, .control])
        self.plusFanHotKey = HotKey(key: .equal, modifiers: [.command, .option, .control])
        self.lessHotKey = HotKey(key: .minus, modifiers: [.command, .option])
        self.plusHotKey = HotKey(key: .equal, modifiers: [.command, .option])
    }

    func plusHandler() {
        print("Plus \(self.loading)")
        if self.loading { return }
        if let pod = getMainPod() {
            incrTemp(pod: pod, by: 1)
        }
    }

    func lessHandler() {
        print("Less \(self.loading)")
        if self.loading { return }
        if let pod = getMainPod() {
            incrTemp(pod: pod, by: -1)
        }
    }

    func plusFanHandler() {
        print("PlusFan \(self.loading)")
        if self.loading { return }
        if let pod = getMainPod() {
            incrFan(pod: pod, by: 1)
        }
    }

    func lessFanHandler() {
        print("LessFan \(self.loading)")
        if self.loading { return }
        if let pod = getMainPod() {
            incrFan(pod: pod, by: -1)
        }
    }

    func initMenu() {
        loadConfig()

        if let client = sensiboClient {
            client.getPods() { (pods, error) in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
                self.pods = pods ?? []
                self.displayMain()
                self.constructMenu()
            }
        } else {
            self.constructMenu()
        }
    }

    func getMainPod() -> Pod? {
        return self.pods.first(where: { $0.name() == mainPod })
    }

    func displayMain() {
        print("displayMain \(mainPod?.description as String?)")
        if (mainPod != nil) {
            let pod = getMainPod()
            print("Pod: \(pod?.state?.targetTemperature as Int?)")
            if (pod != nil && pod!.state != nil) {
                if let button = statusItem.button {
                    let temp = String(pod!.state!.targetTemperature)
                    let fan = pod!.state!.fanLevel
                    DispatchQueue.main.async {
                        button.contentTintColor = nil
                        button.title = "\(temp)° \(fan)"
                    }
                }
            }
        }
    }

    func displayLoading() {
        self.loading = true
        if let button = statusItem.button {
            if let mutableAttributedTitle = button.attributedTitle.mutableCopy() as? NSMutableAttributedString {
                mutableAttributedTitle.addAttribute(.foregroundColor, value: NSColor.lightGray, range: NSRange(location: 0, length: mutableAttributedTitle.length))
                button.attributedTitle = mutableAttributedTitle
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func loadConfig() {
        if let apiKey = UserDefaults.standard.string(forKey: "APIKey") {
            self.sensiboClient = SensiboClient(apiKey: apiKey)
        }
        if let mainPod = UserDefaults.standard.string(forKey: "MainPod") {
            self.mainPod = mainPod
        }
    }

    func togglePod(pod: Pod) {
        print("togglePod - Pod ID: \(pod.id), Name: \(pod.name())")
        self.displayLoading()
        sensiboClient?.getPodState(podId: pod.id) { (state, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                self.loading = false
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
                        self.displayMain()
                    }
                    self.loading = false
                }
            }
        }
    }

    func setFanLevel(pod: Pod, fanLevel: FanLevel) {
        print("setFanLevel - pod: \(pod.name()), fanLevel: \(fanLevel.description)")
        self.displayLoading()
        sensiboClient?.getPodState(podId: pod.id) { (state, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                self.loading = false
            }
            if let state = state {
                state.fanLevel = fanLevel
                self.sensiboClient?.setPodState(podId: pod.id, podState: state) { (podState, error) in
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                        self.loading = false
                    } else {
                        print("Success: true, Pod State: \(podState.debugDescription)")
                        pod.state = podState
                        self.constructMenu()
                        self.displayMain()
                        self.loading = false
                    }
                }
            }
        }
    }

    func incrTemp(pod: Pod, by: Int) {
        print("incrTemp - pod: \(pod.name()), by: \(by.description)")
        self.displayLoading()
        sensiboClient?.getPodState(podId: pod.id) { (state, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                self.loading = false
            }
            if let state = state {
                state.targetTemperature = state.targetTemperature + by
                print("incrTemp - pod: \(pod.name()), newTemp: \(state.targetTemperature.description)")
                self.sensiboClient?.setPodState(podId: pod.id, podState: state) { (podState, error) in
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                        self.loading = false
                    } else {
                        print("Success: true, Pod State: \(podState.debugDescription)")
                        pod.state = podState
                        self.constructMenu()
                        self.displayMain()
                        self.loading = false
                    }
                }
            }
        }
    }

    func incrFan(pod: Pod, by: Int) {
        let fanValues = [FanLevel.quiet, FanLevel.low, FanLevel.medium, FanLevel.high]
        print("incrTemp - pod: \(pod.name()), by: \(by.description)")
        self.displayLoading()
        sensiboClient?.getPodState(podId: pod.id) { (state, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                self.loading = false
            }
            if let state = state {
                if let curFanLevel = fanValues.firstIndex(where: { $0 == state.fanLevel }) {
                    let maxFanLevel = fanValues.count
                    var nextFanLevel = curFanLevel + by
                    print("nextFanLevel = \(nextFanLevel)")
                    if (nextFanLevel > maxFanLevel - 1) {
                        nextFanLevel = nextFanLevel - maxFanLevel
                    } else if (nextFanLevel < 0) {
                        nextFanLevel = maxFanLevel + nextFanLevel
                    }
                    print("nextFanLevel = \(nextFanLevel)")

                    state.fanLevel = fanValues[nextFanLevel]
                    print("incrFan - pod: \(pod.name()), new level: \(state.fanLevel)")
                    self.sensiboClient?.setPodState(podId: pod.id, podState: state) { (podState, error) in
                        if let error = error {
                            print("Error: \(error.localizedDescription)")
                            self.loading = false
                        } else {
                            print("Success: true, Pod State: \(podState.debugDescription)")
                            pod.state = podState
                            self.constructMenu()
                            self.displayMain()
                            self.loading = false
                        }
                    }
                }
            }
        }
    }
    func setTemp(pod: Pod, temp: Int) {
        print("setTemp - pod: \(pod.name()), temp: \(temp.description)")
        self.displayLoading()
        sensiboClient?.getPodState(podId: pod.id) { (state, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                self.loading = false
            }
            if let state = state {
                state.targetTemperature = temp
                self.sensiboClient?.setPodState(podId: pod.id, podState: state) { (podState, error) in
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                        self.loading = false
                    } else {
                        print("Success: true, Pod State: \(podState.debugDescription)")
                        pod.state = podState
                        self.constructMenu()
                        self.displayMain()
                        self.loading = false
                    }
                }
            }
        }
    }

    func setMode(pod: Pod, mode: ACMode) {
        print("setMode - pod: \(pod.name()), mode: \(mode.description)")
        self.displayLoading()
        sensiboClient?.getPodState(podId: pod.id) { (state, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                        self.loading = false
            }
            if let state = state {
                state.mode = mode
                self.sensiboClient?.setPodState(podId: pod.id, podState: state) { (podState, error) in
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                        self.loading = false
                    } else {
                        print("Success: true, Pod State: \(podState.debugDescription)")
                        pod.state = podState
                        self.constructMenu()
                        self.displayMain()
                        self.loading = false
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
        let mainPod = getMainPod()!
        print("mainPod \(mainPod.name())")

        menu.addItem(NSMenuItem(title: "Main - \(mainPod.name())", action: nil, keyEquivalent: ""))
        let mainPodItems = menuGenerator.subMenuItems(for: mainPod)
        for subMenu in mainPodItems {
            menu.addItem(subMenu)
        }
        menu.addItem(NSMenuItem.separator())

        if pods.count > 1 {
            menu.addItem(NSMenuItem(title: "Others", action: nil, keyEquivalent: ""))
            for pod in pods {
                if (pod.name() != mainPod.name()) {
                    menu.addItem(menuGenerator.menuItem(for: pod))
                }
            }
        } else {
            menu.addItem(NSMenuItem(title: "No A/C found", action: nil, keyEquivalent: ""))
        }

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

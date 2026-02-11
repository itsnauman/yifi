//
//  yifiApp.swift
//  yifi
//
//  Created by Nauman Ahmad on 2/3/26.
//

import SwiftUI

@main
struct yifiApp: App {
    @AppStorage("showMenuBarExtra") private var showMenuBarExtra = true
    @State private var networkMonitor = NetworkMonitor()

    init() {
        UserDefaults.standard.register(defaults: ["showMenuBarExtra": true])
        if UserDefaults.standard.bool(forKey: "showMenuBarExtra") == false {
            UserDefaults.standard.set(true, forKey: "showMenuBarExtra")
        }
        let storedValue = UserDefaults.standard.bool(forKey: "showMenuBarExtra")
        print("yifiApp init, showMenuBarExtra=\(storedValue)")
    }

    var body: some Scene {
        MenuBarExtra("Yifi", systemImage: "stethoscope", isInserted: $showMenuBarExtra) {
            MenuBarView(networkMonitor: networkMonitor)
        }
        .menuBarExtraStyle(.window)
    }
}

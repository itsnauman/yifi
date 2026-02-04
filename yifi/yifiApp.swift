//
//  yifiApp.swift
//  yifi
//
//  Created by Nauman Ahmad on 2/3/26.
//

import SwiftUI

@main
struct yifiApp: App {
    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
        } label: {
            Label("Yifi", systemImage: "wifi")
        }
        .menuBarExtraStyle(.window)
    }
}

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
        MenuBarExtra("Yifi", systemImage: "wifi") {
            MenuBarView()
                .frame(width: 300)
        }
        .menuBarExtraStyle(.window)
    }
}

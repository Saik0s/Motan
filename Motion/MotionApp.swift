//
//  MotionApp.swift
//  Motion
//
//  Created by Igor Tarasenko on 02/08/2022.
//

import SwiftUI

let store = AppStore()

@main
struct MotionApp: App {
    var body: some Scene {
        WindowGroup {
          ContentView(store: store)
        }
    }
}

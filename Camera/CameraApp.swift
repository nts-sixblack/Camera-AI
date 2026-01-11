//
//  CameraApp.swift
//  Camera
//
//  Created by Thanh Sau on 9/1/26.
//

import SwiftUI

@main
struct CameraApp: App {

    init() {
        // Pre-warm camera engine during app launch for faster viewfinder display
        CameraEngine.shared.preWarm()
    }

    var body: some Scene {
        WindowGroup {
            CameraContentView()
        }
    }
}

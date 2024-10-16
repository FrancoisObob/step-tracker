//
//  Step_TrackerApp.swift
//  Step Tracker
//
//  Created by Francois Lambert on 5/20/24.
//

import SwiftUI

@main
struct Step_TrackerApp: App {

    let hkManager = HealthKitManager()

    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environment(hkManager)
        }
    }
}

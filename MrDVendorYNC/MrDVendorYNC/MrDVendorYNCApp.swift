//
//  MrDVendorYNCApp.swift
//  MrDVendorYNC
//
//  Created by Yi-Nain Chen on 2026/09/09.
//

import SwiftUI
import GoogleMaps
import GooglePlaces

@main
struct MrDVendorYNCApp: App {
    init() {
        GMSServices.provideAPIKey(AppConfig.googleAPIKey)
        GMSPlacesClient.provideAPIKey(AppConfig.googleAPIKey)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

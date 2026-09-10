//
//  AppConfig.swift
//  MrDVendorYNC
//

import Foundation

// Central place for the Google API key (shared by both Maps and Places SDKs)
enum AppConfig {
    static var googleAPIKey: String {
        Bundle.main.object(forInfoDictionaryKey: "GoogleAPIKey") as? String ?? ""
    }

    static var hasGoogleAPIKey: Bool {
        !googleAPIKey.isEmpty && googleAPIKey != "YOUR_GOOGLE_MAPS_API_KEY"
    }
}

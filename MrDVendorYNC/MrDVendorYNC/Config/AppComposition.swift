//
//  AppComposition.swift
//  MrDVendorYNC
//
//  Created by Yi-Nain Chen on 2026/09/09.
//

import Foundation

enum AppComposition {
    static let tokenStore: TokenStoring = KeychainTokenStore()
    static var simulateVendorFetchFailure = false

    static func makeVendorService() -> VendorFetching {
        VendorService(tokenStore: tokenStore,
                      useLiveBackend: false,
                      shouldSimulateFailure: { simulateVendorFetchFailure })
// If a real backend existed, flip useLiveBackend to true and pass its baseURL
//        VendorService(baseURL: URL(string: "https://api.example.com")!,
//                      tokenStore: tokenStore,
//                      useLiveBackend: true)
    }

    static func makePlacesService() -> PlaceSearching {
        PlacesService(useLiveBackend: false)
//        Once the GooglePlaces API key is configured, flip this to true to use the real Places SDK
//        PlacesService(useLiveBackend: true)
    }
}

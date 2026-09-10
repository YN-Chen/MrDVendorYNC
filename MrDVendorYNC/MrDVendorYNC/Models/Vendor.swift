//
//  Vendor.swift
//  MrDVendorYNC
//
//  Created by Yi-Nain Chen on 2026/09/09.
//

import CoreLocation

struct VendorListResponse: Codable {
    let vendors: [Vendor]
}

// NOTES:
// Identifiable needed because VendorsScreen puts this into List which needs unique stable id for each row.
struct Vendor: Identifiable, Codable {
    let id: String
    var name: String
    var address: String
    var coordinate: VendorCoordinate?
    var isFavorite: Bool
    var updatedAt: Date
}

struct VendorCoordinate: Codable, Equatable {
    var lat: Double
    var lng: Double

    var clLocationCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
}

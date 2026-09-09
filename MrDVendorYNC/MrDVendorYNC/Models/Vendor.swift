//
//  Vendor.swift
//  MrDVendorYNC
//

import CoreLocation

struct VendorCoordinate: Codable, Equatable, Hashable {
    var lat: Double
    var lng: Double

    var clLocationCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
}

struct Vendor: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var address: String
    var coordinate: VendorCoordinate?
    var isFavorite: Bool
    var updatedAt: Date
}

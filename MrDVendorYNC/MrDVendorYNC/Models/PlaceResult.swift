//
//  PlaceResult.swift
//  MrDVendorYNC
//

import CoreLocation

/// A single result surfaced by `PlaceSearching`, independent of whether it
/// came from the real Google Places SDK or `MockPlacesService`.
struct PlaceResult: Identifiable, Equatable {
    let id: String
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D

    static func == (lhs: PlaceResult, rhs: PlaceResult) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.address == rhs.address &&
        lhs.coordinate.latitude == rhs.coordinate.latitude &&
        lhs.coordinate.longitude == rhs.coordinate.longitude
    }
}

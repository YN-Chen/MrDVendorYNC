//
//  PlaceResult.swift
//  MrDVendorYNC
//
//  Created by Yi-Nain Chen on 2026/09/09.
//

import CoreLocation

// NOTES:
// Identifiable needed because PlaceSearchSheet puts this into ForEach which needs unique stable id for each row.
struct PlaceResult: Identifiable {
    let id: String
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
}

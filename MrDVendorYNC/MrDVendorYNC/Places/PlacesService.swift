//
//  PlacesService.swift
//  MrDVendorYNC
//
//  Created by Yi-Nain Chen on 2026/09/09.
//

import CoreLocation
import GooglePlaces

protocol PlaceSearching {
    func search(query: String) async throws -> [PlaceResult]
}

// NOTES:
// GoogleMaps SDK is in with the implementation, I gated it via useLiveBackend set in AppComposition, due to me
// working with a mock as I don't have a APIKey for it as it requires a credit card details to get APIKey even on free tier and
// I wasn't comfortable setting that up.
final class PlacesService: PlaceSearching {
    private let useLiveBackend: Bool
    private let placesClient = GMSPlacesClient.shared()
    private let sessionToken = GMSAutocompleteSessionToken()

    private let localMockPlacesResults: [PlaceResult] = [
        PlaceResult(id: "place-001",
                    name: "Truth Coffee Roasting",
                    address: "36 Buitenkant St, Cape Town, 8001",
                    coordinate: CLLocationCoordinate2D(latitude: -33.928650, longitude: 18.421890)),
        PlaceResult(id: "place-002",
                    name: "The Test Kitchen",
                    address: "375 Albert Rd, Woodstock, Cape Town, 7925",
                    coordinate: CLLocationCoordinate2D(latitude: -33.927700, longitude: 18.454500)),
        PlaceResult(id: "place-003",
                    name: "Bootlegger Coffee Company",
                    address: "31 Kloof St, Cape Town, 8001",
                    coordinate: CLLocationCoordinate2D(latitude: -33.934200, longitude: 18.406900)),
        PlaceResult(id: "place-004",
                    name: "Harbour House V&A Waterfront",
                    address: "Quay 6, V&A Waterfront, Cape Town, 8001",
                    coordinate: CLLocationCoordinate2D(latitude: -33.905700, longitude: 18.419800)),
        PlaceResult(id: "place-005",
                    name: "Clarke's Bar & Dining Room",
                    address: "133 Bree St, Cape Town, 8001",
                    coordinate: CLLocationCoordinate2D(latitude: -33.918200, longitude: 18.418600))
    ]

    init(useLiveBackend: Bool = false) {
        self.useLiveBackend = useLiveBackend
    }

    func search(query: String) async throws -> [PlaceResult] {
        if useLiveBackend {
            return try await searchGooglePlaces(query: query)
        }
        return try await searchMock(query: query)
    }

    private func searchGooglePlaces(query: String) async throws -> [PlaceResult] {
        let suggestions = try await fetchAutocompleteSuggestions(query: query)

        var results: [PlaceResult] = []
        for suggestion in suggestions {
            guard let placeSuggestion = suggestion.placeSuggestion else { continue }
            if let result = try? await fetchPlaceDetails(placeID: placeSuggestion.placeID) {
                results.append(result)
            }
        }
        return results
    }

    private func fetchAutocompleteSuggestions(query: String) async throws -> [GMSAutocompleteSuggestion] {
        try await withCheckedThrowingContinuation { continuation in
            let request = GMSAutocompleteRequest(query: query)
            request.sessionToken = sessionToken
            placesClient.fetchAutocompleteSuggestions(from: request) { suggestions, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: suggestions ?? [])
            }
        }
    }

    private func fetchPlaceDetails(placeID: String) async throws -> PlaceResult {
        try await withCheckedThrowingContinuation { continuation in
            let properties: [String] = [
                GMSPlaceProperty.name.rawValue,
                GMSPlaceProperty.formattedAddress.rawValue,
                GMSPlaceProperty.coordinate.rawValue,
                GMSPlaceProperty.placeID.rawValue
            ]
            let request = GMSFetchPlaceRequest(placeID: placeID, placeProperties: properties, sessionToken: sessionToken)
            placesClient.fetchPlace(with: request) { place, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let place else {
                    continuation.resume(throwing: AppError.unknown)
                    return
                }
                let result = PlaceResult(id: place.placeID ?? placeID,
                                         name: place.name ?? "Unknown place",
                                         address: place.formattedAddress ?? "",
                                         coordinate: place.coordinate)
                continuation.resume(returning: result)
            }
        }
    }

    private func searchMock(query: String) async throws -> [PlaceResult] {
        try await Task.sleep(nanoseconds: 400_000_000)

        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        return localMockPlacesResults.filter {
            $0.name.localizedCaseInsensitiveContains(trimmed) ||
            $0.address.localizedCaseInsensitiveContains(trimmed)
        }
    }
}

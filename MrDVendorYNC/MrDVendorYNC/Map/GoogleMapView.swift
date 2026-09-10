//
//  GoogleMapView.swift
//  MrDVendorYNC
//
//  Created by Yi-Nain Chen on 2026/09/09.
//

// NOTES:
// GoogleMaps SDK is in with the implementation, I gated it via AppConfig.hasGoogleAPIKey, due to me
// working with a mock view as I don't have a APIKey for it as it requires a credit card details to get APIKey even on free tier and
// I wasn't comfortable setting that up.

import SwiftUI
import CoreLocation
import GoogleMaps

struct GoogleMapView: View {
    var vendors: [Vendor]
    @Binding var selectedVendorID: String?

    var body: some View {
        if AppConfig.hasGoogleAPIKey {
            GoogleMapRepresentable(vendors: vendors, selectedVendorID: $selectedVendorID)
        } else {
            MapUnavailableView()
        }
    }
}

private struct GoogleMapRepresentable: UIViewRepresentable {
    var vendors: [Vendor]
    @Binding var selectedVendorID: String?

    private static let defaultCenter = CLLocationCoordinate2D(latitude: -33.9249, longitude: 18.4241)

    func makeUIView(context: Context) -> GMSMapView {
        let options = GMSMapViewOptions()
        options.camera = GMSCameraPosition.camera(withTarget: Self.defaultCenter, zoom: 12)
        let mapView = GMSMapView(options: options)
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ mapView: GMSMapView, context: Context) {
        mapView.clear()

        var markerByVendorID: [String: GMSMarker] = [:]
        for vendor in vendors {
            guard let coordinate = vendor.coordinate?.clLocationCoordinate else { continue }
            let marker = GMSMarker(position: coordinate)
            marker.title = vendor.name
            marker.snippet = vendor.address
            marker.userData = vendor.id
            marker.map = mapView
            markerByVendorID[vendor.id] = marker
        }

        if let selectedID = selectedVendorID,
           let vendor = vendors.first(where: { $0.id == selectedID }),
           let coordinate = vendor.coordinate?.clLocationCoordinate {
            mapView.animate(to: GMSCameraPosition.camera(withTarget: coordinate, zoom: 15))
            mapView.selectedMarker = markerByVendorID[selectedID]
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(selectedVendorID: $selectedVendorID)
    }

    final class Coordinator: NSObject, GMSMapViewDelegate {
        @Binding var selectedVendorID: String?

        init(selectedVendorID: Binding<String?>) {
            _selectedVendorID = selectedVendorID
        }

        func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            selectedVendorID = marker.userData as? String
            return false
        }
    }
}

private struct MapUnavailableView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "map")
                .font(.system(size: 32))
                .foregroundStyle(.secondary)
            Text("Map unavailable")
                .font(.headline)
            Text("Add a real Google API key (GoogleAPIKey in GoogleAPIConfig.plist) to enable the live map.")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .secondarySystemBackground))
    }
}

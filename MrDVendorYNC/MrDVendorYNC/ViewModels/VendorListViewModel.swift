//
//  VendorListViewModel.swift
//  MrDVendorYNC
//
//  Created by Yi-Nain Chen on 2026/09/09.
//

import Combine
import CoreLocation
import Foundation

@MainActor
final class VendorListViewModel: ObservableObject {
    @Published private(set) var vendors: [Vendor] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedVendorID: String?

    private let vendorService: VendorFetching

    init(vendorService: VendorFetching = AppComposition.makeVendorService()) {
        self.vendorService = vendorService
    }

    func loadIfNeeded() async {
        guard vendors.isEmpty else { return }
        await load()
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            vendors = try await vendorService.fetchVendors()
        } catch {
            errorMessage = (error as? AppError)?.errorDescription ?? AppError.unknown.errorDescription
        }
        isLoading = false
    }

    func toggleFavorite(_ vendor: Vendor) {
        guard let index = vendors.firstIndex(where: { $0.id == vendor.id }) else { return }
        vendors[index].isFavorite.toggle()
    }

    func select(_ vendor: Vendor) {
        selectedVendorID = vendor.id
    }

    func addVendor(from place: PlaceResult) {
        let vendor = Vendor(id: "place-\(place.id)",
                            name: place.name,
                            address: place.address,
                            coordinate: VendorCoordinate(lat: place.coordinate.latitude, lng: place.coordinate.longitude),
                            isFavorite: false,
                            updatedAt: Date())
        guard !vendors.contains(where: { $0.id == vendor.id }) else { return }
        vendors.append(vendor)
        selectedVendorID = vendor.id
    }
}

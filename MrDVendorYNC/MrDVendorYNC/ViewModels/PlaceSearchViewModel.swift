//
//  PlaceSearchViewModel.swift
//  MrDVendorYNC
//
//  Created by Yi-Nain Chen on 2026/09/09.
//

import Combine
import Foundation

@MainActor
final class PlaceSearchViewModel: ObservableObject {
    @Published var query = ""
    @Published private(set) var results: [PlaceResult] = []
    @Published private(set) var isSearching = false
    @Published var errorMessage: String?

    private let placesService: PlaceSearching
    private var searchTask: Task<Void, Never>?

    init(placesService: PlaceSearching = AppComposition.makePlacesService()) {
        self.placesService = placesService
    }

    func queryChanged() {
        searchTask?.cancel()
        let currentQuery = query
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 250_000_000)
            guard !Task.isCancelled else { return }
            await performSearch(query: currentQuery)
        }
    }

    private func performSearch(query: String) async {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            results = []
            errorMessage = nil
            return
        }
        isSearching = true
        errorMessage = nil
        do {
            results = try await placesService.search(query: query)
        } catch {
            errorMessage = (error as? AppError)?.errorDescription ?? AppError.unknown.errorDescription
        }
        isSearching = false
    }
}

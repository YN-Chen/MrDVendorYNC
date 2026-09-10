//
//  SettingsViewModel.swift
//  MrDVendorYNC
//
//  Created by Yi-Nain Chen on 2026/09/09.
//

import Combine
import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var tokenInput = ""
    @Published private(set) var storedToken: String?
    @Published var errorMessage: String?
    @Published var simulateVendorFetchFailure = AppComposition.simulateVendorFetchFailure

    private let tokenStore: TokenStoring

    init(tokenStore: TokenStoring = AppComposition.tokenStore) {
        self.tokenStore = tokenStore
        refresh()
    }

    var hasStoredToken: Bool { storedToken != nil }

    func refresh() {
        do {
            storedToken = try tokenStore.loadToken()
            errorMessage = nil
        } catch {
            errorMessage = (error as? AppError)?.errorDescription ?? AppError.unknown.errorDescription
        }
    }

    func save() {
        let trimmed = tokenInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        do {
            try tokenStore.save(trimmed)
            tokenInput = ""
            refresh()
        } catch {
            errorMessage = (error as? AppError)?.errorDescription ?? AppError.unknown.errorDescription
        }
    }

    func clear() {
        do {
            try tokenStore.clearToken()
            refresh()
        } catch {
            errorMessage = (error as? AppError)?.errorDescription ?? AppError.unknown.errorDescription
        }
    }

    func toggleSimulateFailure(_ isOn: Bool) {
        simulateVendorFetchFailure = isOn
        AppComposition.simulateVendorFetchFailure = isOn
    }
}

//
//  VendorService.swift
//  MrDVendorYNC
//
//  Created by Yi-Nain Chen on 2026/09/09.
//

import Foundation

protocol VendorFetching {
    func fetchVendors() async throws -> [Vendor]
}

// NOTES:
// Implementation has for local hardcoded version as well as if there was a real backend, flipped on and off based on the useLiveBackend BOOL that gets set in AppComposition
final class VendorService: VendorFetching {
    private let baseURL: URL
    private let urlSession: URLSession
    private let tokenStore: TokenStoring
    private let useLiveBackend: Bool
    private let fileName: String
    private let simulatedLatencyNanoseconds: UInt64
    private let shouldSimulateFailure: () -> Bool

    init(baseURL: URL = URL(string: "https://api.example.com")!,
         urlSession: URLSession = .shared,
         tokenStore: TokenStoring = AppComposition.tokenStore,
         useLiveBackend: Bool = false,
         fileName: String = "vendors",
         simulatedLatencyNanoseconds: UInt64 = 500_000_000,
         shouldSimulateFailure: @escaping () -> Bool = { false }) {
        self.baseURL = baseURL
        self.urlSession = urlSession
        self.tokenStore = tokenStore
        self.useLiveBackend = useLiveBackend
        self.fileName = fileName
        self.simulatedLatencyNanoseconds = simulatedLatencyNanoseconds
        self.shouldSimulateFailure = shouldSimulateFailure
    }

    func fetchVendors() async throws -> [Vendor] {
        if useLiveBackend {
            return try await fetchFromNetwork()
        } else {
            return try await fetchFromBundledJSON()
        }
    }

    private func fetchFromBundledJSON() async throws -> [Vendor] {
        try await Task.sleep(nanoseconds: simulatedLatencyNanoseconds)

        if shouldSimulateFailure() {
            throw AppError.offline
        }

        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            throw AppError.decoding
        }
        let data = try Data(contentsOf: url)
        return try Self.decodeVendors(from: data)
    }

    private func fetchFromNetwork() async throws -> [Vendor] {
        var request = URLRequest(url: baseURL.appendingPathComponent("v1/vendors"))
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = try? tokenStore.loadToken(), !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await urlSession.data(for: request)
        } catch {
            throw AppError.offline
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError.unknown
        }
        switch httpResponse.statusCode {
        case 200..<300:
            return try Self.decodeVendors(from: data)
        case 401:
            throw AppError.unauthorized
        default:
            throw AppError.server(status: httpResponse.statusCode)
        }
    }

    static func decodeVendors(from data: Data) throws -> [Vendor] {
        do {
            return try makeDecoder().decode(VendorListResponse.self, from: data).vendors
        } catch {
            throw AppError.decoding
        }
    }

    private static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}

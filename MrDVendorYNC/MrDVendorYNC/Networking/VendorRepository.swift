//
//  VendorRepository.swift
//  MrDVendorYNC
//

import Foundation

/// Abstraction over "where vendors come from". Swapping the concrete type
/// injected into `VendorListViewModel` is the only thing needed to move
/// between the bundled mock JSON and a real REST backend.
protocol VendorRepository {
    func fetchVendors() async throws -> [Vendor]
}

/// The REST JSON envelope this app expects from `GET /v1/vendors`:
///
/// ```json
/// { "vendors": [ { "id": "ven-001", "name": "...", "address": "...",
///                  "coordinate": { "lat": -33.9, "lng": 18.4 },
///                  "isFavorite": false, "updatedAt": "2025-06-01T12:00:00Z" } ] }
/// ```
///
/// Both `LocalJSONVendorRepository` and `RemoteVendorRepository` decode this
/// same shape, so the parsing logic is exercised identically whether the
/// bytes came from a bundled file or the network.
struct VendorListResponse: Codable {
    let vendors: [Vendor]
}

enum VendorJSONDecoding {
    static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    static func decodeVendors(from data: Data) throws -> [Vendor] {
        do {
            return try makeDecoder().decode(VendorListResponse.self, from: data).vendors
        } catch {
            throw AppError.decoding
        }
    }
}

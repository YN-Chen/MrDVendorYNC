//
//  MrDVendorYNCTests.swift
//  MrDVendorYNCTests
//
//  Created by Yi-Nain Chen on 2026/09/09.
//

import XCTest
@testable import MrDVendorYNC

final class VendorServiceTests: XCTestCase {

    func testDecodeVendorsParsesFieldsIncludingOptionalCoordinate() throws {
        let json = """
        {
          "vendors": [
            {
              "id": "ven-001",
              "name": "Mr D Pizza — Cape Town CBD",
              "address": "12 Loop St, Cape Town, 8000",
              "coordinate": { "lat": -33.918861, "lng": 18.423300 },
              "isFavorite": false,
              "updatedAt": "2025-06-01T12:00:00Z"
            },
            {
              "id": "ven-005",
              "name": "Observatory Coffee Roasters",
              "address": "9 Lower Main Rd, Observatory, Cape Town, 7925",
              "coordinate": null,
              "isFavorite": false,
              "updatedAt": "2025-06-05T08:00:00Z"
            }
          ]
        }
        """
        let data = Data(json.utf8)

        let vendors = try VendorService.decodeVendors(from: data)

        XCTAssertEqual(vendors.count, 2)

        let pizza = try XCTUnwrap(vendors.first { $0.id == "ven-001" })
        XCTAssertEqual(pizza.name, "Mr D Pizza — Cape Town CBD")
        XCTAssertEqual(pizza.address, "12 Loop St, Cape Town, 8000")
        XCTAssertEqual(pizza.isFavorite, false)
        XCTAssertEqual(pizza.coordinate, VendorCoordinate(lat: -33.918861, lng: 18.423300))

        let noCoordinateVendor = try XCTUnwrap(vendors.first { $0.id == "ven-005" })
        XCTAssertNil(noCoordinateVendor.coordinate)
    }

    func testDecodeVendorsThrowsDecodingErrorForMalformedJSON() {
        let malformedJSON = Data("{ \"vendors\": [ { \"id\": 42 } ] }".utf8)

        XCTAssertThrowsError(try VendorService.decodeVendors(from: malformedJSON)) { error in
            XCTAssertEqual(error as? AppError, .decoding)
        }
    }
}

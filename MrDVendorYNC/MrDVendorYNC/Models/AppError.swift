//
//  AppError.swift
//  MrDVendorYNC
//
//  Created by Yi-Nain Chen on 2026/09/09.
//

import Foundation

// NOTES:
// Central unified error type for the whole Vendor app so that the facing UI layer on needs the errorDescription to throw just that.
enum AppError: LocalizedError, Equatable {
    case offline
    case server(status: Int)
    case decoding
    case unauthorized
    case keychain(OSStatus)
    case unknown

    var errorDescription: String? {
        switch self {
        case .offline:
            return "You appear to be offline. Check your connection and try again."
        case .server(let status):
            return "The server returned an error (status \(status)). Please try again."
        case .decoding:
            return "We couldn't read the vendor data. Please try again later."
        case .unauthorized:
            return "Your session token is missing or invalid. Add one in Settings."
        case .keychain(let status):
            return "Couldn't access secure storage (code \(status))."
        case .unknown:
            return "Something went wrong. Please try again."
        }
    }
}

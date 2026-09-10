//
//  KeychainTokenStore.swift
//  MrDVendorYNC
//
//  Created by Yi-Nain Chen on 2026/09/09.
//

import Foundation
import Security

protocol TokenStoring {
    func save(_ token: String) throws
    func loadToken() throws -> String?
    func clearToken() throws
}

final class KeychainTokenStore: TokenStoring {
    private let service: String
    private let account = "sessionToken"

    init(service: String = Bundle.main.bundleIdentifier ?? "MrDVendorYNC") {
        self.service = service
    }

    func save(_ token: String) throws {
        let data = Data(token.utf8)

        if try loadToken() != nil {
            let status = SecItemUpdate(baseQuery() as CFDictionary,
                                       [kSecValueData as String: data] as CFDictionary)
            guard status == errSecSuccess else { throw AppError.keychain(status) }
        } else {
            var addQuery = baseQuery()
            addQuery[kSecValueData as String] = data
            addQuery[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
            let status = SecItemAdd(addQuery as CFDictionary, nil)
            guard status == errSecSuccess else { throw AppError.keychain(status) }
        }
    }

    func loadToken() throws -> String? {
        var query = baseQuery()
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            guard let data = result as? Data, let token = String(data: data, encoding: .utf8) else { return nil }
            return token
        case errSecItemNotFound:
            return nil
        default:
            throw AppError.keychain(status)
        }
    }

    func clearToken() throws {
        let status = SecItemDelete(baseQuery() as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw AppError.keychain(status) }
    }

    private func baseQuery() -> [String: Any] {
        return [kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account]
    }
}

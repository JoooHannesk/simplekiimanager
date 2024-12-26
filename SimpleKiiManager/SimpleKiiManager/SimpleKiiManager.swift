//
//  SimpleKiiManager.swift
//  SimpleKiiManager
//
//  Created by Johannes Kinzig on 22.12.24.
//

import Foundation
import Security

/**
 Provide a simple interface to access keychain functionality on macOS, iOS and visionOS
 */
public class SimpleKiiManagerSt {
    static let shared: SimpleKiiManagerSt = {
        let skiiManager = SimpleKiiManagerSt()
        return skiiManager
    }()

    public init() {}

    // MARK: - Public methods

    /**
     Add a secret to secure storage (keychain)

     - Parameter serviceName: Secret's (service/entry) name, e.g. item name.
     - Parameter accountName: Secret's account, e.g. username, profile name. Optional, default: nil
     - Parameter secretValue: The actual secret, e.g. password, passphrase, pin, token, etc.
     - Parameter comment: Comment for entry. Optional, default: nil
     - Parameter secretKind: The secret's kind, default is set to `.genericPassword`. Refer to ``SecretKind``.
     - Parameter accessibilityMode: Specifies the items accessibility mode, default is set to `.whenUnlocked`. Refer to ``SecretAccessibilityMode``.
     - Parameter cloudSynchronization: When set, secret is added to iCloud keychain instead of local keychain. Default: false
     - Throws: An error of type ``KiiManagerError``.
     - Note: This library assumes that `serviceName` is always given when adding a new entry to the keychain.
     */
    public func addSecret(
        serviceName: String,
        accountName: String? = nil,
        secretValue: String,
        comment: String? = nil,
        secretKind: SecretKind = .genericPassword,
        accessibilityMode: SecretAccessibilityMode = .whenUnlocked,
        cloudSynchronization: Bool = false
    )
        throws(KiiManagerError)
    {
        let addSecretQuery =
            [
                kSecAttrService as String: serviceName,
                kSecAttrAccount as String: accountName ?? "",
                kSecAttrComment as String: comment ?? "",
                kSecValueData as String: secretValue.data(using: .utf8)!,
                kSecClass as String: secretKind.specifiedKind,
                kSecAttrAccessible as String: accessibilityMode.specifiedMode,
                kSecAttrSynchronizable as String: cloudSynchronization,
            ] as CFDictionary

        let result = SecItemAdd(addSecretQuery, nil)

        if result == errSecMissingEntitlement {
            throw KiiManagerError.securityEntitlementError("Check required entitlements and code signing settings!")
        } else if result == errSecDuplicateItem {
            throw KiiManagerError.entryAlreadyExists("Entry already exists. Use 'updateSecret' instead.")
        } else if result != errSecSuccess {
            throw KiiManagerError.genericError(result)
        }
    }

    /**
     Retrieve secret from secure storage (keychain)

     - Parameter serviceName: Secret's (service/entry) name, e.g. item name.
     - Parameter accountName: Secret's account, e.g. username, profile name.
     - Parameter secretKind: The secret's kind, default is set to `.genericPassword`. Refer to ``SecretKind``.
     - Returns: The requested secret as String.
     - Throws: An error of type ``KiiManagerError``
     - Note: Entries can be retrieved from keychain using either `serviceName` or `accountName` (or both).
     */
    public func getSecret(
        serviceName: String? = nil, accountName: String? = nil, secretKind: SecretKind = .genericPassword
    ) throws(KiiManagerError) -> KiiSecret {
        
        guard !(serviceName == nil && accountName == nil) else {
            throw KiiManagerError.invalidIdentifier("Both 'serviceName' and 'accountName' cannot be nil")
        }
        
        var getSecretQuery =
            [
                kSecReturnData as String: true,
                kSecReturnAttributes as String: true,
                kSecClass as String: secretKind.specifiedKind,
                kSecMatchLimit as String: kSecMatchLimitOne,
            ] as [String: Any]
        
        if let serviceName = serviceName {
            getSecretQuery[kSecAttrService as String] = serviceName
        }
        if let accountName {
            getSecretQuery[kSecAttrAccount as String] = accountName
        }

        var secretDataTypeRef: CFTypeRef?
        let result = SecItemCopyMatching(getSecretQuery as CFDictionary, &secretDataTypeRef)

        if result == errSecItemNotFound {
            throw KiiManagerError.entryNotFound("Requested secret not found")
        } else if result != errSecSuccess {
            throw KiiManagerError.genericError(result)
        }
        
        guard let secretData = secretDataTypeRef as? [String: Any?] else {
            throw KiiManagerError.dataFormatMissmatch
        }
        
        if let serviceName = secretData["svce"] as? String,
           let secretValueData = secretData[kSecValueData as String] as? Data,
           let secretValue = String(data: secretValueData, encoding: .utf8),
           let creationDate = secretData["cdat"] as? Date,
           let modificationDate = secretData["mdat"] as? Date {
            let secret = KiiSecret(
                serviceName: serviceName,
                accountName: secretData["acct", default: nil] as? String,
                secretValue: secretValue,
                secretKind: secretKind,
                comment: secretData["icmt", default: nil] as? String,
                creationDate: creationDate,
                modificationDate: modificationDate
            )
            return secret
        }
        else {
            throw KiiManagerError.entryIsMissingElements
        }
    }

    public func updateSecret() {}

    private func removeSecret() {}

}

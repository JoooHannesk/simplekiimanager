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
     
     - Parameter labelName: Secret's label name.
     - Parameter serviceName: Secret's service name. **Optional, default: nil**
     - Parameter accountName: Secret's account, e.g. username, profile name. **Optional, default: nil**
     - Parameter secretValue: The actual secret, e.g. password, passphrase, pin, token, etc.
     - Parameter comment: Comment for entry. **Optional, default: nil**
     - Parameter secretKind: The secret's kind, default is set to `.genericPassword`. Refer to ``SecretKind``.
     - Parameter accessibilityMode: Specifies the items accessibility mode, default is set to `.whenUnlocked`. Refer to ``SecretAccessibilityMode``.
     - Parameter cloudSynchronization: When set, secret is added to iCloud keychain instead of local keychain. Default: false
     - Throws: An error of type ``KiiManagerError``.
     - Note: This library assumes that `labelName` is always given when adding a new entry to the keychain.
     */
    public func addSecret(
        labelName: String,
        serviceName: String? = nil,
        accountName: String? = nil,
        secretValue: String,
        comment: String? = nil,
        secretKind: SecretKind = .genericPassword,
        accessibilityMode: SecretAccessibilityMode = .whenUnlocked,
        cloudSynchronization: Bool = false
    )
        throws(KiiManagerError)
    {
        var addSecretQuery: Dictionary<String, Any> = [
            kSecAttrLabel as String: labelName,
            kSecValueData as String: secretValue.data(using: .utf8)!,
            kSecClass as String: secretKind.specifiedKind,
            kSecAttrAccessible as String: accessibilityMode.specifiedMode,
            kSecAttrSynchronizable as String: cloudSynchronization,
            ]
        
        if let serviceName = serviceName {
            addSecretQuery[kSecAttrService as String] = serviceName
        }
        if let accountName = accountName {
            addSecretQuery[kSecAttrAccount as String] = accountName
        }
        if let comment = comment {
            addSecretQuery[kSecAttrComment as String] = comment
        }

        let result = SecItemAdd(addSecretQuery as CFDictionary, nil)

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

     - Parameter labelName: Secret's label name. **Optional, default: nil**
     - Parameter serviceName: Secret's (service/entry) name, e.g. item name. **Optional, default: nil**
     - Parameter accountName: Secret's account, e.g. username, profile name. **Optional, default: nil**
     - Parameter secretKind: The secret's kind, default is set to `.genericPassword`. Refer to ``SecretKind``.
     - Returns: The requested etntry as ``KiiSecret``
     - Throws: An error of type ``KiiManagerError``
     */
    public func getSecret(labelName: String? = nil, serviceName: String? = nil, accountName: String? = nil,
                          secretKind: SecretKind = .genericPassword) throws(KiiManagerError) -> KiiSecret {
        
        guard !(labelName == nil && serviceName == nil && accountName == nil) else {
            throw KiiManagerError.invalidIdentifier("'labelName', 'serviceName' and 'accountName' cannot be nil all at once!")
        }
        
        var getSecretQuery: Dictionary<String, Any> = [
                kSecReturnData as String: true,
                kSecReturnAttributes as String: true,
                kSecClass as String: secretKind.specifiedKind,
                kSecMatchLimit as String: kSecMatchLimitOne,
            ]
        
        if let labelName = labelName {
            getSecretQuery[kSecAttrLabel as String] = labelName
        }
        if let serviceName = serviceName {
            getSecretQuery[kSecAttrService as String] = serviceName
        }
        if let accountName = accountName {
            getSecretQuery[kSecAttrAccount as String] = accountName
        }

        var secretDataTypeRef: CFTypeRef?
        let result = SecItemCopyMatching(getSecretQuery as CFDictionary, &secretDataTypeRef)

        if result == errSecItemNotFound {
            throw KiiManagerError.entryNotFound("Requested secret not found")
        } else if result != errSecSuccess {
            throw KiiManagerError.genericError(result)
        }
        
        guard let secretData = secretDataTypeRef as? Dictionary<String, Any?> else {
            throw KiiManagerError.dataFormatMissmatch
        }

        if let lableName = secretData["labl"] as? String,
           let secretValueData = secretData[kSecValueData as String] as? Data,
           let secretValue = String(data: secretValueData, encoding: .utf8),
           let creationDate = secretData["cdat"] as? Date,
           let modificationDate = secretData["mdat"] as? Date {
            let secret = KiiSecret(
                labelName: lableName,
                serviceName: secretData["svce", default: nil] as? String,
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

    /**
     Update entry properties for secret entry
     
     - Parameter labelName: Secret's label name.
     - Parameter serviceName: Secret's (service/entry) name, e.g. item name. **Optional, default: nil**
     - Parameter accountName: Secret's account, e.g. username, profile name. **Optional, default: nil**
     - Parameter secretKind: The secret's kind, default is set to `.genericPassword`. Refer to ``SecretKind``.
     - Parameter newLabelName: New label name. **Optional, default: nil**
     - Parameter newServiceName: New service name. **Optional, default: nil**
     - Parameter newAccountName: New account name. **Optional, default: nil**
     - Parameter newSecret: New secret. **Optional, default: nil**
     - Parameter newComment: New comment. **Optional, default: nil**
     - Throws: An error of type ``KiiManagerError``.
     */
    public func updateSecret(labelName: String,
                             serviceName: String? = nil, accountName: String? = nil, secretKind: SecretKind = .genericPassword,
                             newLabelName: String? = nil, newServiceName: String? = nil, newAccountName: String? = nil, newSecret: String? = nil, newComment: String? = nil)
    throws(KiiManagerError) {
        
        // find entry in keychain which will be updated
        var searchEntryQuery: Dictionary<String, Any> = [
            kSecAttrLabel as String: labelName,
            kSecClass as String: secretKind.specifiedKind
        ]
        
        // modify query depeding on given parameters/arguments
        if let serviceName = serviceName {
            searchEntryQuery[kSecAttrService as String] = serviceName
        }
        if let accountName = accountName {
            searchEntryQuery[kSecAttrAccount as String] = accountName
        }
        
        // define query to update entry
        var updateEntryQuery: Dictionary<String, Any> = [:]
        
        if let newLabelName = newLabelName {
            updateEntryQuery[kSecAttrLabel as String] = newLabelName
        }
        if let newServiceName = newServiceName {
            updateEntryQuery[kSecAttrService as String] = newServiceName
        }
        if let newAccountName = newAccountName {
            updateEntryQuery[kSecAttrAccount as String] = newAccountName
        }
        if let newSecret = newSecret {
            updateEntryQuery[kSecValueData as String] = newSecret.data(using: .utf8)!
        }
        if let newComment = newComment {
            updateEntryQuery[kSecAttrComment as String] = newComment
        }
        
        // update entry
        let result = SecItemUpdate(searchEntryQuery as CFDictionary, updateEntryQuery as CFDictionary)
        
        if result == errSecItemNotFound {
            throw KiiManagerError.entryNotFound("Entry not found for given service and account name!")
        } else if result != errSecSuccess {
            throw KiiManagerError.genericError(result)
        }
    }

    /**
     Remove secret from secure storage (keychain).
     
     - Parameter labelName: Secret's label name.
     - Parameter serviceName: Secret's service name. **Optional, default: nil**
     - Parameter accountName: Secret's account, e.g. username, profile name. **Optional, default: nil**
     - Parameter secretKind: The secret's kind, default is set to `.genericPassword`. Refer to ``SecretKind``.
     - Throws: An error of type ``KiiManagerError``.
     - Note: This library assumes that `labelName` is always given when adding a new entry to the keychain.
     */
    public func removeSecret(labelName: String, serviceName: String? = nil, accountName: String? = nil, secretKind: SecretKind = .genericPassword) throws(KiiManagerError) {
        // find entry in keychain which will be deleted
        var deleteQuery: Dictionary<String, Any> = [
            kSecAttrLabel as String: labelName,
            kSecClass as String: secretKind.specifiedKind
        ]
        
        if let serviceName = serviceName {
            deleteQuery[kSecAttrService as String] = serviceName
        }
        if let accountName = accountName {
            deleteQuery[kSecAttrAccount as String] = accountName
        }
        
        // delete entry
        let result = SecItemDelete(deleteQuery as CFDictionary)
        
        if result == errSecItemNotFound {
            throw KiiManagerError.entryNotFound("Entry not found for given service and account name!")
        } else if result != errSecSuccess {
            throw KiiManagerError.genericError(result)
        }
    }
}

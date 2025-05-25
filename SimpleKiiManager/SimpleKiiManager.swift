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
    public static let shared: SimpleKiiManagerSt = {
        let skiiManager = SimpleKiiManagerSt()
        return skiiManager
    }()

    public init() {}

    // MARK: - Public methods

    /**
     Add a secret to secure storage (keychain)
     
     - Parameter accountName: Secret's account, e.g. username, profile name.
     - Parameter labelName: Secret's label name. **Optional, default: nil**
     - Parameter serviceName: Secret's service name. **Optional, default: nil**
     - Parameter secretValue: The actual secret, e.g. password, passphrase, pin, token, etc.
     - Parameter comment: Description or comment for entry. **Optional, default: nil**
     - Parameter secretKind: The secret's kind, default is set to `.genericPassword`. Refer to ``SecretKind``.
     - Parameter accessibilityMode: Specifies the items accessibility mode, default is set to `.whenUnlocked`. Refer to ``SecretAccessibilityMode``.
     - Parameter cloudSynchronization: When set, secret is added to iCloud keychain instead of local keychain. **Default: false**
     - Throws: An error of type ``KiiManagerError``.
     - Note: This library assumes that `accountName` is always given when adding a new entry to the keychain.
     */
    public func addSecret(
        accountName: String,
        labelName: String? = nil,
        serviceName: String? = nil,
        secretValue: String,
        comment: String? = nil,
        secretKind: SecretKind = .genericPassword,
        accessibilityMode: SecretAccessibilityMode = .whenUnlocked,
        cloudSynchronization: Bool = false
    )
        throws(KiiManagerError)
    {
        var addSecretQuery: Dictionary<String, Any> = [
            kSecAttrAccount as String: accountName,
            kSecValueData as String: secretValue.data(using: .utf8)!,
            kSecClass as String: secretKind.specifiedKind,
            kSecAttrAccessible as String: accessibilityMode.specifiedMode,
            kSecAttrSynchronizable as String: cloudSynchronization,
            ]
        
        if let labelName = labelName {
            addSecretQuery[kSecAttrLabel as String] = labelName
        }
        if let serviceName = serviceName {
            addSecretQuery[kSecAttrService as String] = serviceName
        }
        if let comment = comment {
            addSecretQuery[kSecAttrComment as String] = comment
        }

        let result = SecItemAdd(addSecretQuery as CFDictionary, nil)
        
        try throwErrorFor(result)
    }

    /**
     Retrieve secret from secure storage (keychain)

     - Parameter accountName: Secret's account, e.g. username, profile name. **Optional, default: nil**
     - Parameter labelName: Secret's label name. **Optional, default: nil**
     - Parameter serviceName: Secret's (service/entry) name, e.g. item name. **Optional, default: nil**
     - Parameter secretKind: The secret's kind, default is set to `.genericPassword`. Refer to ``SecretKind``.
     - Returns: The requested etntry as ``KiiSecret``
     - Throws: An error of type ``KiiManagerError``
     */
    public func getSecret(accountName: String? = nil, labelName: String? = nil, serviceName: String? = nil,
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
        
        if let accountName = accountName {
            getSecretQuery[kSecAttrAccount as String] = accountName
        }
        if let labelName = labelName {
            getSecretQuery[kSecAttrLabel as String] = labelName
        }
        if let serviceName = serviceName {
            getSecretQuery[kSecAttrService as String] = serviceName
        }

        var secretDataTypeRef: CFTypeRef?
        let result = SecItemCopyMatching(getSecretQuery as CFDictionary, &secretDataTypeRef)
        
        try throwErrorFor(result)
        
        guard let secretData = secretDataTypeRef as? Dictionary<String, Any?> else {
            throw KiiManagerError.dataFormatMissmatch
        }

        if let accountName = secretData["acct", default: nil] as? String,
           let secretValueData = secretData[kSecValueData as String] as? Data,
           let secretValue = String(data: secretValueData, encoding: .utf8),
           let creationDate = secretData["cdat"] as? Date,
           let modificationDate = secretData["mdat"] as? Date {
            let secret = KiiSecret(
                accountName: accountName,
                labelName: secretData["labl"] as? String,
                serviceName: secretData["svce", default: nil] as? String,
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
     
     - Parameter accountName: Secret's account, e.g. username, profile name.
     - Parameter labelName: Secret's label name. **Optional, default: nil**
     - Parameter serviceName: Secret's (service/entry) name, e.g. item name. **Optional, default: nil**
     - Parameter secretKind: The secret's kind, default is set to `.genericPassword`. Refer to ``SecretKind``.
     - Parameter newLabelName: New label name. **Optional, default: nil**
     - Parameter newServiceName: New service name. **Optional, default: nil**
     - Parameter newAccountName: New account name. **Optional, default: nil**
     - Parameter newSecretValue: New secret. **Optional, default: nil**
     - Parameter newComment: New comment. **Optional, default: nil**
     - Throws: An error of type ``KiiManagerError``.
     */
    public func updateSecret(accountName: String, labelName: String? = nil, serviceName: String? = nil, secretKind: SecretKind = .genericPassword,
                             newLabelName: String? = nil, newServiceName: String? = nil, newAccountName: String? = nil, newSecretValue: String? = nil, newComment: String? = nil)
    throws(KiiManagerError) {
        
        // find entry in keychain which will be updated
        var searchEntryQuery: Dictionary<String, Any> = [
            kSecAttrAccount as String: accountName,
            kSecClass as String: secretKind.specifiedKind
        ]
        
        // modify query depeding on given parameters/arguments
        if let labelName = labelName {
            searchEntryQuery[kSecAttrLabel as String] = labelName
        }
        if let serviceName = serviceName {
            searchEntryQuery[kSecAttrService as String] = serviceName
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
        if let newSecret = newSecretValue {
            updateEntryQuery[kSecValueData as String] = newSecret.data(using: .utf8)!
        }
        if let newComment = newComment {
            updateEntryQuery[kSecAttrComment as String] = newComment
        }
        
        // update entry
        let result = SecItemUpdate(searchEntryQuery as CFDictionary, updateEntryQuery as CFDictionary)
        
        try throwErrorFor(result)
    }
    
    
    /**
     Add or update an element in keychain
     
     Add a new element to keychain or update its secret vlaue in case it already exists. This methods supports updating the elements **secret value only**. When required to update other element properties (e.g. serviceName, labelName) use ``SimpleKiiManagerSt/updateSecret(accountName:labelName:serviceName:secretKind:newLabelName:newServiceName:newAccountName:newSecretValue:newComment:)``.
     
     - Parameter accountName: Secret's account, e.g. username, profile name.
     - Parameter labelName: Secret's label name. **Optional, default: nil**
     - Parameter serviceName: Secret's service name. **Optional, default: nil**
     - Parameter secretValue: The actual secret, e.g. password, passphrase, pin, token, etc.
     - Parameter comment: Comment for entry. **Optional, default: nil**
     - Parameter secretKind: The secret's kind, default is set to `.genericPassword`. Refer to ``SecretKind``.
     - Parameter accessibilityMode: Specifies the items accessibility mode, default is set to `.whenUnlocked`. Refer to ``SecretAccessibilityMode``.
     - Parameter cloudSynchronization: When set, secret is added to iCloud keychain instead of local keychain. Default: false
     - Throws: An error of type ``KiiManagerError``.
     - Note: This library assumes that `accountName` is always given when adding a new entry to the keychain.
     */
    @discardableResult
    public func addOrUpdateSecretValue(accountName: String,
                                       labelName: String? = nil,
                                       serviceName: String? = nil,
                                       secretValue: String,
                                       comment: String? = nil,
                                       secretKind: SecretKind = .genericPassword,
                                       accessibilityMode: SecretAccessibilityMode = .whenUnlocked,
                                       cloudSynchronization: Bool = false) throws(KiiManagerError) -> ItemProcessed {
        var processed: ItemProcessed = .nothing
        do {
            try self.updateSecret(accountName: accountName, labelName: labelName, serviceName: serviceName,
                                  secretKind: secretKind, newSecretValue: secretValue)
            processed = .updated
        } catch KiiManagerError.entryNotFound {
            try self.addSecret(accountName: accountName, labelName: labelName, serviceName: serviceName, secretValue: secretValue,
                               comment: comment, secretKind: secretKind, accessibilityMode: accessibilityMode, cloudSynchronization: cloudSynchronization)
            processed = .added
        } catch {
            throw error
        }
        return processed
    }
    

    /**
     Remove secret from secure storage (keychain).
     
     - Parameter accountName: Secret's account, e.g. username, profile name.
     - Parameter labelName: Secret's label name. **Optional, default: nil**
     - Parameter serviceName: Secret's service name. **Optional, default: nil**
     - Parameter secretKind: The secret's kind, default is set to `.genericPassword`. Refer to ``SecretKind``.
     - Throws: An error of type ``KiiManagerError``.
     */
    public func removeSecret(accountName: String, labelName: String? = nil, serviceName: String? = nil, secretKind: SecretKind = .genericPassword) throws(KiiManagerError) {
        // find entry in keychain which will be deleted
        var deleteQuery: Dictionary<String, Any> = [
            kSecAttrAccount as String: accountName,
            kSecClass as String: secretKind.specifiedKind
        ]
        
        if let serviceName = serviceName {
            deleteQuery[kSecAttrService as String] = serviceName
        }
        if let labelName = labelName {
            deleteQuery[kSecAttrLabel as String] = labelName
        }
        
        // delete entry
        let result = SecItemDelete(deleteQuery as CFDictionary)
        
        try throwErrorFor(result)

    }
    
    // MARK: - Helpers
    
    private func throwErrorFor(_ result: OSStatus) throws(KiiManagerError) {
        if result == errSecMissingEntitlement {
            throw KiiManagerError.securityEntitlementError("Check required entitlements and code signing settings!")
        } else if result == errSecDuplicateItem {
            throw KiiManagerError.entryAlreadyExists("Entry already exists. Use 'updateSecret' instead.")
        } else if result == errSecItemNotFound {
            throw KiiManagerError.entryNotFound("Requested secret not found")
        } else if result != errSecSuccess {
            throw KiiManagerError.genericError(result)
        }
    }
}

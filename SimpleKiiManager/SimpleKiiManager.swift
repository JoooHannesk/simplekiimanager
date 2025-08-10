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
     - Parameter accessPolicyMode: Specifies the items access policy mode, default is set to `.whenUnlocked`. Refer to ``AccessPolicy``.
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
        accessPolicyMode: AccessPolicy = .whenUnlocked,
        cloudSynchronization: Bool = false
    )
        throws(KiiManagerError)
    {
        var addSecretQuery: Dictionary<String, Any> = [
            kSecAttrAccount as String: accountName,
            kSecValueData as String: secretValue.data(using: .utf8)!,
            kSecClass as String: secretKind.specifiedKind,
            kSecAttrAccessible as String: accessPolicyMode.specifiedMode,
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
        
        try checkResultForError(result)
    }

    /**
     Retrieve all secrets from secure storage (keychain)
         
     - Parameter accountName: Secret's account, e.g. username, profile name. **Optional, default: nil**
     - Parameter labelName: Secret's label name. **Optional, default: nil**
     - Parameter serviceName: Secret's (service/entry) name, e.g. item name. **Optional, default: nil**
     - Parameter secretKind: The secret's kind, default is set to `.genericPassword`. Refer to ``SecretKind``.
     - Parameter retrieve: Number of entries to request (default: 255)
     - Returns: The requested entry as ``KiiSecret`` inside an array.
     - Throws: An error of type ``KiiManagerError``
     - Note: There may be multiple entries for the same `labelName` (e.g. same `labelName` but different `accountName`). Use this method to retrieve all secrets previously stored under a single `labelName`.
     */
    public func getMultipleSecrets(accountName: String? = nil, labelName: String? = nil, serviceName: String? = nil,
                                   secretKind: SecretKind = .genericPassword, numberOfEntries retrieve: UInt8 = 255 ) throws(KiiManagerError) -> [KiiSecret] {
        guard !(labelName == nil && serviceName == nil && accountName == nil) else {
            throw KiiManagerError.invalidIdentifier("'labelName', 'serviceName' and 'accountName' cannot be nil all at once!")
        }

        var getSecretQuery: Dictionary<String, Any> = [
                kSecReturnData as String: true,
                kSecReturnAttributes as String: true,
                kSecClass as String: secretKind.specifiedKind,
                kSecMatchLimit as String: retrieve
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
        
        try checkResultForError(result)
        
        guard let allRetrievedEntries = secretDataTypeRef as? [Dictionary<String, Any?>] else {
            throw KiiManagerError.dataFormatMissmatch
        }
        var kiiSecrets: [KiiSecret] = []
        for secretData in allRetrievedEntries {
            if let accountName = secretData[kSecAttrAccount as String] as? String,
               let secretValueData = secretData[kSecValueData as String] as? Data,
               let secretValue = String(data: secretValueData, encoding: .utf8),
               let creationDate = secretData[kSecAttrCreationDate as String] as? Date,
               let modificationDate = secretData[kSecAttrModificationDate as String] as? Date {
                let secret = KiiSecret(
                    accountName: accountName,
                    labelName: secretData[kSecAttrLabel as String, default:  nil] as? String,
                    serviceName: secretData[kSecAttrService as String, default: nil] as? String,
                    secretValue: secretValue,
                    secretKind: secretKind,
                    comment: secretData[kSecAttrComment as String, default: nil] as? String,
                    creationDate: creationDate,
                    modificationDate: modificationDate
                )
                kiiSecrets.append(secret)
            }
            else {
                throw KiiManagerError.entryIsMissingElements
            }
        }
        return kiiSecrets
    }

    /**
     Retrieve a single secret from secure storage (keychain)

     This method is deprecated and **retained solely for backward compatibility and may be removed in future versions!**
     Use ``SimpleKiiManagerSt/getMultipleSecrets(accountName:labelName:serviceName:secretKind:numberOfEntries:)`` instead. See below for further information.
     - Parameter accountName: Secret's account, e.g. username, profile name. **Optional, default: nil**
     - Parameter labelName: Secret's label name. **Optional, default: nil**
     - Parameter serviceName: Secret's (service/entry) name, e.g. item name. **Optional, default: nil**
     - Parameter secretKind: The secret's kind, default is set to `.genericPassword`. Refer to ``SecretKind``.
     - Returns: The requested entry as ``KiiSecret``
     - Throws: An error of type ``KiiManagerError``
     - Note: There may be multiple entries for the same `labelName` (e.g. same `labelName` but different `accountName`). **If you’re certain that only a single entry exists, use this method to retrieve it. It is retained solely for backward compatibility and may be removed in future versions!**
     */
    @available(*, deprecated, renamed: "getMultipleSecrets(accountName:labelName:serviceName:secretKind:)")
    public func getSecret(accountName: String? = nil, labelName: String? = nil, serviceName: String? = nil,
                          secretKind: SecretKind = .genericPassword) throws(KiiManagerError) -> KiiSecret {
        let kiiSecrets = try getMultipleSecrets(accountName: accountName, labelName: labelName, serviceName: serviceName,
                                               secretKind: secretKind)
        guard let kiiSecret = kiiSecrets.first else {
            throw KiiManagerError.entryNotFound("Requested secret not found")
        }
        return kiiSecret
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
        
        try checkResultForError(result)
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
     - Parameter accessPolicyMode: Specifies the item's access policy mode, default is set to `.whenUnlocked`. Refer to ``AccessPolicy``.
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
                                       accessPolicyMode: AccessPolicy = .whenUnlocked,
                                       cloudSynchronization: Bool = false) throws(KiiManagerError) -> ItemProcessed {
        var processed: ItemProcessed = .nothing
        do {
            try self.updateSecret(accountName: accountName, labelName: labelName, serviceName: serviceName,
                                  secretKind: secretKind, newSecretValue: secretValue)
            processed = .updated
        } catch KiiManagerError.entryNotFound {
            try self.addSecret(accountName: accountName, labelName: labelName, serviceName: serviceName, secretValue: secretValue,
                               comment: comment, secretKind: secretKind, accessPolicyMode: accessPolicyMode, cloudSynchronization: cloudSynchronization)
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
        // find entry in keychain -> is going to be deleted
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
        
        try checkResultForError(result)
    }
    
    // MARK: - Helpers
    
    private func checkResultForError(_ result: OSStatus) throws(KiiManagerError) {
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

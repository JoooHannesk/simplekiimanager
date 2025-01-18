//
//  ComfortKiiManager.swift
//  SimpleKiiManager
//
//  Created by Johannes Kinzig on 16.01.25.
//

import Foundation

/**
 Provide functionality to read and write secrets to keychain by offering a property wrapper
 
 Implementation based on ``SimpleKiiManagerSt``
 */
@propertyWrapper public struct ComfortKiiManager {
    let accountName: String
    let labelName: String?
    let serviceName: String?
    let comment: String?
    let secretKind: SecretKind
    let accessibilityMode: SecretAccessibilityMode
    let cloudSynchronization: Bool
    
    public let simpleKiiManager = SimpleKiiManagerSt.shared
    
    public var wrappedValue: String? {
        get {
            return self.getSecret()
        }
        set {
            if let newValue {
                self.getSecret() == nil ? self.addSecret(secretValue: newValue) : self.updateSecret(secretValue: newValue)
            } else {
                self.deleteSecret()
            }
        }
    }
    
    /**
     Define settings for secret element to handle
     
     - Parameter accountName: Secret's account, e.g. username, profile name.
     - Parameter labelName: Secret's label name. **Optional, default: nil**
     - Parameter serviceName: Secret's service name. **Optional, default: nil**
     - Parameter comment: Comment for entry. **Optional, default: nil**
     - Parameter secretKind: The secret's kind, default is set to `.genericPassword`. Refer to ``SecretKind``.
     - Parameter accessibilityMode: Specifies the items accessibility mode, default is set to `.whenUnlocked`. Refer to ``SecretAccessibilityMode``.
     - Parameter cloudSynchronization: When set, secret is added to iCloud keychain instead of local keychain. Default: false
     */
    public init(
        accountName: String,
        labelName: String? = nil,
        serviceName: String? = nil,
        comment: String? = nil,
        secretKind: SecretKind = .genericPassword,
        accessibilityMode: SecretAccessibilityMode = .whenUnlocked,
        cloudSynchronization: Bool = false
    ) {
        self.accountName = accountName
        self.labelName = labelName
        self.serviceName = serviceName
        self.comment = comment
        self.secretKind = secretKind
        self.accessibilityMode = accessibilityMode
        self.cloudSynchronization = cloudSynchronization
    }
    
    /// Add secret to keychain using framework API
    func addSecret(secretValue: String) {
        do {
            try simpleKiiManager.addSecret(accountName: self.accountName, labelName: self.labelName, serviceName: self.serviceName, secretValue: secretValue,
                                           comment: self.comment, secretKind: self.secretKind, accessibilityMode: self.accessibilityMode, cloudSynchronization: self.cloudSynchronization)
        }
        catch {
            print(error)
        }
    }
    
    /// Retrieve secret from keychain using framework API
    func getSecret() -> String? {
        do {
            let secret = try simpleKiiManager.getSecret(accountName: self.accountName, labelName: self.labelName, serviceName: self.serviceName, secretKind: self.secretKind)
            return secret.secretValue
        }
        catch {
            if case KiiManagerError.entryNotFound = error {
                /// Keychain will throw this error every time an entry is added for the first time; do not make it look like an error
                // TODO: improve
                print("Entry not found in keychain")
            }
            return nil
        }
    }
    
    /// Update secret in keychain using framework API
    func updateSecret(secretValue: String) {
        do {
            try simpleKiiManager.updateSecret(accountName: self.accountName, labelName: self.labelName, serviceName: self.serviceName, secretKind: self.secretKind, newSecretValue: secretValue)
        }
        catch {
            print(error)
        }
    }
    
    /// Delete secret from keychain using framework API
    func deleteSecret() {
        do {
            try simpleKiiManager.removeSecret(accountName: self.accountName, labelName: self.labelName, serviceName: self.serviceName, secretKind: self.secretKind)
        }
        catch {
            print(error)
        }
    }
}

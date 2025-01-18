//
//  SimpleKiiManagerTypes.swift
//  SimpleKiiManagerTypes
//
//  Created by Johannes Kinzig on 23.12.24.
//

import Security

/// The secret's kind
///
/// Collection of the secret supported kinds, e.g. generic password, internet password, certificate, etc
public enum SecretKind {
    /// for use with generic password items
    case genericPassword
    /// for use with Internet password items
    case internetPassword
    /// for use with certificate items
    case certificate
    /// for use with key items
    case cryptographicKey
    /// for use with identity
    case identity

    init?(_ specifiedKind: CFString) {
        switch specifiedKind {
        case kSecClassGenericPassword:
            self = .genericPassword
        case kSecClassInternetPassword:
            self = .internetPassword
        case kSecClassCertificate:
            self = .certificate
        case kSecClassKey:
            self = .cryptographicKey
        case kSecClassIdentity:
            self = .identity
        default:
            return nil
        }
    }

    var specifiedKind: CFString {
        switch self {
        case .genericPassword:
            return kSecClassGenericPassword
        case .internetPassword:
            return kSecClassInternetPassword
        case .certificate:
            return kSecClassCertificate
        case .cryptographicKey:
            return kSecClassKey
        case .identity:
            return kSecClassIdentity
        }
    }
}

/// The secret's accessibility constraint.
///
/// Controls the keychain item access policy. Depends on device's lock state and passcode settings: e.g. item accessible when unlocked, when password is set, etc.
public enum SecretAccessibilityMode {
    /**
    Item can be accessed while **device is unlocked**, therefore mainly suited for applications accessing the keychain when **running in foreground**.
    Items marked with this attribute will be **backed up when encrypted backups** are enabled. Reflects `kSecAttrAccessibleWhenUnlocked`.
     */
    case whenUnlocked
    
    /**
     Item can be accessed when device was initially unlocked after a restart, therefore suitable for applications requiring keychain access when **running in background**.
     Items marked with this attribute will be **backed up when encrypted backups** are enabled. Reflects `kSecAttrAccessibleAfterFirstUnlock`.
     */
    case afterFirstUnlock

    /**
    Item can be accessed while **device is unlocked**, therefore mainly suited for applications accessing the keychain when **running in foreground**. Device is **required to have a passcode set up**.
    Items marked with this attribute will **never get backed up or migrated to another device**. When a backup is restored, this item will be missing. Disabling the passcode protection on device **deletes all items marked with this attribute**.
    Reflects `kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly`.
     */
    case whenPasswordSetAndUnlockedLocalDeviceOnly
    
    /**
    Item can be accessed while **device is unlocked**, therefore mainly suited for applications accessing the keychain when **running in foreground**.
    Items marked with this attribute will **never get backed up or migrated to another device**. When a backup is restored, this item will be missing.
    Reflects `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`.
     */
    case whenUnlockedLocalDeviceOnly
    
    /**
    Item can be accessed when device was initially unlocked after a restart, therefore suitable for applications requiring keychain access when **running in background**.
    Items marked with this attribute will **never get backed up or migrated to another device**. When a backup is restored, this item will be missing.
    Reflects `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`.
     */
    case afterFirstUnlockLocalDeviceOnly

    init?(_ specifiedMode: CFString) {
        switch specifiedMode {
        case kSecAttrAccessibleWhenUnlocked:
            self = .whenUnlocked
        case kSecAttrAccessibleAfterFirstUnlock:
            self = .afterFirstUnlock
        case kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly:
            self = .whenPasswordSetAndUnlockedLocalDeviceOnly
        case kSecAttrAccessibleWhenUnlockedThisDeviceOnly:
            self = .whenUnlockedLocalDeviceOnly
        case kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly:
            self = .afterFirstUnlockLocalDeviceOnly
        default:
            return nil
        }
    }

    var specifiedMode: CFString {
        switch self {
        case .whenUnlocked:
            return kSecAttrAccessibleWhenUnlocked
        case .afterFirstUnlock:
            return kSecAttrAccessibleAfterFirstUnlock
        case .whenPasswordSetAndUnlockedLocalDeviceOnly:
            return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
        case .whenUnlockedLocalDeviceOnly:
            return kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        case .afterFirstUnlockLocalDeviceOnly:
            return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        }
    }
}


public enum KiiManagerError: Error {
    case genericError(OSStatus)
    case securityEntitlementError(String)
    case entryAlreadyExists(String)
    case entryNotFound(String)
    case dataFormatMissmatch
    case entryIsMissingElements
    case invalidIdentifier(String)
}

/**
Custom type representing an element retrieved from keychain

Defines a custom struct representing an entry/element/item (call it whatever you like) retrieved from keychain holding its properties.
 */
public struct KiiSecret: CustomStringConvertible {
    /// Secret account name as given when stored in keychain (optional)
    public let accountName: String
    /// Secret label as given when stored in keychain
    public let labelName: String?
    /// Secret service name as given when stored in keychain
    public let serviceName: String?
    /// Actual secret (e.g. password, token, etc.) as given when stored in keychain
    public let secretValue: String
    /// Secret kind as given when stored in keychain
    public let secretKind: SecretKind
    /// Secret comment as given when stored in keychain
    public let comment: String?
    /// Creation date / date first stored in keychain
    public let creationDate: Date
    /// Modification date / date last updated
    public let modificationDate: Date
    /// String representation of this instance (mainly for developing purpose and comfortable insight)
    public var description: String { return getStringRepresentation(for: self) }
}

// MARK: - Helper Functions
/// Get a string representation for data model
///
/// - Parameter for: type/instance to show its custom String representation
/// - Returns: string representation of dataModelObject
private func getStringRepresentation(for dataModelObject: Any) -> String {
    var stringRepresentation: String =
        String(describing: type(of: dataModelObject)) + " – "
    let dataModelObjectMirror: Mirror = Mirror(reflecting: dataModelObject)
    for dataModelObjectProperty in dataModelObjectMirror.children {
        stringRepresentation +=
            "\(String(describing: dataModelObjectProperty.label ?? "")): \(String(describing: dataModelObjectProperty.value)) "
    }
    return stringRepresentation
}

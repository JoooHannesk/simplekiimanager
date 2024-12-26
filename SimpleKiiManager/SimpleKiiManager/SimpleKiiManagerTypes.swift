//
//  SimpleKiiManagerTypes.swift
//  SimpleKiiManagerTypes
//
//  Created by Johannes Kinzig on 23.12.24.
//

import Security

/** The secret's kind

 Collection of the secret supported kinds, e.g. generic password, internet password, certificate, etc
 */
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


/**
 The secrets accessibility constraint.
 
 Constraints the device's state in which the secret can be retrieved: e.g. when unlocked, when password is set, etc.
 */
public enum SecretAccessibilityMode {
    // items will be backed up and transferred to a new device
    case whenUnlocked
    case afterFirstUnlock
    
    // items will not be backed up!
    case whenPasswordSetAndUnlockedLocalDeviceOnly
    case whenUnlockedLocalDeviceOnly
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


// TODO: shorten and add to elements
/**
 @constant kSecAttrAccessibleWhenUnlocked Item data can only be accessed
     while the device is unlocked. This is recommended for items that only
     need be accesible while the application is in the foreground.  Items
     with this attribute will migrate to a new device when using encrypted
     backups.
 */

/**
 @constant kSecAttrAccessibleAfterFirstUnlock Item data can only be
     accessed once the device has been unlocked after a restart.  This is
     recommended for items that need to be accesible by background
     applications. Items with this attribute will migrate to a new device
     when using encrypted backups.
 */

/**
 @constant kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly Item data can
     only be accessed while the device is unlocked. This is recommended for
     items that only need to be accessible while the application is in the
     foreground and requires a passcode to be set on the device. Items with
     this attribute will never migrate to a new device, so after a backup
     is restored to a new device, these items will be missing. This
     attribute will not be available on devices without a passcode. Disabling
     the device passcode will cause all previously protected items to
     be deleted.
 */

/**
 @constant kSecAttrAccessibleWhenUnlockedThisDeviceOnly Item data can only
     be accessed while the device is unlocked. This is recommended for items
     that only need be accesible while the application is in the foreground.
     Items with this attribute will never migrate to a new device, so after
     a backup is restored to a new device, these items will be missing.
 */

/**
 @constant kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly Item data can
     only be accessed once the device has been unlocked after a restart.
     This is recommended for items that need to be accessible by background
     applications. Items with this attribute will never migrate to a new
     device, so after a backup is restored to a new device these items will
     be missing.
 */

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
 Custom entry type retrieved from keychain
 */
public struct KiiSecret: CustomStringConvertible {
    /// Secret service name as given when stored in keychain
    public let serviceName: String
    /// Secret account name as given when stored in keychain (optional)
    public let accountName: String?
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
/**
 Get a string representation for data model
 - Parameter for: type/instance to show its custom String representation
 - Returns: string representation of dataModelObject
 */
fileprivate func getStringRepresentation(for dataModelObject: Any) -> String {
    var stringRepresentation: String = String(describing: type(of: dataModelObject)) + " – "
    let dataModelObjectMirror: Mirror = Mirror(reflecting: dataModelObject)
    for dataModelObjectProperty in dataModelObjectMirror.children {
        stringRepresentation += "\(String(describing: dataModelObjectProperty.label ?? "")): \(String(describing: dataModelObjectProperty.value)) "
    }
    return stringRepresentation
}

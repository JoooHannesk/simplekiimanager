# Usage
This library consists of two major classes being in charge for keychain interaction

* ``SimpleKiiManagerSt``: offers methods to add, read, update and delete items in keychain
* ``ComfortKiiManager``: offers a property wrapper to add, read, update and delete items in keychain

## Supported item types and accessibility policies
Keychain supports different item types based on their intended use (e.g. passwords, identities, certificates, etc.) and maintains different access policies based on the device-state (e.g. unlocked, booted but not initially unlocked)
* Supported item types: <doc:ItemTypes>
* Supported access policies: <doc:AccessPolicies>

## Using SimpleKiiManagerSt
### add items
Adding a username and passwort:
```swift
try SimpleKiiManagerSt.shared.addSecret(accountName: "user@example.com", labelName: "ExampleLogin", serviceName: "ExampleMailService", secretValue: "mySuperSecretPassword", comment: "E-Mail login for example user")
```
``SimpleKiiManagerSt/addSecret(accountName:labelName:serviceName:secretValue:comment:secretKind:accessibilityMode:cloudSynchronization:)``

### read items

### update items

### add or update items secret value
Add a new element to keychain or update its secret vlaue in case it already exists.

### delete items

## Using ComfortKiiManager

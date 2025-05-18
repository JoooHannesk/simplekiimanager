# Usage
This library consists of two classes simplifying keychain interactions.

* ``SimpleKiiManagerSt``: offers methods to add, read, update and delete items in keychain
* ``ComfortKiiManager``: offers a property wrapper to add, read, update and delete items in keychain

## Supported item types and accessibility policies
Keychain supports different item types based on their intended use (e.g. passwords, identities, certificates, etc.) and maintains different access policies based on the device state (e.g. unlocked, booted but not initially unlocked, etc.). Make sure to select the appropriate one for your specific case.
* Supported item types: ``SecretKind``
* Supported access policies: ``SecretAccessibilityMode``

## Using SimpleKiiManagerSt
This library performs all keychain CRUD operations on a shared singleton.

### Adding an item to keychain
In this example a *username* and *passwort*. The item type ``SecretKind`` is set to `.genericPassword` by default (function parameter: `secretKind`) when not explicitely stated otherwise in the function call. The same applies for ``SecretAccessibilityMode``, the default argument for parameter `accessibilityMode` is `.whenUnlocked`.
```swift
import SimpleKiiManager

// parameter *secretKind* and *accessibilityMode* not explicitely stated as the default values are used
try SimpleKiiManagerSt.shared.addSecret(accountName: "user@example.com", labelName: "ExampleLogin", serviceName: "ExampleMailService", secretValue: "mySuperSecretPassword", comment: "E-Mail login for example user")

// parameter *secretKind* and *accessibilityMode* explicitely stated
try SimpleKiiManagerSt.shared.addSecret(accountName: default1SecretAccountName, labelName: defaultSecretLabelName, serviceName: defaultSecretServiceName, secretValue: default1SecretValue, comment: default1comment, secretKind: .genericPassword, accessibilityMode: .afterFirstUnlock)
```
Refer to ``SimpleKiiManagerSt/addSecret(accountName:labelName:serviceName:secretValue:comment:secretKind:accessibilityMode:cloudSynchronization:)``.

If the item already exists, an error of type ``KiiManagerError`` will be thrown. To update an existing item, refer to ``SimpleKiiManagerSt/updateSecret(accountName:labelName:serviceName:secretKind:newLabelName:newServiceName:newAccountName:newSecretValue:newComment:)``.

For more comfort when adding a new item or updating an existing one, refer to ``SimpleKiiManagerSt/addOrUpdateSecretValue(accountName:labelName:serviceName:secretValue:comment:secretKind:accessibilityMode:cloudSynchronization:)`` but make sure to understand its limitations, as described in more details below.

### Reading an item
ToDo!

### Updating an item
ToDo!

### Adding or updating an item in a single function call
Add a new item to keychain or update its secret vlaue in case it already exists.

For a more comfortable usage scenario, this library supports adding/updating an item in a single function call. You don't need to check if an item already exists in keychain before adding it or updating its secret value. This function call checks if the item exists before updating or adding. In case it exists, its secret value gets updated. In case it is not existing, it will be added.

**Important remark:** This method updates only the item’s secret value. To update additional properties (e.g., serviceName, labelName), use ``SimpleKiiManagerSt/updateSecret(accountName:labelName:serviceName:secretKind:newLabelName:newServiceName:newAccountName:newSecretValue:newComment:)``.

```swift
// 1. add an item
try SimpleKiiManagerSt.shared.addOrUpdateSecretValue(accountName: "test1@example.com", labelName: "SimpleKiiManagerLabel", secretValue: "ThisIsMySuperSecretPassword1ForTestingPurpose")

// 2. update this item's secret value
try SimpleKiiManagerSt.shared.addOrUpdateSecretValue(accountName: "test1@example.com", labelName: "SimpleKiiManagerLabel", secretValue: "NewSuperSecretPasswordForTesting")

// 3. delete this item
try SimpleKiiManagerSt.shared.removeSecret(accountName: "test1@example.com")
```
Refer to ``SimpleKiiManagerSt/addOrUpdateSecretValue(accountName:labelName:serviceName:secretValue:comment:secretKind:accessibilityMode:cloudSynchronization:)``

### Deleting an item
ToDo!

## Using ComfortKiiManager
This class provides even more comfort using the keychain by offering the CRUD mechanisms through a property wrapper. Even though, its functionality is more basic compared to ``SimpleKiiManagerSt``. Make sure to understand its limitations by looking at the usage example below.

```swift
import SimpleKiiManager

// 1. init and provide account name for item
@ComfortKiiManager(accountName: "mySimpleSecret")
var mySecret: String?

// 2. add (or updated) secret value for item
mySecret = "thisIsMySuperSecretSecret"

// 3. updated secret value for item 
mySecret = "updatedSuperSecretSecret"

// 4. read secret value
print(mySecret)
    
// 5. remove item from keychain
mySecret = nil
```
All CRUD (create, read, updated, delete) operations are supported and were implemented using the underlying class ``SimpleKiiManagerSt``.

# Usage
This library consists of two classes simplifying keychain interactions.

* ``SimpleKiiManagerSt``: offers methods to add, read, update and delete items in keychain
* ``ComfortKiiManager``: offers a property wrapper to add, read, update and delete items in keychain

## Supported item types and accessibility policies
Keychain supports different item types based on their intended use (e.g. passwords, identities, certificates, etc.) and maintains different access policies based on the device state (e.g. unlocked, booted but not initially unlocked, etc.). Make sure to select the appropriate one for your specific case.
* Supported item types: ``SecretKind``
* Supported access policies: ``AccessPolicy``

## Using SimpleKiiManagerSt
This library performs all keychain CRUD operations on a shared singleton.

### Adding an item to keychain
In this example a *username* and *passwort*. The item type ``SecretKind`` is set to `.genericPassword` by default (function parameter: `secretKind`) when not explicitely stated otherwise in the function call. The same applies for ``AccessPolicy``, the default argument for parameter `accessPolicyMode` is `.whenUnlocked`.
```swift
import SimpleKiiManager

// parameter *secretKind* and *accessPolicyMode* not explicitely stated as the default values are used
try SimpleKiiManagerSt.shared.addSecret(accountName: "user@example.com", labelName: "ExampleLogin", serviceName: "ExampleMailService", secretValue: "mySuperSecretPassword", comment: "E-Mail login for example user")

// parameter *secretKind* and *accessPolicyMode* explicitely stated
try SimpleKiiManagerSt.shared.addSecret(accountName: default1SecretAccountName, labelName: defaultSecretLabelName, serviceName: defaultSecretServiceName, secretValue: default1SecretValue, comment: default1comment, secretKind: .genericPassword, accessPolicyMode: .afterFirstUnlock)
```
Refer to ``SimpleKiiManagerSt/addSecret(accountName:labelName:serviceName:secretValue:comment:secretKind:accessPolicyMode:cloudSynchronization:)``.

If the item already exists, an error of type ``KiiManagerError`` will be thrown. To update an existing item, refer to ``SimpleKiiManagerSt/updateSecret(accountName:labelName:serviceName:secretKind:newLabelName:newServiceName:newAccountName:newSecretValue:newComment:)``.

For more comfort when adding a new item or updating an existing one, refer to ``SimpleKiiManagerSt/addOrUpdateSecretValue(accountName:labelName:serviceName:secretValue:comment:secretKind:accessPolicyMode:cloudSynchronization:)`` but make sure to understand its limitations, as described in more details below.

### Reading an item
```swift
let mySecretResponse = try SimpleKiiManagerSt.shared.getSecret(accountName: "user@example.com")
print(mySecretResponse)
```
The return value is of type ``KiiSecret``. The method ``SimpleKiiManagerSt/getSecret(accountName:labelName:serviceName:secretKind:)`` requires at least one of the parameters (`accountName`, `labelName`, or `serviceName`) to be provided. The `secretKind` parameter has a default value of `.genericPassword`. For further details, refer to ``SimpleKiiManagerSt/getSecret(accountName:labelName:serviceName:secretKind:)``.


### Updating an item
```swift
// Updating the entry identified by accountName: "user@example.com", labelName: "ExampleLogin", serviceName: "ExampleMailService"
// Providing new values for its label, service, account, password (aka. secret value) and comment
try SimpleKiiManagerSt.shared.updateSecret(accountName: "user@example.com", labelName: "ExampleLogin", serviceName: "ExampleMailService", newLabelName: "NewLabelName", newServiceName: "NewServiceName", newAccountName: "newUser@example.com", newSecretValue: "newPaSsWoRd", newComment: "Username changed")
```
The parameters `labelName` and `serviceName` are optional and are used to help locate the desired item. The `secretKind` parameter is required, but it has a default value of `.genericPassword`. The parameters used to specify updated values — `newLabelName`, `newServiceName`, `newAccountName`, `newSecretValue`, and `newComment` — are all optional, but at least one should be provided, as calling this method without updating any values would have no practical effect.
```swift
// Updating the password only, solely identifying the item by its account name
try SimpleKiiManagerSt.shared.updateSecret(accountName: "newUser@example.com", newSecretValue: "mYnEwPaSsWoRd"))
```
Refer to ``SimpleKiiManagerSt/updateSecret(accountName:labelName:serviceName:secretKind:newLabelName:newServiceName:newAccountName:newSecretValue:newComment:)``.

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
Refer to ``SimpleKiiManagerSt/addOrUpdateSecretValue(accountName:labelName:serviceName:secretValue:comment:secretKind:accessPolicyMode:cloudSynchronization:)``.

#### Changes with Version 0.0.2
Since **Version 0.0.2** ``SimpleKiiManagerSt/addOrUpdateSecretValue(accountName:labelName:serviceName:secretValue:comment:secretKind:accessPolicyMode:cloudSynchronization:)`` has a (`@discardableResult`) return value of type ``SimpleKiiManager/ItemProcessed`` to indicate if the item was ``SimpleKiiManager/ItemProcessed/added`` or ``SimpleKiiManager/ItemProcessed/updated``.
```swift
let processedAction = try SimpleKiiManagerSt.shared.addOrUpdateSecretValue(accountName: "test1@example.com", labelName: "SimpleKiiManagerLabel", secretValue: "NewSuperSecretPasswordForTesting")
```

### Deleting an item
```swift
try SimpleKiiManagerSt.shared.removeSecret(accountName: "test1@example.com")
```
Refer to ``SimpleKiiManagerSt/removeSecret(accountName:labelName:serviceName:secretKind:)``.

## Using ComfortKiiManager
This class provides even more comfort using the keychain by offering the CRUD mechanisms through a property wrapper. Even though, its functionality is more basic compared to ``SimpleKiiManagerSt``. Make sure to understand its limitations by looking at the usage example below.

```swift
import SimpleKiiManager

// 1. Init and provide account name for item
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

# Release Notes
What's New and What Got Fixed?

## Version 0.0.2
* ``SimpleKiiManager/KiiManagerError`` does now conform to `Equatable` protocol for better handling
* ``SimpleKiiManagerSt/addOrUpdateSecretValue(accountName:labelName:serviceName:secretValue:comment:secretKind:accessibilityMode:cloudSynchronization:)`` now has a (`@discardableResult`) return value of type ``ItemProcessed`` to indicate if the item was ``ItemProcessed/added`` or ``ItemProcessed/updated``.

## Version 0.0.1
* First and initial library version
* CRUD operations on keychain items through **simplified functions** (this library offers functions to create, read, update, delete keychain items) – see <doc:Usage/Using-SimpleKiiManagerSt>
* CRUD operations on keychain items through a **property wrapper** (for more comfort and less code) – <doc:Usage/Using-ComfortKiiManager>

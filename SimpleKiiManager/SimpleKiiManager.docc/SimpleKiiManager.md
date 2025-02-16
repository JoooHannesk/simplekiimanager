# ``SimpleKiiManager``
Simple wrapper around the default keychain API.

The native keychain API provided by macOS / iOS is quite advanced and therefore may require some time to dive into. ``SimpleKiiManager`` aims to provide a simple interface around the default API to get started more quickly.

## Supported functionality
* CRUD operations on keychain items through **simplified functions** (this library offers functions to create, read, update, delete keychain items)
* CRUD operations on keychain items through a **property wrapper** (for more comfort and less code)

## Version
* 0.0.1 (Date 01.2025)

## Runs on
* iOS >= 17.5
* macOS >= 14.2
* visionOS >= 1.3 (untested)

## Documentation
* <doc:Installation>: How to add this framework to your Xcode project
* <doc:Usage>: How to use this library, its methods and property wrappers
* <doc:Tests>

## Author
Johannes Kinzig (2025)

## MIT License
This library is provided under the MIT License. See <doc:License>

## Background
Storing secrets, such as passwords, identities, certificates, etc. on (a) device is always a security challenge. iOS / macOS offers a secure solution for this – named **Keychain**.
As described above, using the native keychain API can be quite challenging, therefore this library aims to offer a more comfortable starting point.

## Other keychain libraries
This is not the only library wrapping the native keychain API, several more exist:
TODO: link to other libraries

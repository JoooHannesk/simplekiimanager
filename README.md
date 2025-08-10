![project_avatar_icon](https://bitbucket.org/swift-projects/simplekiimanager/raw/main/Meta/simplekiimanager-avatar.png)
# SimpleKiiManager
Simple wrapper around the default keychain API.

The native keychain API provided by macOS / iOS is quite advanced and therefore may require some time to dive into. `SimpleKiiManager` aims to provide a simple interface around the default API to get started quickly.

## Supported functionality
* CRUD operations on keychain items through **simplified functions** (this library offers functions to create, read, update, delete keychain items) – see [Using SimpleKiiManagerSt](https://simplekiimanager.kinzig-developer-docs.com/documentation/simplekiimanager/usage/#Using-SimpleKiiManagerSt)
* CRUD operations on keychain items through a **property wrapper** (for more comfort and less code) – see [Using ComfortKiiManager](https://simplekiimanager.kinzig-developer-docs.com/documentation/simplekiimanager/usage/#Using-ComfortKiiManager)

## Version
* [Version 0.0.5](https://simplekiimanager.kinzig-developer-docs.com/documentation/simplekiimanager/releasenotes#Version-005) (Dated 08.2025)
* [Version 0.0.4](https://simplekiimanager.kinzig-developer-docs.com/documentation/simplekiimanager/releasenotes#Version-004) (Dated 08.2025)
* [Version 0.0.3](https://simplekiimanager.kinzig-developer-docs.com/documentation/simplekiimanager/releasenotes#Version-003) (Dated 05.2025)
* [Version 0.0.2](https://simplekiimanager.kinzig-developer-docs.com/documentation/simplekiimanager/releasenotes#Version-002) (Dated 05.2025)
* [Version 0.0.1](https://simplekiimanager.kinzig-developer-docs.com/documentation/simplekiimanager/releasenotes#Version-001) (Dated 01.2025)

## Runs on
* iOS >= 17.5
* macOS >= 14.2
* visionOS >= 1.3 (untested)

## Documentation
* [Release Notes](https://simplekiimanager.kinzig-developer-docs.com/documentation/simplekiimanager/releasenotes/): What's New and What Got Fixed?
* [Installation](https://simplekiimanager.kinzig-developer-docs.com/documentation/simplekiimanager/installation/): How to add this framework to your Xcode project?
* [Usage](https://simplekiimanager.kinzig-developer-docs.com/documentation/simplekiimanager/usage/): How to use this library, its methods and property wrappers?
* [Tests](https://simplekiimanager.kinzig-developer-docs.com/documentation/simplekiimanager/tests/): What is covered by the tests?
* [To-Dos](https://simplekiimanager.kinzig-developer-docs.com/documentation/simplekiimanager/to-dos/): To-Dos and Known Issues

## Resources
* Project Home: [https://johanneskinzig.com/simple-wrapper-around-the-default-keychain-api-simplekiimanager.html](https://johanneskinzig.com/simple-wrapper-around-the-default-keychain-api-simplekiimanager.html)
* Git Repo: [https://bitbucket.org/swift-projects/simplekiimanager/src/main/](https://bitbucket.org/swift-projects/simplekiimanager/src/main/)
* Documentation (this documentation): [https://simplekiimanager.kinzig-developer-docs.com/documentation/simplekiimanager/](https://simplekiimanager.kinzig-developer-docs.com/documentation/simplekiimanager/) 

## Author
Johannes Kinzig – [Contact me](https://johanneskinzig.com/lets-connect.html) – [Web](https://johanneskinzig.com) – [Project Home](https://johanneskinzig.com/simple-wrapper-around-the-default-keychain-api-simplekiimanager.html)

## Contribution
Contribution is always welcome, please [Contact me](https://johanneskinzig.com/lets-connect.html).

## MIT License
This library is provided under the MIT License. See [License](https://simplekiimanager.kinzig-developer-docs.com/documentation/simplekiimanager/license). Copyright (c) 2025 Johannes Kinzig

## Background
Storing secrets, such as passwords, identities, certificates, etc. on (a) device is always a security challenge. iOS / macOS offers a secure solution for this – named **Keychain**.
As described above, using the native keychain API can be quite challenging, therefore this library aims to offer a more comfortable starting point.

## Other keychain libraries
My library is not the only wrapper for the native keychain API, several more exist:

* [keychain-swift](https://github.com/evgenyneu/keychain-swift)
* [Latch](https://github.com/endocrimes/Latch)
* [SwiftKeychainWrapper](https://github.com/jrendel/SwiftKeychainWrapper)
* [KeychainAccess](https://github.com/kishikawakatsumi/KeychainAccess)
* [Locksmith](https://github.com/matthewpalmer/Locksmith)
* [KeyClip](https://github.com/s-aska/KeyClip)
* [SwiftKeychain](https://github.com/yankodimitrov/SwiftKeychain)


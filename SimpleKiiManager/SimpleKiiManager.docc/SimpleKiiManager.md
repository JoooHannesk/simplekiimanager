# ``SimpleKiiManager``
Simple wrapper around the default keychain API.

The native keychain API provided by macOS / iOS is quite advanced and therefore may require some time to dive into. ``SimpleKiiManager`` aims to provide a simple interface around the default API to get started quickly.

## Supported functionality
* CRUD operations on keychain items through **simplified functions** (this library offers functions to create, read, update, delete keychain items) – see <doc:Usage/Using-SimpleKiiManagerSt>
* CRUD operations on keychain items through a **property wrapper** (for more comfort and less code) – <doc:Usage/Using-ComfortKiiManager>

## Newest Version
* <doc:ReleaseNotes/Version-002> (Dated 05.2025)
* <doc:ReleaseNotes/Version-001> (Dated 01.2025)

## Runs on
* iOS >= 17.5
* macOS >= 14.2
* visionOS >= 1.3 (untested)

## Documentation
* <doc:ReleaseNotes>: What's New and What Got Fixed?
* <doc:Installation>: How to add this framework to your Xcode project?
* <doc:Usage>: How to use this library, its methods and property wrappers?
* <doc:Tests>: What is covered by the tests?
* <doc:ToDos>: To-Dos and Known Issues

## Resources
* Project Home: [https://johanneskinzig.com/simple-wrapper-around-the-default-keychain-api-simplekiimanager.html](https://johanneskinzig.com/simple-wrapper-around-the-default-keychain-api-simplekiimanager.html)
* Git Repo: [https://bitbucket.org/swift-projects/simplekiimanager/src/main/](https://bitbucket.org/swift-projects/simplekiimanager/src/main/)
* Documentation (this documentation): [https://simplekiimanager.kinzig-developer-docs.com/documentation/simplekiimanager/](https://simplekiimanager.kinzig-developer-docs.com/documentation/simplekiimanager/) 

## Author
Johannes Kinzig – [Contact me](https://johanneskinzig.com/lets-connect.html) – [Web](https://johanneskinzig.com) – [Project Home](https://johanneskinzig.com/simple-wrapper-around-the-default-keychain-api-simplekiimanager.html)

## MIT License
This library is provided under the MIT License. See <doc:License>. Copyright (c) 2025 Johannes Kinzig

## Background
Storing secrets, such as passwords, identities, certificates, etc. on (a) device is always a security challenge. iOS / macOS offers a secure solution for this – named **Keychain**.
As described above, using the native keychain API can be quite challenging, therefore this library aims to offer a more comfortable starting point.

## Other keychain libraries
This is not the only library wrapping the native keychain API, several more exist:
TODO: link to other libraries

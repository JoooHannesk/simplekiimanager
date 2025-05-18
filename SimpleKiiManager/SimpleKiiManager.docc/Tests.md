# Tests
Tests run locally on your Mac.

+ Clone the project and open it in Xcode.
+ All test cases are located in `SimpleKiiManagerTests/SimpleKiiManagerTests.swift` and can be run on a Mac using Xcode – either with *⌘U* or by selecting *Product → Test* from the menu.
+ The tests write temporary items to your Mac’s keychain and remove them after execution. To inspect what’s written, you can run the tests individually and view the keychain entries using the *Keychain Access app*, located at */System/Library/CoreServices/Applications/Keychain Access.app* (on macOS 15).

## Current Situation
+ Test coverage is currently 86%.
+ All test cases were performed with the **item type** set to `.genericPassword`. This is the default value when no explicit argument is provided in the function call. To learn more about the supported item types, see type ``SecretKind``.
+ All test cases were performed with the **accessibility mode** set to `.whenUnlocked`. This is the default value when no explicit argument is provided in the function call. To learn more about the supported accessibility modes, see section ``SecretAccessibilityMode``.

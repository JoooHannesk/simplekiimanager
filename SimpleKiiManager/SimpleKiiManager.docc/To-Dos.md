# To-Dos
To-Dos and Known Issues

## Retrieving entries
* [ ] Remove ``SimpleKiiManagerSt/getSecret(accountName:labelName:serviceName:secretKind:)``.
* [ ] Adapt test cases
* [ ] Adapt ``ComfortKiiManager``

## Error handling for ComfortKiiManager
* [ ] Implement proper error handling within ComfortKiiManager
* [ ] Expose meaningful error information to implementers
* [ ] Document the error handling behavior and expected error cases

## BUG: `.internetPassword` items fail because `serviceName` is always written to `kSecAttrService`

**Symptom:** Any call to ``SimpleKiiManagerSt/addSecret(accountName:labelName:serviceName:secretValue:comment:secretKind:accessPolicyMode:cloudSynchronization:)``,
``SimpleKiiManagerSt/getMultipleSecrets(accountName:labelName:serviceName:secretKind:numberOfEntries:)``,
``SimpleKiiManagerSt/updateSecret(accountName:labelName:serviceName:secretKind:newLabelName:newServiceName:newAccountName:newSecretValue:newComment:)``, or
``SimpleKiiManagerSt/removeSecret(accountName:labelName:serviceName:secretKind:)`` made with `secretKind: .internetPassword` and a non-nil `serviceName`
fails at runtime with `KiiManagerError.genericError(-25303)` (`errSecNoSuchAttr`).

**Root cause:** In `SimpleKiiManager.swift`, whenever `serviceName` is non-nil it is unconditionally written to (and read back from) the `kSecAttrService`
key. `kSecAttrService` is only a valid attribute for `kSecClass == kSecClassGenericPassword`. Items of class `kSecClassInternetPassword` do not support
`kSecAttrService` at all — they use `kSecAttrServer` instead (see Apple's "Password Attribute Keys" documentation). Passing `kSecAttrService` in a query
for an internet-password item is rejected by the Security framework with `errSecNoSuchAttr`, so `.internetPassword` is currently unusable whenever
`serviceName` is supplied.

**Where to fix (all four spots key off `secretKind` and currently hardcode `kSecAttrService`):**
- `addSecret(...)`: `if let serviceName = serviceName { addSecretQuery[kSecAttrService as String] = serviceName }`
- `getMultipleSecrets(...)`: the matching `if let serviceName = serviceName { getSecretQuery[kSecAttrService as String] = serviceName }`, **and** the
  `KiiSecret(... serviceName: secretData[kSecAttrService as String, default: nil] as? String ...)` construction that reads the value back out.
- `updateSecret(...)`: `if let serviceName = serviceName { searchEntryQuery[kSecAttrService as String] = serviceName }` and the matching
  `newServiceName` branch (`updateEntryQuery[kSecAttrService as String] = newServiceName`).
- `removeSecret(...)`: `if let serviceName = serviceName { deleteQuery[kSecAttrService as String] = serviceName }`.

**Required fix:** Pick the correct attribute key based on `secretKind` instead of always using `kSecAttrService`, e.g.:

```swift
let serviceAttrKey = (secretKind == .internetPassword) ? kSecAttrServer : kSecAttrService
```

and use `serviceAttrKey as String` everywhere `kSecAttrService as String` is currently hardcoded in the four methods above (both when writing the query
and when reading the value back out of the dictionary in `getMultipleSecrets`). `SecretKind` already models `.internetPassword`, so no public API/type
changes should be needed — just make the internal attribute mapping respect it.

**Acceptance criteria for the fix:**
1. `addSecret`, `getMultipleSecrets`, `updateSecret`, and `removeSecret` all work correctly end-to-end for `secretKind: .internetPassword` with a
   non-nil `serviceName` (add an entry, then read/update/delete it by that same `serviceName`), with no `errSecNoSuchAttr` failures.
2. `secretKind: .genericPassword` behavior is unchanged (still uses `kSecAttrService`).
3. Add test coverage in `SimpleKiiManagerTests.swift` mirroring the existing `.genericPassword` add/get/update/delete tests, but using
   `secretKind: .internetPassword`, to prevent regressions.

**Context:** Discovered via the `SiincosCharge` app's `SecureStorage` type, which originally called these APIs with `secretKind: .internetPassword`
and a `serviceName` (the server host). It was worked around there by switching to `.genericPassword`, but that workaround should be reverted once this
framework bug is fixed, since `.internetPassword` is the semantically correct kind for host + credentials storage.

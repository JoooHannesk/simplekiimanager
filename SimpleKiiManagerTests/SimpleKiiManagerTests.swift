//
//  SimpleKiiManagerTests.swift
//  SimpleKiiManagerStTests
//
//  Created by Johannes Kinzig on 25.12.24.
//

import XCTest
@testable import SimpleKiiManager

/**
 Test `SimpleKiiManagerSt` implementation
 */
final class SimpleKiiManagerStTests: XCTestCase {
    // constants for initially adding secret
    let defaultSecretLabelName = "SimpleKiiManagerLabel"
    let defaultSecretServiceName = "SimpleKiiManagerServiceName"
    let default1SecretAccountName = "test1@account.com"
    let default1SecretValue = "ThisIsSuperSecretPassword1ForTestingPurpose."
    let default1comment = "This is a comment for test1."
    
    // constants for updating secret
    let newLabelName = "SimpleKiiNewLabelName"
    let new1SecretServiceName = "NewServiceName"
    let new1SecretAccountName = "newtest1@account.com"
    let new1SecretValue = "NewSuperSecretPasswordForTesting"
    let new1comment = "New comment for testing."
    
    // MARK: - Test with exhaustive method-parameters
    
    func test01AddSecret1DefaultFunctionSignature() {
        XCTAssertNoThrow(try SimpleKiiManagerSt.shared.addSecret(accountName: default1SecretAccountName, labelName: defaultSecretLabelName, serviceName: defaultSecretServiceName, secretValue: default1SecretValue, comment: default1comment))
    }
    
    func test02GetSecretDefaultFunctionSignature() throws {
        let mySecretResponses = try SimpleKiiManagerSt.shared.getMultipleSecrets(serviceName: defaultSecretServiceName)
        let mySecretResponse = try XCTUnwrap(mySecretResponses.first)
        XCTAssertNotNil(mySecretResponse)
        XCTAssertEqual(mySecretResponse.labelName, defaultSecretLabelName)
        XCTAssertEqual(mySecretResponse.serviceName, defaultSecretServiceName)
        XCTAssertEqual(mySecretResponse.accountName, default1SecretAccountName)
        XCTAssertEqual(mySecretResponse.secretValue, default1SecretValue)
        XCTAssertEqual(mySecretResponse.comment, default1comment)
    }
    
    func test02GetSecretBasedOnAccountName() throws {
        let mySecretResponses = try SimpleKiiManagerSt.shared.getMultipleSecrets(accountName: default1SecretAccountName)
        let mySecretResponse = try XCTUnwrap(mySecretResponses.first)
        XCTAssertNotNil(mySecretResponse)
        XCTAssertEqual(mySecretResponse.labelName, defaultSecretLabelName)
        XCTAssertEqual(mySecretResponse.serviceName, defaultSecretServiceName)
        XCTAssertEqual(mySecretResponse.accountName, default1SecretAccountName)
        XCTAssertEqual(mySecretResponse.secretValue, default1SecretValue)
        XCTAssertEqual(mySecretResponse.comment, default1comment)
    }
    
    func test03UpdateEntry() {
        XCTAssertNoThrow(try SimpleKiiManagerSt.shared.updateSecret(accountName: default1SecretAccountName, labelName: defaultSecretLabelName, serviceName: defaultSecretServiceName,
                                                                    newLabelName: newLabelName, newServiceName: new1SecretServiceName, newAccountName: new1SecretAccountName, newSecretValue: new1SecretValue, newComment: new1comment))
    }
    
    func test04UpdatePasswordOnly() throws {
        let newPassword = "newPassword"
        XCTAssertNoThrow(try SimpleKiiManagerSt.shared.updateSecret(accountName: new1SecretAccountName, newSecretValue: newPassword))
        let mySecretResponses = try SimpleKiiManagerSt.shared.getMultipleSecrets(accountName: new1SecretAccountName)
        let mySecretResponse = try XCTUnwrap(mySecretResponses.first)
        XCTAssertEqual(mySecretResponse.secretValue, newPassword)
        XCTAssertNoThrow(try SimpleKiiManagerSt.shared.updateSecret(accountName: new1SecretAccountName, newSecretValue: new1SecretValue))
    }
    
    func test05GetUpdatedSecret() throws {
        let mySecretResponses = try SimpleKiiManagerSt.shared.getMultipleSecrets(labelName: newLabelName)
        let mySecretResponse = try XCTUnwrap(mySecretResponses.first)
        XCTAssertNotNil(mySecretResponse)
        XCTAssertEqual(mySecretResponse.labelName, newLabelName)
        XCTAssertEqual(mySecretResponse.serviceName, new1SecretServiceName)
        XCTAssertEqual(mySecretResponse.accountName, new1SecretAccountName)
        XCTAssertEqual(mySecretResponse.secretValue, new1SecretValue)
        XCTAssertEqual(mySecretResponse.comment, new1comment)
    }
    
    func test06DeleteSecret() throws {
        try SimpleKiiManagerSt.shared.removeSecret(accountName: new1SecretAccountName)
        XCTAssertThrowsError(try SimpleKiiManagerSt.shared.removeSecret(accountName: new1SecretAccountName))
    }
    
    func test07GetSecretWithMissingIdentifier() {
        XCTAssertThrowsError(try SimpleKiiManagerSt.shared.getMultipleSecrets(accountName: nil, labelName: nil, serviceName: nil))  { error in
            let purposeError = error as! KiiManagerError
            XCTAssertEqual(purposeError, KiiManagerError.invalidIdentifier("'labelName', 'serviceName' and 'accountName' cannot be nil all at once!"))
        }
    }
    
    func test08StoreMultipleSecretsForSameLabelName() throws {
        // Store secrets
        XCTAssertNoThrow(try SimpleKiiManagerSt.shared.addSecret(accountName: "test1@account.com", labelName: "TestCaseSimpleKiiManagerLabel", secretValue: "99112233"))
        XCTAssertNoThrow(try SimpleKiiManagerSt.shared.addSecret(accountName: "User9988@nobody.com", labelName: "TestCaseSimpleKiiManagerLabel", secretValue: "33229988"))
        // Retrieve secrets
        do {
            let allMySecrets = try SimpleKiiManagerSt.shared.getMultipleSecrets(labelName: "TestCaseSimpleKiiManagerLabel")
            XCTAssertEqual(allMySecrets.count, 2)
        }
        catch {
            XCTFail("Failed to retrieve secrets: \(error.localizedDescription), \(error)")
        }
        try SimpleKiiManagerSt.shared.removeSecret(accountName: "test1@account.com", labelName: "TestCaseSimpleKiiManagerLabel")
        try SimpleKiiManagerSt.shared.removeSecret(accountName: "User9988@nobody.com", labelName: "TestCaseSimpleKiiManagerLabel")
        XCTAssertThrowsError(try SimpleKiiManagerSt.shared.removeSecret(accountName: "test1@account.com"))
        XCTAssertThrowsError(try SimpleKiiManagerSt.shared.removeSecret(accountName: "User9988@nobody.com"))
    }
}

/**
 Test `SimpleKiiManagerSt.shared.addOrUpdateSecretValue` method implementation
 */
final class AddOrUpdateTests: XCTestCase {
    let defaultSecretLabelName = "SimpleKiiManagerLabel"
    let defaultSecretAccountName = "test1@account.com"
    let defaultSecretValue = "ThisIsSuperSecretPassword1ForTestingPurpose."
    let default2SecretValue = "NewSuperSecretPasswordForTesting."
    
    func test01AddOrUpdateNewSecret() throws {
        let processedAction = try SimpleKiiManagerSt.shared.addOrUpdateSecretValue(accountName: defaultSecretAccountName, labelName: defaultSecretLabelName, secretValue: defaultSecretValue)
        XCTAssertEqual(defaultSecretValue, try SimpleKiiManagerSt.shared.getMultipleSecrets(accountName: defaultSecretAccountName, labelName: defaultSecretLabelName).first?.secretValue)
        XCTAssertEqual(processedAction, .added)
    }
    
    func test02UpdateExistingSecret() throws {
        let processedAction = try SimpleKiiManagerSt.shared.addOrUpdateSecretValue(accountName: defaultSecretAccountName, labelName: defaultSecretLabelName, secretValue: default2SecretValue)
        XCTAssertEqual(default2SecretValue, try SimpleKiiManagerSt.shared.getMultipleSecrets(accountName: defaultSecretAccountName, labelName: defaultSecretLabelName).first?.secretValue)
        XCTAssertEqual(processedAction, .updated)
    }
    
    func test03DeleteSecret() {
        XCTAssertNoThrow(try SimpleKiiManagerSt.shared.removeSecret(accountName: defaultSecretAccountName))
        XCTAssertThrowsError(try SimpleKiiManagerSt.shared.removeSecret(accountName: defaultSecretAccountName)) { error in
            let purposeError = error as! KiiManagerError
            XCTAssertEqual(purposeError, KiiManagerError.entryNotFound("Requested secret not found"))
        }
    }
}

/**
 Test `ComfortKiiManager` implementation
 */
final class ComfortKiiManagerTests: XCTestCase {
    @ComfortKiiManager(accountName: "mySimpleSecret")
    var mySecret: String?
    
    func test01SetSecret() {
        mySecret = "thisIsMySuperSecretSecret"
        XCTAssertEqual(mySecret, "thisIsMySuperSecretSecret")
    }
    
    func test03UpdateSecret() {
        mySecret = "anotherSuperSecretSecret"
        XCTAssertEqual(mySecret, "anotherSuperSecretSecret")
        mySecret = nil
    }
}

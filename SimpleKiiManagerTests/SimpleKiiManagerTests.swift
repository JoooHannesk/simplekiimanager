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
        let mySecretResponse = try SimpleKiiManagerSt.shared.getSecret(serviceName: defaultSecretServiceName)
        XCTAssertNotNil(mySecretResponse)
        XCTAssertEqual(mySecretResponse.labelName, defaultSecretLabelName)
        XCTAssertEqual(mySecretResponse.serviceName, defaultSecretServiceName)
        XCTAssertEqual(mySecretResponse.accountName, default1SecretAccountName)
        XCTAssertEqual(mySecretResponse.secretValue, default1SecretValue)
        XCTAssertEqual(mySecretResponse.comment, default1comment)
    }
    
    func test02GetSecretBasedOnAccountName() throws {
        let mySecretResponse = try SimpleKiiManagerSt.shared.getSecret(accountName: default1SecretAccountName)
        XCTAssertNotNil(mySecretResponse)
        XCTAssertEqual(mySecretResponse.labelName, defaultSecretLabelName)
        XCTAssertEqual(mySecretResponse.serviceName, defaultSecretServiceName)
        XCTAssertEqual(mySecretResponse.accountName, default1SecretAccountName)
        XCTAssertEqual(mySecretResponse.secretValue, default1SecretValue)
        XCTAssertEqual(mySecretResponse.comment, default1comment)
    }
    
    func test03UpdateSecret() {
        XCTAssertNoThrow(try SimpleKiiManagerSt.shared.updateSecret(accountName: default1SecretAccountName, labelName: defaultSecretLabelName, serviceName: defaultSecretServiceName,
                                                                    newLabelName: newLabelName, newServiceName: new1SecretServiceName, newAccountName: new1SecretAccountName, newSecretValue: new1SecretValue, newComment: new1comment))
    }
    
    func test04GetUpdatedSecret() throws {
        let mySecretResponse = try SimpleKiiManagerSt.shared.getSecret(labelName: newLabelName)
        XCTAssertNotNil(mySecretResponse)
        XCTAssertEqual(mySecretResponse.labelName, newLabelName)
        XCTAssertEqual(mySecretResponse.serviceName, new1SecretServiceName)
        XCTAssertEqual(mySecretResponse.accountName, new1SecretAccountName)
        XCTAssertEqual(mySecretResponse.secretValue, new1SecretValue)
        XCTAssertEqual(mySecretResponse.comment, new1comment)
    }
    
    func test05DeleteSecret() throws {
        try SimpleKiiManagerSt.shared.removeSecret(accountName: new1SecretAccountName)
        XCTAssertThrowsError(try SimpleKiiManagerSt.shared.removeSecret(accountName: new1SecretAccountName))
    }
    
    func test06GetSecretWithMissingIdentifier() {
        XCTAssertThrowsError(try SimpleKiiManagerSt.shared.getSecret(accountName: nil, labelName: nil, serviceName: nil))
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
    
    func test01AddOrUpdateNewSecret() {
        XCTAssertNoThrow(try SimpleKiiManagerSt.shared.addOrUpdateSecretValue(accountName: defaultSecretAccountName, labelName: defaultSecretLabelName, secretValue: defaultSecretValue))
        XCTAssertEqual(defaultSecretValue, try SimpleKiiManagerSt.shared.getSecret(accountName: defaultSecretAccountName, labelName: defaultSecretLabelName).secretValue)
    }
    
    func test02UpdateExistingSecret() {
        XCTAssertNoThrow(try SimpleKiiManagerSt.shared.addOrUpdateSecretValue(accountName: defaultSecretAccountName, labelName: defaultSecretLabelName, secretValue: default2SecretValue))
        XCTAssertEqual(default2SecretValue, try SimpleKiiManagerSt.shared.getSecret(accountName: defaultSecretAccountName, labelName: defaultSecretLabelName).secretValue)
    }
    
    func test03DeleteSecret() {
        XCTAssertNoThrow(try SimpleKiiManagerSt.shared.removeSecret(accountName: defaultSecretAccountName))
        XCTAssertThrowsError(try SimpleKiiManagerSt.shared.removeSecret(accountName: defaultSecretAccountName))
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

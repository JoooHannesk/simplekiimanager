//
//  SimpleKiiManagerTests.swift
//  SimpleKiiManagerStTests
//
//  Created by Johannes Kinzig on 25.12.24.
//

import XCTest
@testable import SimpleKiiManager

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
    
    func testa01AddSecret1DefaultFunctionSignature() {
        XCTAssertNoThrow(try SimpleKiiManagerSt.shared.addSecret(labelName: defaultSecretLabelName, serviceName: defaultSecretServiceName, accountName: default1SecretAccountName, secretValue: default1SecretValue, comment: default1comment))
    }
    
    func testa02GetSecretDefaultFunctionSignature() throws {
        let mySecretResponse = try SimpleKiiManagerSt.shared.getSecret(serviceName: defaultSecretServiceName)
        XCTAssertNotNil(mySecretResponse)
        XCTAssertEqual(mySecretResponse.labelName, defaultSecretLabelName)
        XCTAssertEqual(mySecretResponse.serviceName, defaultSecretServiceName)
        XCTAssertEqual(mySecretResponse.accountName, default1SecretAccountName)
        XCTAssertEqual(mySecretResponse.secretValue, default1SecretValue)
        XCTAssertEqual(mySecretResponse.comment, default1comment)
    }
    
    func testa03UpdateSecret() {
        XCTAssertNoThrow(try SimpleKiiManagerSt.shared.updateSecret(labelName: defaultSecretLabelName, serviceName: defaultSecretServiceName, accountName: default1SecretAccountName,
                                                                    newLabelName: newLabelName, newServiceName: new1SecretServiceName, newAccountName: new1SecretAccountName, newSecret: new1SecretValue, newComment: new1comment))
    }
    
    func testa04GetUpdatedSecret() throws {
        let mySecretResponse = try SimpleKiiManagerSt.shared.getSecret(labelName: newLabelName)
        XCTAssertNotNil(mySecretResponse)
        XCTAssertEqual(mySecretResponse.labelName, newLabelName)
        XCTAssertEqual(mySecretResponse.serviceName, new1SecretServiceName)
        XCTAssertEqual(mySecretResponse.accountName, new1SecretAccountName)
        XCTAssertEqual(mySecretResponse.secretValue, new1SecretValue)
        XCTAssertEqual(mySecretResponse.comment, new1comment)
    }
    
    func testa05DeleteSecret() throws {
        try SimpleKiiManagerSt.shared.removeSecret(labelName: newLabelName)
        XCTAssertThrowsError(try SimpleKiiManagerSt.shared.removeSecret(labelName: newLabelName))
    }
    
    func testa06GetSecretWithMissingIdentifier() {
        XCTAssertThrowsError(try SimpleKiiManagerSt.shared.getSecret(labelName: nil, serviceName: nil, accountName: nil))
    }
}

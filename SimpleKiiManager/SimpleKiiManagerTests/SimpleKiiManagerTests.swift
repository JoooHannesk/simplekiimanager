//
//  SimpleKiiManagerTests.swift
//  SimpleKiiManagerStTests
//
//  Created by Johannes Kinzig on 25.12.24.
//

import XCTest
@testable import SimpleKiiManager

final class SimpleKiiManagerStTests: XCTestCase {
    let defaultSecretServiceName = "SimpleKiiManagerServiceName"
    let default1SecretAccountName = "test1@account.com"
    let default1SecretValue = "ThisIsSuperSecretPassword1ForTestingPurpose."
    let default1comment = "This is a comment for test1."
    
    func test01AddSecret1DefaultFunctionSignature() {
        XCTAssertNoThrow(try SimpleKiiManagerSt.shared.addSecret(serviceName: defaultSecretServiceName, accountName: default1SecretAccountName, secretValue: default1SecretValue, comment: default1comment))
    }
    
    func test02GetSecretDefaultFunctionSignature() throws {
        let mySecretResponse = try SimpleKiiManagerSt.shared.getSecret(serviceName: defaultSecretServiceName)
        XCTAssertNotNil(mySecretResponse)
        XCTAssertEqual(mySecretResponse.serviceName, defaultSecretServiceName)
        XCTAssertEqual(mySecretResponse.accountName, default1SecretAccountName)
        XCTAssertEqual(mySecretResponse.secretValue, default1SecretValue)
        XCTAssertEqual(mySecretResponse.comment, default1comment)
    }
    
    func test03UpdateSecret() {
        
    }
    
    func test04DeleteSecret() {
        
    }
    
    func test05GetSecretWithMissingIdentifier() {
        XCTAssertThrowsError(try SimpleKiiManagerSt.shared.getSecret(serviceName: nil, accountName: nil))
    }
}

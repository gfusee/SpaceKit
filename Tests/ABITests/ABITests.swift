import SpaceKit
import XCTest
import Foundation

@Codable struct User {
    let name: Buffer
    let balance: BigUint
}

@Codable struct Account {
    let address: Address
    let user: User
}

@Codable enum UserType {
    case staker
    case admin
}

@Codable enum DepositType {
    case none
    case egld(BigUint)
    case esdt(Buffer, UInt64, BigUint)
}

final class ABITests: XCTestCase {

    func testGetSimpleStructABIPart() throws {
        let userAbi = User._extractABIType!
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted.union(.sortedKeys)

        let jsonData = try! jsonEncoder.encode(userAbi)
        let json = String(data: jsonData, encoding: .utf8)!
        
        let expected = """
        {
          "fields" : [
            {
              "name" : "name",
              "type" : "bytes"
            },
            {
              "name" : "balance",
              "type" : "BigUint"
            }
          ],
          "type" : "struct"
        }
        """
        
        XCTAssertEqual(json, expected)
    }
    
    func testGetSimpleEnumABIPart() throws {
        let userAbi = UserType._extractABIType!
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted.union(.sortedKeys)

        let jsonData = try! jsonEncoder.encode(userAbi)
        let json = String(data: jsonData, encoding: .utf8)!
        
        let expected = """
        {
          "type" : "enum",
          "variants" : [
            {
              "discriminant" : 0,
              "name" : "staker"
            },
            {
              "discriminant" : 1,
              "name" : "admin"
            }
          ]
        }
        """
        
        XCTAssertEqual(json, expected)
    }
    
    func testGetStructWithOtherStructABIPart() throws {
        let userAbi = Account._extractABIType!
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted.union(.sortedKeys)

        let jsonData = try! jsonEncoder.encode(userAbi)
        let json = String(data: jsonData, encoding: .utf8)!
        
        let expected = """
        {
          "fields" : [
            {
              "name" : "address",
              "type" : "Address"
            },
            {
              "name" : "user",
              "type" : "User"
            }
          ],
          "type" : "struct"
        }
        """
        
        XCTAssertEqual(json, expected)
    }
    
    func testGetEnumWithAssociatedValuesABIPart() throws {
        let userAbi = DepositType._extractABIType!
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted.union(.sortedKeys)

        let jsonData = try! jsonEncoder.encode(userAbi)
        let json = String(data: jsonData, encoding: .utf8)!
        
        let expected = """
        {
          "type" : "enum",
          "variants" : [
            {
              "discriminant" : 0,
              "name" : "none"
            },
            {
              "discriminant" : 1,
              "fields" : [
                {
                  "name" : "0",
                  "type" : "BigUint"
                }
              ],
              "name" : "egld"
            },
            {
              "discriminant" : 2,
              "fields" : [
                {
                  "name" : "0",
                  "type" : "bytes"
                },
                {
                  "name" : "1",
                  "type" : "u64"
                },
                {
                  "name" : "2",
                  "type" : "BigUint"
                }
              ],
              "name" : "esdt"
            }
          ]
        }
        """
        
        XCTAssertEqual(json, expected)
    }
    
    func testGetAllDeclaredTypes() throws {
        // Scans the runtime to find all the @Codable types
        // declared from the smart contract dev or any dependency used such as SpaceKit
        let exportableTypes = getAllABIExportableTypes()
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted.union(.sortedKeys)

        let jsonData = try! jsonEncoder.encode(exportableTypes)
        let json = String(data: jsonData, encoding: .utf8)!
        
        let expected = """
        {
          "Account" : {
            "fields" : [
              {
                "name" : "address",
                "type" : "Address"
              },
              {
                "name" : "user",
                "type" : "User"
              }
            ],
            "type" : "struct"
          },
          "DepositType" : {
            "type" : "enum",
            "variants" : [
              {
                "discriminant" : 0,
                "name" : "none"
              },
              {
                "discriminant" : 1,
                "fields" : [
                  {
                    "name" : "0",
                    "type" : "BigUint"
                  }
                ],
                "name" : "egld"
              },
              {
                "discriminant" : 2,
                "fields" : [
                  {
                    "name" : "0",
                    "type" : "bytes"
                  },
                  {
                    "name" : "1",
                    "type" : "u64"
                  },
                  {
                    "name" : "2",
                    "type" : "BigUint"
                  }
                ],
                "name" : "esdt"
              }
            ]
          },
          "TokenPayment" : {
            "fields" : [
              {
                "name" : "tokenIdentifier",
                "type" : "bytes"
              },
              {
                "name" : "nonce",
                "type" : "u64"
              },
              {
                "name" : "amount",
                "type" : "BigUint"
              }
            ],
            "type" : "struct"
          },
          "User" : {
            "fields" : [
              {
                "name" : "name",
                "type" : "bytes"
              },
              {
                "name" : "balance",
                "type" : "BigUint"
              }
            ],
            "type" : "struct"
          },
          "UserType" : {
            "type" : "enum",
            "variants" : [
              {
                "discriminant" : 0,
                "name" : "staker"
              },
              {
                "discriminant" : 1,
                "name" : "admin"
              }
            ]
          }
        }
        """
        
        XCTAssertEqual(json, expected)
    }
}


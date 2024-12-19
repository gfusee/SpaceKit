import SpaceKit
import XCTest
import Foundation

@Controller struct AdderController {
    @Storage(key: "sum") var sum: BigUint
    
    public mutating func add(value: BigUint) {
        self.sum += value
    }

    public func getSum() -> BigUint {
        self.sum
    }
}

@Controller struct MultiValueController {
    public func returnMultiValues(
        values: MultiValueEncoded<BigUint>
    ) -> MultiValueEncoded<BigUint> {
        values
    }
    
    public func returnOptionalValue(
        optValue: OptionalArgument<BigUint>
    ) -> OptionalArgument<BigUint> {
        optValue
    }
}

@Controller struct OnlyOwnerController {
    public func onlyOwnerEndpoint() {
        assertOwner()
    }
    
    public func onlyOwnerEndpointWithSpaceKit() {
        SpaceKit.assertOwner()
    }
    
    public func onlyOwnerEndpointWithComment() {
        // This is a dummy comment
        assertOwner()
    }
    
    public func notOnlyOwnerEndpointBecauseIsAtSecondStatement() {
        _ = BigUint(integerLiteral: 3) + 6
        assertOwner()
    }
}

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
        
        let jsonEncoder = ABIJSONEncoder()

        let jsonData = try! jsonEncoder.encode(userAbi)
        let json = String(data: jsonData, encoding: .utf8)!
        
        let expected = """
        {
          "type" : "struct",
          "fields" : [
            {
              "name" : "name",
              "type" : "bytes"
            },
            {
              "name" : "balance",
              "type" : "BigUint"
            }
          ]
        }
        """
        
        XCTAssertEqual(json, expected)
    }
    
    func testGetSimpleEnumABIPart() throws {
        let userAbi = UserType._extractABIType!
        
        let jsonEncoder = ABIJSONEncoder()

        let jsonData = try! jsonEncoder.encode(userAbi)
        let json = String(data: jsonData, encoding: .utf8)!
        
        let expected = """
        {
          "type" : "enum",
          "variants" : [
            {
              "name" : "staker",
              "discriminant" : 0
            },
            {
              "name" : "admin",
              "discriminant" : 1
            }
          ]
        }
        """
        
        XCTAssertEqual(json, expected)
    }
    
    func testGetStructWithOtherStructABIPart() throws {
        let userAbi = Account._extractABIType!
        
        let jsonEncoder = ABIJSONEncoder()

        let jsonData = try! jsonEncoder.encode(userAbi)
        let json = String(data: jsonData, encoding: .utf8)!
        
        let expected = """
        {
          "type" : "struct",
          "fields" : [
            {
              "name" : "address",
              "type" : "Address"
            },
            {
              "name" : "user",
              "type" : "User"
            }
          ]
        }
        """
        
        XCTAssertEqual(json, expected)
    }
    
    func testGetEnumWithAssociatedValuesABIPart() throws {
        let userAbi = DepositType._extractABIType!
        
        let jsonEncoder = ABIJSONEncoder()

        let jsonData = try! jsonEncoder.encode(userAbi)
        let json = String(data: jsonData, encoding: .utf8)!
        
        let expected = """
        {
          "type" : "enum",
          "variants" : [
            {
              "name" : "none",
              "discriminant" : 0
            },
            {
              "name" : "egld",
              "discriminant" : 1,
              "fields" : [
                {
                  "name" : "0",
                  "type" : "BigUint"
                }
              ]
            },
            {
              "name" : "esdt",
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
              ]
            }
          ]
        }
        """
        
        XCTAssertEqual(json, expected)
    }
    
    func testGetAllDeclaredTypes() throws {
        // Scans the runtime to find all the @Codable types
        // declared by the smart contract dev or any dependency used such as SpaceKit
        let exportableTypes = getAllABIExportableTypes()
        
        let jsonEncoder = ABIJSONEncoder()

        let jsonData = try! jsonEncoder.encode(exportableTypes)
        let json = String(data: jsonData, encoding: .utf8)!
        
        let expected = """
        {
          "Account" : {
            "type" : "struct",
            "fields" : [
              {
                "name" : "address",
                "type" : "Address"
              },
              {
                "name" : "user",
                "type" : "User"
              }
            ]
          },
          "DepositType" : {
            "type" : "enum",
            "variants" : [
              {
                "name" : "none",
                "discriminant" : 0
              },
              {
                "name" : "egld",
                "discriminant" : 1,
                "fields" : [
                  {
                    "name" : "0",
                    "type" : "BigUint"
                  }
                ]
              },
              {
                "name" : "esdt",
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
                ]
              }
            ]
          },
          "TokenPayment" : {
            "type" : "struct",
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
            ]
          },
          "User" : {
            "type" : "struct",
            "fields" : [
              {
                "name" : "name",
                "type" : "bytes"
              },
              {
                "name" : "balance",
                "type" : "BigUint"
              }
            ]
          },
          "UserType" : {
            "type" : "enum",
            "variants" : [
              {
                "name" : "staker",
                "discriminant" : 0
              },
              {
                "name" : "admin",
                "discriminant" : 1
              }
            ]
          }
        }
        """
        
        XCTAssertEqual(json, expected)
    }
    
    func testGetSimpleControllerABIPart() throws {
        let controllerAbi = AdderController._extractABIEndpoints
        
        let jsonEncoder = ABIJSONEncoder()

        let jsonData = try! jsonEncoder.encode(controllerAbi)
        let json = String(data: jsonData, encoding: .utf8)!
        
        let expected = """
        [
          {
            "name" : "add",
            "mutability" : "mutable",
            "payableInTokens" : [
              "*"
            ],
            "inputs" : [
              {
                "name" : "value",
                "type" : "BigUint"
              }
            ],
            "outputs" : [

            ]
          },
          {
            "name" : "getSum",
            "mutability" : "mutable",
            "payableInTokens" : [
              "*"
            ],
            "inputs" : [

            ],
            "outputs" : [
              {
                "type" : "BigUint"
              }
            ]
          }
        ]
        """
        
        XCTAssertEqual(json, expected)
    }
    
    func testGetMultiValueControllerABIPart() throws {
        let controllerAbi = MultiValueController._extractABIEndpoints
        
        let jsonEncoder = ABIJSONEncoder()

        let jsonData = try! jsonEncoder.encode(controllerAbi)
        let json = String(data: jsonData, encoding: .utf8)!
        
        let expected = """
        [
          {
            "name" : "returnMultiValues",
            "mutability" : "mutable",
            "payableInTokens" : [
              "*"
            ],
            "inputs" : [
              {
                "name" : "values",
                "type" : "variadic<BigUint>",
                "multi_arg" : true
              }
            ],
            "outputs" : [
              {
                "type" : "variadic<BigUint>",
                "multi_result" : true
              }
            ]
          },
          {
            "name" : "returnOptionalValue",
            "mutability" : "mutable",
            "payableInTokens" : [
              "*"
            ],
            "inputs" : [
              {
                "name" : "optValue",
                "type" : "optional<BigUint>",
                "multi_arg" : true
              }
            ],
            "outputs" : [
              {
                "type" : "optional<BigUint>",
                "multi_result" : true
              }
            ]
          }
        ]
        """
        
        XCTAssertEqual(json, expected)
    }
    
    func testGetOnlyOwnerControllerABIPart() throws {
        let controllerAbi = OnlyOwnerController._extractABIEndpoints
        
        let jsonEncoder = ABIJSONEncoder()

        let jsonData = try! jsonEncoder.encode(controllerAbi)
        let json = String(data: jsonData, encoding: .utf8)!
        
        print(json)
        
        let expected = """
        [
          {
            "name" : "onlyOwnerEndpoint",
            "onlyOwner" : true,
            "mutability" : "mutable",
            "payableInTokens" : [
              "*"
            ],
            "inputs" : [

            ],
            "outputs" : [

            ]
          },
          {
            "name" : "onlyOwnerEndpointWithSpaceKit",
            "onlyOwner" : true,
            "mutability" : "mutable",
            "payableInTokens" : [
              "*"
            ],
            "inputs" : [

            ],
            "outputs" : [

            ]
          },
          {
            "name" : "onlyOwnerEndpointWithComment",
            "onlyOwner" : true,
            "mutability" : "mutable",
            "payableInTokens" : [
              "*"
            ],
            "inputs" : [

            ],
            "outputs" : [

            ]
          },
          {
            "name" : "notOnlyOwnerEndpointBecauseIsAtSecondStatement",
            "mutability" : "mutable",
            "payableInTokens" : [
              "*"
            ],
            "inputs" : [

            ],
            "outputs" : [

            ]
          }
        ]
        """
        
        XCTAssertEqual(json, expected)
    }

    func testGetAllDeclaredControllersABIParts() throws {
        // Scans the runtime to find all the @Controller types
        // declared by the smart contract dev
        let exportableEndpoints = getAllABIExportableEndpoints()
        
        let jsonEncoder = ABIJSONEncoder()

        let jsonData = try! jsonEncoder.encode(exportableEndpoints)
        let json = String(data: jsonData, encoding: .utf8)!
        
        print(json)
        
        let expected = """
        [
          {
            "name" : "onlyOwnerEndpoint",
            "onlyOwner" : true,
            "mutability" : "mutable",
            "payableInTokens" : [
              "*"
            ],
            "inputs" : [

            ],
            "outputs" : [

            ]
          },
          {
            "name" : "onlyOwnerEndpointWithSpaceKit",
            "onlyOwner" : true,
            "mutability" : "mutable",
            "payableInTokens" : [
              "*"
            ],
            "inputs" : [

            ],
            "outputs" : [

            ]
          },
          {
            "name" : "onlyOwnerEndpointWithComment",
            "onlyOwner" : true,
            "mutability" : "mutable",
            "payableInTokens" : [
              "*"
            ],
            "inputs" : [

            ],
            "outputs" : [

            ]
          },
          {
            "name" : "notOnlyOwnerEndpointBecauseIsAtSecondStatement",
            "mutability" : "mutable",
            "payableInTokens" : [
              "*"
            ],
            "inputs" : [

            ],
            "outputs" : [

            ]
          },
          {
            "name" : "returnMultiValues",
            "mutability" : "mutable",
            "payableInTokens" : [
              "*"
            ],
            "inputs" : [
              {
                "name" : "values",
                "type" : "variadic<BigUint>",
                "multi_arg" : true
              }
            ],
            "outputs" : [
              {
                "type" : "variadic<BigUint>",
                "multi_result" : true
              }
            ]
          },
          {
            "name" : "returnOptionalValue",
            "mutability" : "mutable",
            "payableInTokens" : [
              "*"
            ],
            "inputs" : [
              {
                "name" : "optValue",
                "type" : "optional<BigUint>",
                "multi_arg" : true
              }
            ],
            "outputs" : [
              {
                "type" : "optional<BigUint>",
                "multi_result" : true
              }
            ]
          },
          {
            "name" : "add",
            "mutability" : "mutable",
            "payableInTokens" : [
              "*"
            ],
            "inputs" : [
              {
                "name" : "value",
                "type" : "BigUint"
              }
            ],
            "outputs" : [

            ]
          },
          {
            "name" : "getSum",
            "mutability" : "mutable",
            "payableInTokens" : [
              "*"
            ],
            "inputs" : [

            ],
            "outputs" : [
              {
                "type" : "BigUint"
              }
            ]
          }
        ]
        """
        
        XCTAssertEqual(json, expected)
    }
}


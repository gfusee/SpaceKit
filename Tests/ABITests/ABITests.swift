import XCTest
import SpaceKit
import Foundation

@Init func initialize(initialValue: BigUint) {
    var controller = AdderController()
    
    controller.sum = initialValue
}

@Controller public struct AdderController {
    @Storage(key: "sum") var sum: BigUint
    
    public mutating func add(value: BigUint) {
        self.sum += value
    }

    public func getSum() -> BigUint {
        self.sum
    }
}

@Controller public struct MultiValueController {
    public func acceptTwoValues(
        firstValue: Buffer,
        secondValue: BigUint
    ) {}
    
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

@Controller public struct OnlyOwnerController {
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

@Codable public struct User {
    let name: Buffer
    let balance: BigUint
}

@Codable public struct Account {
    let address: Address
    let user: User
}

@Codable public enum UserType {
    case staker
    case admin
}

@Codable public enum DepositType {
    case none
    case egld(BigUint)
    case esdt(Buffer, UInt64, BigUint)
}

@Event public struct NoDataEvent {
    let firstIndexedValue: Buffer
    let secondIndexedValue: BigUint
}

@Event(dataType: Bool) public struct DataEvent {
    let firstIndexedValue: Buffer
    let secondIndexedValue: BigUint
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
    
    func testGetMultiValueControllerABIPart() throws {
        let controllerAbi = MultiValueController._extractABIEndpoints
        
        let jsonEncoder = ABIJSONEncoder()

        let jsonData = try! jsonEncoder.encode(controllerAbi)
        let json = String(data: jsonData, encoding: .utf8)!
        
        let expected = """
        [
          {
            "name" : "acceptTwoValues",
            "mutability" : "mutable",
            "payableInTokens" : [
              "*"
            ],
            "inputs" : [
              {
                "name" : "firstValue",
                "type" : "bytes"
              },
              {
                "name" : "secondValue",
                "type" : "BigUint"
              }
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

    func testGetEventWithoutDataABIPart() throws {
        let eventABI = NoDataEvent._extractABIEvent
        
        let jsonEncoder = ABIJSONEncoder()

        let jsonData = try! jsonEncoder.encode(eventABI)
        let json = String(data: jsonData, encoding: .utf8)!
        
        let expected = """
        {
          "identifier" : "NoDataEvent",
          "inputs" : [
            {
              "name" : "firstIndexedValue",
              "type" : "bytes",
              "indexed" : true
            },
            {
              "name" : "secondIndexedValue",
              "type" : "BigUint",
              "indexed" : true
            }
          ]
        }
        """
        
        XCTAssertEqual(json, expected)
    }
    
    func testGetEventWithDataABIPart() throws {
        let eventABI = DataEvent._extractABIEvent
        
        let jsonEncoder = ABIJSONEncoder()

        let jsonData = try! jsonEncoder.encode(eventABI)
        let json = String(data: jsonData, encoding: .utf8)!
        
        let expected = """
        {
          "identifier" : "DataEvent",
          "inputs" : [
            {
              "name" : "firstIndexedValue",
              "type" : "bytes",
              "indexed" : true
            },
            {
              "name" : "secondIndexedValue",
              "type" : "BigUint",
              "indexed" : true
            },
            {
              "name" : "_data",
              "type" : "bool"
            }
          ]
        }
        """
        
        XCTAssertEqual(json, expected)
    }
}


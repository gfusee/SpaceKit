import SpaceKit
import XCTest

@Controller struct MultiArgsController {
    @Storage(key: "concatenated") var concatenated: Buffer
    
    public mutating func endpointWithOnlyMultiValueEncoded(value: MultiValueEncoded<Buffer>) {
        var concatenated = Buffer()
        
        value.forEach { buffer in
            concatenated = concatenated.appended(buffer)
        }
        
        self.concatenated = concatenated
    }
    
    public mutating func endpointWithBigUintAndMultiValueEncoded(biguint: BigUint, value: MultiValueEncoded<Buffer>) {
        var concatenated = biguint.toBuffer()
        
        value.forEach { buffer in
            concatenated = concatenated.appended(buffer)
        }
        
        self.concatenated = concatenated
    }
    
    public func getConcatenated() -> Buffer {
        self.concatenated
    }
    
    public func getDummyMultiValueEncoded() -> MultiValueEncoded<Buffer> {
        var result = MultiValueEncoded<Buffer>()
        
        result = result.appended(value: "Hello")
        result = result.appended(value: " World")
        result = result.appended(value: " !")
        
        return result
    }
}

final class MultiArgsTests: ContractTestCase {

    override var initialAccounts: [WorldAccount] {
        [
            WorldAccount(address: "contract")
        ]
    }

    func testMultiValueEncodedWithNoArgument() throws {
        var contract = try self.deployContract(MultiArgsContract.self, at: "contract")
        
        try contract.endpointWithOnlyMultiValueEncoded(value: MultiValueEncoded())

        let result = try contract.getConcatenated()

        XCTAssertEqual(result, "")
    }
    
    func testMultiValueEncodedWithOneArgument() throws {
        var contract = try self.deployContract(MultiArgsContract.self, at: "contract")
        
        var input = MultiValueEncoded<Buffer>()
        input = input.appended(value: "Hello")
        
        try contract.endpointWithOnlyMultiValueEncoded(value: input)

        let result = try contract.getConcatenated()

        XCTAssertEqual(result, "Hello")
    }
    
    func testMultiValueEncodedWithMultipleArguments() throws {
        var contract = try self.deployContract(MultiArgsContract.self, at: "contract")
        
        var input = MultiValueEncoded<Buffer>()
        input = input.appended(value: "Hello")
        input = input.appended(value: " World")
        input = input.appended(value: " !")
        
        try contract.endpointWithOnlyMultiValueEncoded(value: input)

        let result = try contract.getConcatenated()

        XCTAssertEqual(result, "Hello World !")
    }
    
    func testMultiValueEncodedWithMultipleArgumentsAndArgsBefore() throws {
        var contract = try self.deployContract(MultiArgsContract.self, at: "contract")
        
        var input = MultiValueEncoded<Buffer>()
        input = input.appended(value: "Hello")
        input = input.appended(value: " World")
        input = input.appended(value: " !")
        
        try contract.endpointWithBigUintAndMultiValueEncoded(biguint: 5, value: input)

        let result = try contract.getConcatenated()

        XCTAssertEqual(result, "5Hello World !")
    }
    
    func getMultiValueEncoded() throws {
        let contract = try self.deployContract(MultiArgsContract.self, at: "contract")

        let result = try contract.getDummyMultiValueEncoded()
        
        var expected = MultiValueEncoded<Buffer>()
        expected = expected.appended(value: "Hello")
        expected = expected.appended(value: " World")
        expected = expected.appended(value: " !")

        XCTAssertEqual(result, expected)
    }
    
}

import SpaceKit
import SpaceKitTesting

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
            WorldAccount(
                address: "contract",
                controllers: [
                    MultiArgsController.self
                ]
            )
        ]
    }

    func testMultiValueEncodedWithNoArgument() throws {
        try self.deployContract(at: "contract")
        var controller = self.instantiateController(MultiArgsController.self, for: "contract")!
        
        try controller.endpointWithOnlyMultiValueEncoded(value: MultiValueEncoded())

        let result = try controller.getConcatenated()

        XCTAssertEqual(result, "")
    }
    
    func testMultiValueEncodedWithOneArgument() throws {
        try self.deployContract(at: "contract")
        var controller = self.instantiateController(MultiArgsController.self, for: "contract")!
        
        var input = MultiValueEncoded<Buffer>()
        input = input.appended(value: "Hello")
        
        try controller.endpointWithOnlyMultiValueEncoded(value: input)

        let result = try controller.getConcatenated()

        XCTAssertEqual(result, "Hello")
    }
    
    func testMultiValueEncodedWithMultipleArguments() throws {
        try self.deployContract(at: "contract")
        var controller = self.instantiateController(MultiArgsController.self, for: "contract")!
        
        var input = MultiValueEncoded<Buffer>()
        input = input.appended(value: "Hello")
        input = input.appended(value: " World")
        input = input.appended(value: " !")
        
        try controller.endpointWithOnlyMultiValueEncoded(value: input)

        let result = try controller.getConcatenated()

        XCTAssertEqual(result, "Hello World !")
    }
    
    func testMultiValueEncodedWithMultipleArgumentsAndArgsBefore() throws {
        try self.deployContract(at: "contract")
        var controller = self.instantiateController(MultiArgsController.self, for: "contract")!
        
        var input = MultiValueEncoded<Buffer>()
        input = input.appended(value: "Hello")
        input = input.appended(value: " World")
        input = input.appended(value: " !")
        
        try controller.endpointWithBigUintAndMultiValueEncoded(biguint: 5, value: input)

        let result = try controller.getConcatenated()

        XCTAssertEqual(result, "5Hello World !")
    }
    
    func getMultiValueEncoded() throws {
        try self.deployContract(at: "contract")
        let controller = self.instantiateController(MultiArgsController.self, for: "contract")!

        let result = try controller.getDummyMultiValueEncoded()
        
        var expected = MultiValueEncoded<Buffer>()
        expected = expected.appended(value: "Hello")
        expected = expected.appended(value: " World")
        expected = expected.appended(value: " !")

        XCTAssertEqual(result, expected)
    }
    
}

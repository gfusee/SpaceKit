import SpaceKitTesting

// There was an issue with @Codable macro on structs or enums that has comments on its fields
// The struct here is only here to check if it compiles
@Codable public struct TestStruct {
    let field: Buffer // Dummy comment
}

@Controller public struct CodableMacroStructImplTestsController {
    public func testTopDecodeForCustomInputTooLargeError() {
        let input = Buffer(data: Array("0000000a5346542d616263646566000000000000000a000000016400".hexadecimal))
        let _ = TokenPayment(topDecode: input)
    }
}

final class CodableMacroStructImplTests: ContractTestCase {

    override var initialAccounts: [WorldAccount] {
        [
            WorldAccount(
                address: "contract",
                controllers: [
                    CodableMacroStructImplTestsController.self
                ]
            )
        ]
    }
    
    func testTopEncodeForCustomStruct() throws {
        let tokenPayment = TokenPayment(tokenIdentifier: "SFT-abcdef", nonce: 10, amount: 100)
        var result = Buffer()
        tokenPayment.topEncode(output: &result)
        
        let expected = "0000000a5346542d616263646566000000000000000a0000000164"
        
        XCTAssertEqual(result.hexDescription, expected)
    }
    
    func testNestedEncodeForCustomStruct() throws {
        let tokenPayment = TokenPayment(tokenIdentifier: "SFT-abcdef", nonce: 10, amount: 100)
        var result = Buffer()
        tokenPayment.depEncode(dest: &result)
        
        let expected = "0000000a5346542d616263646566000000000000000a0000000164"
        
        XCTAssertEqual(result.hexDescription, expected)
    }
    
    func testTopDecodeForCustomStruct() throws {
        let input = Buffer(data: Array("0000000a5346542d616263646566000000000000000a0000000164".hexadecimal))
        let result = TokenPayment(topDecode: input)
        
        let expected = TokenPayment(tokenIdentifier: "SFT-abcdef", nonce: 10, amount: 100)
        
        XCTAssertEqual(result, expected)
    }
    
    func testTopDecodeForCustomInputTooLargeError() throws {
        do {
            try self.deployContract(at: "contract")
            let controller = self.instantiateController(CodableMacroStructImplTestsController.self, for: "contract")!
            
            try controller.testTopDecodeForCustomInputTooLargeError()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Top decode error for TokenPayment: input too large."))
        }
    }
    
    func testNestedDecodeForCustomStruct() throws {
        var input = BufferNestedDecodeInput(buffer: Buffer(data: Array("0000000a5346542d616263646566000000000000000a0000000164".hexadecimal)))
        let result = TokenPayment(depDecode: &input)
        
        let expected = TokenPayment(tokenIdentifier: "SFT-abcdef", nonce: 10, amount: 100)
        
        XCTAssertEqual(result, expected)
    }
    
    func testNestedDecodeForTwoCustomStructs() throws {
        var input = BufferNestedDecodeInput(buffer: Buffer(data: Array("0000000a5346542d616263646566000000000000000a00000001640000000a5346542d616263646566000000000000000a0000000203e8".hexadecimal)))
        let result1 = TokenPayment(depDecode: &input)
        let result2 = TokenPayment(depDecode: &input)
        
        let expected1 = TokenPayment(tokenIdentifier: "SFT-abcdef", nonce: 10, amount: 100)
        let expected2 = TokenPayment(tokenIdentifier: "SFT-abcdef", nonce: 10, amount: 1000)
        
        XCTAssertEqual(result1, expected1)
        XCTAssertEqual(result2, expected2)
    }
    
}

import MultiversX
import XCTest

@Contract struct CodableMacroStructImplTestsContract {
    public func testTopDecodeForCustomInputTooLargeError() {
        let input = MXBuffer(data: Array("0000000a5346542d616263646566000000000000000a000000016400".hexadecimal))
        let _ = TokenPayment(topDecode: input)
    }
}

final class CodableMacroStructImplTests: ContractTestCase {

    override var initialAccounts: [WorldAccount] {
        [
            WorldAccount(address: "contract")
        ]
    }
    
    func testTopEncodeForCustomStruct() throws {
        let tokenPayment = TokenPayment.new(tokenIdentifier: "SFT-abcdef", nonce: 10, amount: 100)
        var result = MXBuffer()
        tokenPayment.topEncode(output: &result)
        
        let expected = "0000000a5346542d616263646566000000000000000a0000000164"
        
        XCTAssertEqual(result.hexDescription, expected)
    }
    
    func testNestedEncodeForCustomStruct() throws {
        let tokenPayment = TokenPayment.new(tokenIdentifier: "SFT-abcdef", nonce: 10, amount: 100)
        var result = MXBuffer()
        tokenPayment.depEncode(dest: &result)
        
        let expected = "0000000a5346542d616263646566000000000000000a0000000164"
        
        XCTAssertEqual(result.hexDescription, expected)
    }
    
    func testTopDecodeForCustomStruct() throws {
        let input = MXBuffer(data: Array("0000000a5346542d616263646566000000000000000a0000000164".hexadecimal))
        let result = TokenPayment(topDecode: input)
        
        let expected = TokenPayment.new(tokenIdentifier: "SFT-abcdef", nonce: 10, amount: 100)
        
        XCTAssertEqual(result, expected)
    }
    
    func testTopDecodeForCustomInputTooLargeError() throws {
        do {
            try CodableMacroStructImplTestsContract.testable("contract").testTopDecodeForCustomInputTooLargeError()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Top decode error for TokenPayment: input too large."))
        }
    }
    
    func testNestedDecodeForCustomStruct() throws {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("0000000a5346542d616263646566000000000000000a0000000164".hexadecimal)))
        let result = TokenPayment(depDecode: &input)
        
        let expected = TokenPayment.new(tokenIdentifier: "SFT-abcdef", nonce: 10, amount: 100)
        
        XCTAssertEqual(result, expected)
    }
    
    func testNestedDecodeForTwoCustomStructs() throws {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("0000000a5346542d616263646566000000000000000a00000001640000000a5346542d616263646566000000000000000a0000000203e8".hexadecimal)))
        let result1 = TokenPayment(depDecode: &input)
        let result2 = TokenPayment(depDecode: &input)
        
        let expected1 = TokenPayment.new(tokenIdentifier: "SFT-abcdef", nonce: 10, amount: 100)
        let expected2 = TokenPayment.new(tokenIdentifier: "SFT-abcdef", nonce: 10, amount: 1000)
        
        XCTAssertEqual(result1, expected1)
        XCTAssertEqual(result2, expected2)
    }
    
}

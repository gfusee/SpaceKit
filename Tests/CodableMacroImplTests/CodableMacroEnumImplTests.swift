import SpaceKit
import SpaceKitTesting

// There was an issue with @Codable macro on enums that has only one case
// The struct here is only here to check if it compiles
@Codable enum TestEnumWithOnlyOneCase {
    case firstCase
}

// There was an issue with @Codable macro on structs or enums that has comments on its fields
// The struct here is only here to check if it compiles
@Codable enum TestEnumWithComment {
    case firstCase // Dummy comment
    case secondCase
}

@Codable enum PaymentType: Equatable {
    case egld
    case esdt, multiEsdts
}

@Codable enum SinglePayment: Equatable {
    case egld(BigUint)
    case esdt(Buffer, UInt64, BigUint), none
}

@Controller struct CodableMacroEnumImplTestsController {
    public func testTopDecodeForEnumInputTooLargeError() {
        let input = Buffer(data: Array("010000000a5346542d61626364656600000000000000050000000203e800".hexadecimal))
        let _ = PaymentType(topDecode: input)
    }
}

final class CodableMacroEnumImplTests: ContractTestCase {

    override var initialAccounts: [WorldAccount] {
        [
            WorldAccount(
                address: "contract",
                controllers: [
                    CodableMacroEnumImplTestsController.self
                ]
            )
        ]
    }
    
    func testTopEncodeForEnumWithoutAssociatedValue() throws {
        let tokenType = PaymentType.multiEsdts
        var result = Buffer()
        tokenType.topEncode(output: &result)
        
        let expected = "02"
        
        XCTAssertEqual(result.hexDescription, expected)
    }
    
    func testTopEncodeForEnumWithOneAssociatedValue() throws {
        let singlePayment = SinglePayment.egld(1000)
        var result = Buffer()
        singlePayment.topEncode(output: &result)
        
        let expected = "000000000203e8"
        
        XCTAssertEqual(result.hexDescription, expected)
    }
    
    func testTopEncodeForEnumWithMultipleAssociatedValues() throws {
        let singlePayment = SinglePayment.esdt("SFT-abcdef", 5, 1000)
        var result = Buffer()
        singlePayment.topEncode(output: &result)
        
        let expected = "010000000a5346542d61626364656600000000000000050000000203e8"
        
        XCTAssertEqual(result.hexDescription, expected)
    }
    
    func testNestedEncodeForEnumWithoutAssociatedValue() throws {
        let tokenType = PaymentType.multiEsdts
        var result = Buffer()
        tokenType.depEncode(dest: &result)
        
        let expected = "02"
        
        XCTAssertEqual(result.hexDescription, expected)
    }
    
    func testNestedEncodeForEnumWithOneAssociatedValue() throws {
        let singlePayment = SinglePayment.egld(1000)
        var result = Buffer()
        singlePayment.depEncode(dest: &result)
        
        let expected = "000000000203e8"
        
        XCTAssertEqual(result.hexDescription, expected)
    }
    
    func testNestedEncodeForEnumWithMultipleAssociatedValues() throws {
        let singlePayment = SinglePayment.esdt("SFT-abcdef", 5, 1000)
        var result = Buffer()
        singlePayment.depEncode(dest: &result)
        
        let expected = "010000000a5346542d61626364656600000000000000050000000203e8"
        
        XCTAssertEqual(result.hexDescription, expected)
    }
    
    func testTopDecodeForEnumWithoutAssociatedValue() throws {
        let input = Buffer(data: Array("01".hexadecimal))
        let result = PaymentType(topDecode: input)
        
        let expected = PaymentType.esdt
        
        XCTAssertEqual(result, expected)
    }
    
    func testTopDecodeForEnumWithOneAssociatedValue() throws {
        let input = Buffer(data: Array("000000000203e8".hexadecimal))
        let result = SinglePayment(topDecode: input)
        
        let expected = SinglePayment.egld(1000)
        
        XCTAssertEqual(result, expected)
    }
    
    func testTopDecodeForEnumWithMultipleAssociatedValues() throws {
        let input = Buffer(data: Array("010000000a5346542d61626364656600000000000000050000000203e8".hexadecimal))
        let result = SinglePayment(topDecode: input)
        
        let expected = SinglePayment.esdt("SFT-abcdef", 5, 1000)
        
        XCTAssertEqual(result, expected)
    }
    
    func testTopDecodeForEnumInputTooLargeError() throws {
        do {
            try self.deployContract(at: "contract")
            let controller = self.instantiateController(CodableMacroEnumImplTestsController.self, for: "contract")!
            
            try controller.testTopDecodeForEnumInputTooLargeError()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Top decode error for PaymentType: input too large."))
        }
    }
    
    func testNestedDecodeForEnumWithoutAssociatedValue() throws {
        var input = BufferNestedDecodeInput(buffer: Buffer(data: Array("01".hexadecimal)))
        let result = PaymentType(depDecode: &input)
        
        let expected = PaymentType.esdt
        
        XCTAssertEqual(result, expected)
    }
    
    func testNestedDecodeForEnumWithOneAssociatedValue() throws {
        var input = BufferNestedDecodeInput(buffer: Buffer(data: Array("000000000203e8".hexadecimal)))
        let result = SinglePayment(depDecode: &input)
        
        let expected = SinglePayment.egld(1000)
        
        XCTAssertEqual(result, expected)
    }
    
    func testNestedDecodeForEnumWithMultipleAssociatedValues() throws {
        var input = BufferNestedDecodeInput(buffer: Buffer(data: Array("010000000a5346542d61626364656600000000000000050000000203e8".hexadecimal)))
        let result = SinglePayment(depDecode: &input)
        
        let expected = SinglePayment.esdt("SFT-abcdef", 5, 1000)
        
        XCTAssertEqual(result, expected)
    }
    
    func testNestedDecodeForThreeEnumsWithoutAssociatedValue() throws {
        var input = BufferNestedDecodeInput(buffer: Buffer(data: Array("010000000a5346542d61626364656600000000000000050000000203e8000000000203e802".hexadecimal)))
        let result1 = SinglePayment(depDecode: &input)
        let result2 = SinglePayment(depDecode: &input)
        let result3 = SinglePayment(depDecode: &input)
        
        let expected1 = SinglePayment.esdt("SFT-abcdef", 5, 1000)
        let expected2 = SinglePayment.egld(1000)
        let expected3 = SinglePayment.none
        
        XCTAssertEqual(result1, expected1)
        XCTAssertEqual(result2, expected2)
        XCTAssertEqual(result3, expected3)
    }
    
    func testNestedDecodeForThreeEnumsWithAssociatedValues() throws {
        var input = BufferNestedDecodeInput(buffer: Buffer(data: Array("010002".hexadecimal)))
        let result1 = PaymentType(depDecode: &input)
        let result2 = PaymentType(depDecode: &input)
        let result3 = PaymentType(depDecode: &input)
        
        let expected1 = PaymentType.esdt
        let expected2 = PaymentType.egld
        let expected3 = PaymentType.multiEsdts
        
        XCTAssertEqual(result1, expected1)
        XCTAssertEqual(result2, expected2)
        XCTAssertEqual(result3, expected3)
    }
    
}

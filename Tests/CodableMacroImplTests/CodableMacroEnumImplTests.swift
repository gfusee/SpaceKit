import MultiversX
import XCTest

@Codable enum PaymentType: Equatable {
    case egld
    case esdt, multiEsdts
}

@Codable enum SinglePayment: Equatable {
    case egld(BigUint)
    case esdt(MXBuffer, UInt64, BigUint), none
}

final class CodableMacroEnumImplTests: XCTestCase {
    
    func testTopEncodeForEnumWithoutAssociatedValue() throws {
        let tokenType = PaymentType.multiEsdts
        var result = MXBuffer()
        tokenType.topEncode(output: &result)
        
        let expected = "02"
        
        XCTAssertEqual(result.hexDescription, expected)
    }
    
    func testTopEncodeForEnumWithOneAssociatedValue() throws {
        let singlePayment = SinglePayment.egld(1000)
        var result = MXBuffer()
        singlePayment.topEncode(output: &result)
        
        let expected = "000000000203e8"
        
        XCTAssertEqual(result.hexDescription, expected)
    }
    
    func testTopEncodeForEnumWithMultipleAssociatedValues() throws {
        let singlePayment = SinglePayment.esdt("SFT-abcdef", 5, 1000)
        var result = MXBuffer()
        singlePayment.topEncode(output: &result)
        
        let expected = "010000000a5346542d61626364656600000000000000050000000203e8"
        
        XCTAssertEqual(result.hexDescription, expected)
    }
    
    func testNestedEncodeForEnumWithoutAssociatedValue() throws {
        let tokenType = PaymentType.multiEsdts
        var result = MXBuffer()
        tokenType.depEncode(dest: &result)
        
        let expected = "02"
        
        XCTAssertEqual(result.hexDescription, expected)
    }
    
    func testNestedEncodeForEnumWithOneAssociatedValue() throws {
        let singlePayment = SinglePayment.egld(1000)
        var result = MXBuffer()
        singlePayment.depEncode(dest: &result)
        
        let expected = "000000000203e8"
        
        XCTAssertEqual(result.hexDescription, expected)
    }
    
    func testNestedEncodeForEnumWithMultipleAssociatedValues() throws {
        let singlePayment = SinglePayment.esdt("SFT-abcdef", 5, 1000)
        var result = MXBuffer()
        singlePayment.depEncode(dest: &result)
        
        let expected = "010000000a5346542d61626364656600000000000000050000000203e8"
        
        XCTAssertEqual(result.hexDescription, expected)
    }
    
    func testTopDecodeForEnumWithoutAssociatedValue() throws {
        let input = MXBuffer(data: Array("000000000203e8".hexadecimal))
        let result = SinglePayment.topDecode(input: input)
        
        let expected = SinglePayment.egld(1000)
        
        XCTAssertEqual(result, expected)
    }
    
    func testTopDecodeForEnumWithOneAssociatedValue() throws {
        let input = MXBuffer(data: Array("01".hexadecimal))
        let result = PaymentType.topDecode(input: input)
        
        let expected = PaymentType.esdt
        
        XCTAssertEqual(result, expected)
    }
    
    func testTopDecodeForEnumWithMultipleAssociatedValues() throws {
        let input = MXBuffer(data: Array("010000000a5346542d61626364656600000000000000050000000203e8".hexadecimal))
        let result = SinglePayment.topDecode(input: input)
        
        let expected = SinglePayment.esdt("SFT-abcdef", 5, 1000)
        
        XCTAssertEqual(result, expected)
    }
    
    func testNestedDecodeForEnumWithoutAssociatedValue() throws {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("01".hexadecimal)))
        let result = PaymentType.depDecode(input: &input)
        
        let expected = PaymentType.esdt
        
        XCTAssertEqual(result, expected)
    }
    
    func testNestedDecodeForEnumWithOneAssociatedValue() throws {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("000000000203e8".hexadecimal)))
        let result = SinglePayment.depDecode(input: &input)
        
        let expected = SinglePayment.egld(1000)
        
        XCTAssertEqual(result, expected)
    }
    
    func testNestedDecodeForEnumWithMultipleAssociatedValues() throws {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("010000000a5346542d61626364656600000000000000050000000203e8".hexadecimal)))
        let result = SinglePayment.depDecode(input: &input)
        
        let expected = SinglePayment.esdt("SFT-abcdef", 5, 1000)
        
        XCTAssertEqual(result, expected)
    }
    
    func testNestedDecodeForThreeEnumsWithoutAssociatedValue() throws {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("010000000a5346542d61626364656600000000000000050000000203e8000000000203e802".hexadecimal)))
        let result1 = SinglePayment.depDecode(input: &input)
        let result2 = SinglePayment.depDecode(input: &input)
        let result3 = SinglePayment.depDecode(input: &input)
        
        let expected1 = SinglePayment.esdt("SFT-abcdef", 5, 1000)
        let expected2 = SinglePayment.egld(1000)
        let expected3 = SinglePayment.none
        
        XCTAssertEqual(result1, expected1)
        XCTAssertEqual(result2, expected2)
        XCTAssertEqual(result3, expected3)
    }
    
    func testNestedDecodeForThreeEnumsWithAssociatedValues() throws {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("010002".hexadecimal)))
        let result1 = PaymentType.depDecode(input: &input)
        let result2 = PaymentType.depDecode(input: &input)
        let result3 = PaymentType.depDecode(input: &input)
        
        let expected1 = PaymentType.esdt
        let expected2 = PaymentType.egld
        let expected3 = PaymentType.multiEsdts
        
        XCTAssertEqual(result1, expected1)
        XCTAssertEqual(result2, expected2)
        XCTAssertEqual(result3, expected3)
    }
    
}

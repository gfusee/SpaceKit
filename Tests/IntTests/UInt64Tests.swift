import XCTest
import MultiversX

@Contract struct UInt64TestsContract {
    public func testTopDecodeUInt64TooLargeBufferShouldFail() {
        let input = MXBuffer(data: Array("000000000000000000".hexadecimal))
        let _ = UInt64(topDecode: input)
    }
    
    public func testNestedDecodeUInt64EmptyBufferShouldFail() {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("".hexadecimal)))
        let _ = UInt64(depDecode: &input)
    }
    
    public func testNestedDecodeUInt64TooSmallBufferShouldFail() {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("00000000000000".hexadecimal)))
        let _ = UInt64(depDecode: &input)
    }
    
    public func testNestedDecodeTwoUInt64sTooSmallBufferShouldFail() {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("00000000000003e800000000000000".hexadecimal)))
        let _ = UInt64(depDecode: &input)
        let _ = UInt64(depDecode: &input)
    }
}

final class UInt64Tests: ContractTestCase {

    override var initialAccounts: [WorldAccount] {
        [
            WorldAccount(address: "contract")
        ]
    }
    
    func testTopEncodeUInt64Zero() throws {
        var output = MXBuffer()
        let value: UInt64 = 0
        
        value.topEncode(output: &output)
        
        let expected = ""
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testTopEncodeUInt64One() throws {
        var output = MXBuffer()
        let value: UInt64 = 1
        
        value.topEncode(output: &output)
        
        let expected = "01"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testTopEncodeUInt64Ten() throws {
        var output = MXBuffer()
        let value: UInt64 = 10
        
        value.topEncode(output: &output)
        
        let expected = "0a"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testTopEncodeUInt64Thousand() throws {
        var output = MXBuffer()
        let value: UInt64 = 1000
        
        value.topEncode(output: &output)
        
        let expected = "03e8"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testTopEncodeUInt64Max() throws {
        var output = MXBuffer()
        let value = UInt64.max
        
        value.topEncode(output: &output)
        
        let expected = "ffffffffffffffff"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testNestedEncodeUInt64Zero() throws {
        var output = MXBuffer()
        let value: UInt64 = 0
        
        value.depEncode(dest: &output)
        
        let expected = "0000000000000000"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testNestedEncodeUInt64One() throws {
        var output = MXBuffer()
        let value: UInt64 = 1
        
        value.depEncode(dest: &output)
        
        let expected = "0000000000000001"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testNestedEncodeUInt64Ten() throws {
        var output = MXBuffer()
        let value: UInt64 = 10
        
        value.depEncode(dest: &output)
        
        let expected = "000000000000000a"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testNestedEncodeUInt64Thousand() throws {
        var output = MXBuffer()
        let value: UInt64 = 1000
        
        value.depEncode(dest: &output)
        
        let expected = "00000000000003e8"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testNestedEncodeUInt64Max() throws {
        var output = MXBuffer()
        let value = UInt64.max
        
        value.depEncode(dest: &output)
        
        let expected = "ffffffffffffffff"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testTopDecodeUInt64EmptyBuffer() throws {
        let input = MXBuffer(data: Array("00".hexadecimal))
        let result = UInt64(topDecode: input)
        
        let expected: UInt64 = 0
        
        XCTAssertEqual(result, expected)
    }
    
    func testTopDecodeUInt64Zero() throws {
        let input = MXBuffer(data: Array("00".hexadecimal))
        let result = UInt64(topDecode: input)
        
        let expected: UInt64 = 0
        
        XCTAssertEqual(result, expected)
    }
    
    func testTopDecodeUInt64One() throws {
        let input = MXBuffer(data: Array("01".hexadecimal))
        let result = UInt64(topDecode: input)
        
        let expected: UInt64 = 1
        
        XCTAssertEqual(result, expected)
    }
    
    func testTopDecodeUInt64Thousand() throws {
        let input = MXBuffer(data: Array("03e8".hexadecimal))
        let result = UInt64(topDecode: input)
        
        let expected: UInt64 = 1000
        
        XCTAssertEqual(result, expected)
    }
    
    func testTopDecodeUInt64Max() throws {
        let input = MXBuffer(data: Array("ffffffffffffffff".hexadecimal))
        let result = UInt64(topDecode: input)
        
        let expected = UInt64.max
        
        XCTAssertEqual(result, expected)
    }
    
    func testTopDecodeUInt64TooLargeBufferShouldFail() throws {
        do {
            try UInt64TestsContract.testable("contract").testTopDecodeUInt64TooLargeBufferShouldFail()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Cannot decode UInt64: input too large."))
        }
    }
    
    func testNestedDecodeUInt64Zero() throws {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("0000000000000000".hexadecimal)))
        let result = UInt64(depDecode: &input)
        
        let expected: UInt64 = 0
        
        XCTAssertEqual(result, expected)
    }
    
    func testNestedDecodeUInt64One() throws {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("0000000000000001".hexadecimal)))
        let result = UInt64(depDecode: &input)
        
        let expected: UInt64 = 1
        
        XCTAssertEqual(result, expected)
    }
    
    func testNestedDecodeUInt64Thousand() throws {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("00000000000003e8".hexadecimal)))
        let result = UInt64(depDecode: &input)
        
        let expected: UInt64 = 1000
        
        XCTAssertEqual(result, expected)
    }
    
    func testNestedDecodeUInt64Max() throws {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("ffffffffffffffff".hexadecimal)))
        let result = UInt64(depDecode: &input)
        
        let expected = UInt64.max
        
        XCTAssertEqual(result, expected)
    }
    
    func testNestedDecodeUInt64EmptyBufferShouldFail() throws {
        do {
            try UInt64TestsContract.testable("contract").testNestedDecodeUInt64EmptyBufferShouldFail()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Index out of range."))
        }
    }
    
    func testNestedDecodeUInt64TooSmallBufferShouldFail() throws {
        do {
            try UInt64TestsContract.testable("contract").testNestedDecodeUInt64TooSmallBufferShouldFail()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Index out of range."))
        }
    }
    
    func testNestedDecodeUInt64ThousandTooLargeBuffer() throws {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("00000000000003e800000064".hexadecimal)))
        let result = UInt64(depDecode: &input)
        
        let expected: UInt64 = 1000
        
        XCTAssertEqual(result, expected)
    }
    
    func testNestedDecodeTwoUInt64s() throws {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("00000000000003e80000000000000064".hexadecimal)))
        let result1 = UInt64(depDecode: &input)
        let result2 = UInt64(depDecode: &input)
        
        let expected1: UInt64 = 1000
        let expected2: UInt64 = 100
        
        XCTAssertEqual(result1, expected1)
        XCTAssertEqual(result2, expected2)
    }
    
    func testNestedDecodeTwoUInt64sTooSmallBufferShouldFail() throws {
        do {
            try UInt64TestsContract.testable("contract").testNestedDecodeTwoUInt64sTooSmallBufferShouldFail()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Index out of range."))
        }
    }
    
    func testFixedArrayToUInt64WithZero() throws {
        var array = getZeroedBytes8()
        let result = toBigEndianUInt64(from: array)
        
        let expected: UInt64 = 0
        
        XCTAssertEqual(result, expected)
    }
    
    func testFixedArrayToUInt64WithOne() throws {
        var array = getZeroedBytes8()
        array.7 = 1
        let result = toBigEndianUInt64(from: array)
        
        let expected: UInt64 = 1
        
        XCTAssertEqual(result, expected)
    }
    
    func testFixedArrayToUInt64WithTen() throws {
        var array = getZeroedBytes8()
        array.7 = 10
        let result = toBigEndianUInt64(from: array)
        
        let expected: UInt64 = 10
        
        XCTAssertEqual(result, expected)
    }
    
    func testFixedArrayToUInt64WithThousand() throws {
        var array = getZeroedBytes8()
        
        array.6 = 3
        array.7 = 232
        
        let result = toBigEndianUInt64(from: array)
        
        let expected: UInt64 = 1000
        
        XCTAssertEqual(result, expected)
    }
    
    func testFixedArrayToUInt64WithUInt32Max() throws {
        var array = getZeroedBytes8()
        
        array.4 = 255
        array.5 = 255
        array.6 = 255
        array.7 = 255
        
        let result = toBigEndianUInt64(from: array)
        
        let expected: UInt64 = UInt64(UInt32.max)
        
        XCTAssertEqual(result, expected)
    }
    
    func testFixedArrayToUInt64WithUInt64Max() throws {
        var array = getZeroedBytes8()
        
        array.0 = 255
        array.1 = 255
        array.2 = 255
        array.3 = 255
        array.4 = 255
        array.5 = 255
        array.6 = 255
        array.7 = 255
        
        let result = toBigEndianUInt64(from: array)
        
        let expected = UInt64.max
        
        XCTAssertEqual(result, expected)
    }
}

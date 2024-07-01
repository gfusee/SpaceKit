import XCTest
import MultiversX

@Contract struct IntTestsContract {
    public func testTopDecodeIntTooLargeBufferShouldFail() {
        let input = MXBuffer(data: Array("0001020304".hexadecimal))
        _ = Int(topDecode: input)
    }
    
    public func testNestedDecodeIntEmptyBufferShouldFail() {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("".hexadecimal)))
        let result = Int.depDecode(input: &input)
    }
    
    public func testNestedDecodeIntTooSmallBufferShouldFail() {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("000000".hexadecimal)))
        let result = Int.depDecode(input: &input)
    }
    
    public func testNestedDecodeTwoIntsTooSmallBufferShouldFail() {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("000003e8000000".hexadecimal)))
        let result1 = Int.depDecode(input: &input)
        let result2 = Int.depDecode(input: &input)
    }
}

final class IntTests: ContractTestCase {
    
    func testTopEncodeIntZero() throws {
        var output = MXBuffer()
        let value: Int = 0
        
        value.topEncode(output: &output)
        
        let expected = ""
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testTopEncodeIntOne() throws {
        var output = MXBuffer()
        let value: Int = 1
        
        value.topEncode(output: &output)
        
        let expected = "01"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testTopEncodeIntTen() throws {
        var output = MXBuffer()
        let value: Int = 10
        
        value.topEncode(output: &output)
        
        let expected = "0a"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testTopEncodeIntMinusThousand() throws {
        var output = MXBuffer()
        let value: Int = -1000
        
        value.topEncode(output: &output)
        
        let expected = "fc18"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testTopEncodeIntThousand() throws {
        var output = MXBuffer()
        let value: Int = 1000
        
        value.topEncode(output: &output)
        
        let expected = "03e8"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testTopEncodeIntMin() throws {
        var output = MXBuffer()
        let value: Int = Int(Int32.min)
        
        value.topEncode(output: &output)
        
        let expected = "80000000"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testTopEncodeIntMax() throws {
        var output = MXBuffer()
        let value: Int = Int(Int32.max)
        
        value.topEncode(output: &output)
        
        let expected = "7fffffff"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testNestedEncodeIntZero() throws {
        var output = MXBuffer()
        let value: Int = 0
        
        value.depEncode(dest: &output)
        
        let expected = "00000000"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testNestedEncodeIntOne() throws {
        var output = MXBuffer()
        let value: Int = 1
        
        value.depEncode(dest: &output)
        
        let expected = "00000001"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testNestedEncodeIntTen() throws {
        var output = MXBuffer()
        let value: Int = 10
        
        value.depEncode(dest: &output)
        
        let expected = "0000000a"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testNestedEncodeIntMinusThousand() throws {
        var output = MXBuffer()
        let value: Int = -1000
        
        value.depEncode(dest: &output)
        
        let expected = "fffffc18"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testNestedEncodeIntThousand() throws {
        var output = MXBuffer()
        let value: Int = 1000
        
        value.depEncode(dest: &output)
        
        let expected = "000003e8"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testNestedEncodeIntMax() throws {
        var output = MXBuffer()
        let value: Int = Int(Int32.max)
        
        value.depEncode(dest: &output)
        
        let expected = "7fffffff"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testTopDecodeIntEmpty() throws {
        let input = MXBuffer(data: Array("".hexadecimal))
        let result = Int(topDecode: input)
        
        let expected = 0
        
        XCTAssertEqual(result, expected)
    }
    
    func testTopDecodeIntZero() throws {
        let input = MXBuffer(data: Array("00".hexadecimal))
        let result = Int(topDecode: input)
        
        let expected = 0
        
        XCTAssertEqual(result, expected)
    }
    
    func testTopDecodeIntOne() throws {
        let input = MXBuffer(data: Array("01".hexadecimal))
        let result = Int(topDecode: input)
        
        let expected = 1
        
        XCTAssertEqual(result, expected)
    }
    
    func testTopDecodeIntMinusThousand() throws {
        let input = MXBuffer(data: Array("fc18".hexadecimal))
        let result = Int(topDecode: input)
        
        let expected = -1000
        
        XCTAssertEqual(result, expected)
    }
    
    func testTopDecodeIntThousand() throws {
        let input = MXBuffer(data: Array("03e8".hexadecimal))
        let result = Int(topDecode: input)
        
        let expected = 1000
        
        XCTAssertEqual(result, expected)
    }
    
    func testTopDecodeIntMin() throws {
        let input = MXBuffer(data: Array("80000000".hexadecimal))
        let result = Int(topDecode: input)
        
        let expected = Int(Int32.min)
        
        XCTAssertEqual(result, expected)
    }
    
    func testTopDecodeIntMax() throws {
        let input = MXBuffer(data: Array("7fffffff".hexadecimal))
        let result = Int(topDecode: input)
        
        let expected = Int(Int32.max)
        
        XCTAssertEqual(result, expected)
    }
    
    func testTopDecodeIntTooLargeBufferShouldFail() throws {
        do {
            try IntTestsContract.testable("").testTopDecodeIntTooLargeBufferShouldFail()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Cannot decode Int: input too large."))
        }
    }
    
    func testNestedDecodeIntZero() throws {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("00000000".hexadecimal)))
        let result = Int.depDecode(input: &input)
        
        let expected = 0
        
        XCTAssertEqual(result, expected)
    }
    
    func testNestedDecodeIntOne() throws {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("00000001".hexadecimal)))
        let result = Int.depDecode(input: &input)
        
        let expected = 1
        
        XCTAssertEqual(result, expected)
    }
    
    func testNestedDecodeIntMinusThousand() throws {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("fffffc18".hexadecimal)))
        let result = Int.depDecode(input: &input)
        
        let expected = -1000
        
        XCTAssertEqual(result, expected)
    }
    
    func testNestedDecodeIntThousand() throws {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("000003e8".hexadecimal)))
        let result = Int.depDecode(input: &input)
        
        let expected = 1000
        
        XCTAssertEqual(result, expected)
    }
    
    func testNestedDecodeIntMax() throws {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("7fffffff".hexadecimal)))
        let result = Int.depDecode(input: &input)
        
        let expected = Int(Int32.max)
        
        XCTAssertEqual(result, expected)
    }
    
    func testNestedDecodeIntEmptyBufferShouldFail() throws {
        do {
            try IntTestsContract.testable("").testNestedDecodeIntEmptyBufferShouldFail()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Index out of range."))
        }
    }
    
    func testNestedDecodeIntTooSmallBufferShouldFail() throws {
        do {
            try IntTestsContract.testable("").testNestedDecodeIntTooSmallBufferShouldFail()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Index out of range."))
        }
    }
    
    func testNestedDecodeIntThousandTooLargeBuffer() throws {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("000003e800000064".hexadecimal)))
        let result = Int.depDecode(input: &input)
        
        let expected = 1000
        
        XCTAssertEqual(result, expected)
    }
    
    func testNestedDecodeTwoInts() throws {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("000003e800000064".hexadecimal)))
        let result1 = Int.depDecode(input: &input)
        let result2 = Int.depDecode(input: &input)
        
        let expected1 = 1000
        let expected2 = 100
        
        XCTAssertEqual(result1, expected1)
        XCTAssertEqual(result2, expected2)
    }
    
    func testNestedDecodeTwoIntsTooSmallBufferShouldFail() throws {
        do {
            try IntTestsContract.testable("").testNestedDecodeTwoIntsTooSmallBufferShouldFail()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Index out of range."))
        }
    }
    
    func testFixedArrayToIntWithZero() throws {
        let array: FixedArray8<UInt8> = FixedArray8(count: 0)
        let result = array.toBigEndianInt()
        
        let expected: Int = 0
        
        XCTAssertEqual(result, expected)
    }
    
    func testFixedArrayToIntWithOne() throws {
        var array: FixedArray8<UInt8> = FixedArray8(count: 1)
        array[0] = 1
        let result = array.toBigEndianInt()
        
        let expected: Int = 1
        
        XCTAssertEqual(result, expected)
    }
    
    func testFixedArrayToIntWithTen() throws {
        var array: FixedArray8<UInt8> = FixedArray8(count: 1)
        array[0] = 10
        let result = array.toBigEndianInt()
        
        let expected: Int = 10
        
        XCTAssertEqual(result, expected)
    }
    
    func testFixedArrayToIntWithMinusThousand() throws {
        var array: FixedArray8<UInt8> = FixedArray8(count: 2)
        
        array[0] = 252
        array[1] = 24
        
        let result = array.toBigEndianInt()
        
        let expected: Int = -1000
        
        XCTAssertEqual(result, expected)
    }
    
    func testFixedArrayToIntWithThousand() throws {
        var array: FixedArray8<UInt8> = FixedArray8(count: 2)
        
        array[0] = 3
        array[1] = 232
        
        let result = array.toBigEndianInt()
        
        let expected: Int = 1000
        
        XCTAssertEqual(result, expected)
    }
    
    func testFixedArrayToIntWithMin() throws {
        var array: FixedArray8<UInt8> = FixedArray8(count: 4)
        
        array[0] = 128
        array[1] = 0
        array[2] = 0
        array[3] = 0
        
        let result = array.toBigEndianInt()
        
        let expected = Int(Int32.min)
        
        XCTAssertEqual(result, expected)
    }
    
    func testFixedArrayToIntWithMax() throws {
        var array: FixedArray8<UInt8> = FixedArray8(count: 4)
        
        array[0] = 127
        array[1] = 255
        array[2] = 255
        array[3] = 255
        
        let result = array.toBigEndianInt()
        
        let expected = Int(Int32.max)
        
        XCTAssertEqual(result, expected)
    }
}

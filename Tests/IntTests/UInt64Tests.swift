import XCTest
import MultiversX

final class UInt64Tests: XCTestCase {
    
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
        let value: Int = 1000
        
        value.depEncode(dest: &output)
        
        let expected = "00000000000003e8"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testNestedEncodeUInt64Max() throws {
        var output = MXBuffer()
        let value: Int = Int(Int32.max)
        
        value.depEncode(dest: &output)
        
        let expected = "ffffffffffffffff"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testNestedDecodeUInt64Zero() throws {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("0000000000000000".hexadecimal)))
        let result = UInt64.depDecode(input: &input)
        
        let expected: UInt64 = 0
        
        XCTAssertEqual(result, expected)
    }
    
    func testNestedDecodeUInt64One() throws {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("0000000000000001".hexadecimal)))
        let result = UInt64.depDecode(input: &input)
        
        let expected: UInt64 = 1
        
        XCTAssertEqual(result, expected)
    }
    
    func testNestedDecodeUInt64Thousand() throws {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("00000000000003e8".hexadecimal)))
        let result = UInt64.depDecode(input: &input)
        
        let expected: UInt64 = 1000
        
        XCTAssertEqual(result, expected)
    }
    
    func testNestedDecodeUInt64Max() throws {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("ffffffffffffffff".hexadecimal)))
        let result = UInt64.depDecode(input: &input)
        
        let expected = UInt64.max
        
        XCTAssertEqual(result, expected)
    }
    
    func testNestedDecodeUInt64EmptyBufferShouldFail() throws {
        do {
            try runFailableTransactions {
                var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("".hexadecimal)))
                let result = UInt64.depDecode(input: &input)
            }
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Index out of range."))
        }
    }
    
    func testNestedDecodeUInt64TooSmallBufferShouldFail() throws {
        do {
            try runFailableTransactions {
                var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("00000000000000".hexadecimal)))
                let result = UInt64.depDecode(input: &input)
            }
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Index out of range."))
        }
    }
    
    func testNestedDecodeUInt64ThousandTooLargeBuffer() throws {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("00000000000003e800000064".hexadecimal)))
        let result = UInt64.depDecode(input: &input)
        
        let expected: UInt64 = 1000
        
        XCTAssertEqual(result, expected)
    }
    
    func testNestedDecodeTwoUInt64s() throws {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("00000000000003e80000000000000064".hexadecimal)))
        let result1 = UInt64.depDecode(input: &input)
        let result2 = UInt64.depDecode(input: &input)
        
        let expected1: UInt64 = 1000
        let expected2: UInt64 = 100
        
        XCTAssertEqual(result1, expected1)
        XCTAssertEqual(result2, expected2)
    }
    
    func testNestedDecodeTwoUInt64sTooSmallBufferShouldFail() throws {
        do {
            try runFailableTransactions {
                var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("00000000000003e800000000000000".hexadecimal)))
                let result1 = UInt64.depDecode(input: &input)
                let result2 = UInt64.depDecode(input: &input)
            }
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Index out of range."))
        }
    }
}

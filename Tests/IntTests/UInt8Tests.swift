import XCTest
import MultiversX

@Contract struct UInt8TestsContract {
    public func testTopDecodeUInt8TooLargeBufferShouldFail() {
        let input = MXBuffer(data: Array("0000".hexadecimal))
        let _ = UInt8.topDecode(input: input)
    }
    
    public func testNestedDecodeUInt8EmptyBufferShouldFail() {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("".hexadecimal)))
        let _ = UInt8.depDecode(input: &input)
    }
    
    public func testNestedDecodeTwoUInt8sTooSmallBufferShouldFail() {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("03".hexadecimal)))
        let _ = UInt8.depDecode(input: &input)
        let _ = UInt8.depDecode(input: &input)
    }
}

final class UInt8Tests: ContractTestCase {
    
    func testTopEncodeUInt8Zero() throws {
        var output = MXBuffer()
        let value: UInt8 = 0
        
        value.topEncode(output: &output)
        
        let expected = "00"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testTopEncodeUInt8One() throws {
        var output = MXBuffer()
        let value: UInt8 = 1
        
        value.topEncode(output: &output)
        
        let expected = "01"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testTopEncodeUInt8Ten() throws {
        var output = MXBuffer()
        let value: UInt8 = 10
        
        value.topEncode(output: &output)
        
        let expected = "0a"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testTopEncodeUInt8Max() throws {
        var output = MXBuffer()
        let value = UInt8.max
        
        value.topEncode(output: &output)
        
        let expected = "ff"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testNestedEncodeUInt8Zero() throws {
        var output = MXBuffer()
        let value: UInt8 = 0
        
        value.depEncode(dest: &output)
        
        let expected = "00"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testNestedEncodeUInt8One() throws {
        var output = MXBuffer()
        let value: UInt8 = 1
        
        value.depEncode(dest: &output)
        
        let expected = "01"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testNestedEncodeUInt8Ten() throws {
        var output = MXBuffer()
        let value: UInt8 = 10
        
        value.depEncode(dest: &output)
        
        let expected = "0a"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testNestedEncodeUInt8Max() throws {
        var output = MXBuffer()
        let value = UInt8.max
        
        value.depEncode(dest: &output)
        
        let expected = "ff"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testTopDecodeUInt8EmptyBuffer() throws {
        let input = MXBuffer(data: Array("00".hexadecimal))
        let result = UInt8.topDecode(input: input)
        
        let expected: UInt8 = 0
        
        XCTAssertEqual(result, expected)
    }
    
    func testTopDecodeUInt8Zero() throws {
        let input = MXBuffer(data: Array("00".hexadecimal))
        let result = UInt8.topDecode(input: input)
        
        let expected: UInt8 = 0
        
        XCTAssertEqual(result, expected)
    }
    
    func testTopDecodeUInt8One() throws {
        let input = MXBuffer(data: Array("01".hexadecimal))
        let result = UInt8.topDecode(input: input)
        
        let expected: UInt8 = 1
        
        XCTAssertEqual(result, expected)
    }
    
    func testTopDecodeUInt8Max() throws {
        let input = MXBuffer(data: Array("ff".hexadecimal))
        let result = UInt8.topDecode(input: input)
        
        let expected = UInt8.max
        
        XCTAssertEqual(result, expected)
    }
    
    func testTopDecodeUInt8TooLargeBufferShouldFail() throws {
        do {
            try UInt8TestsContract.testable("").testTopDecodeUInt8TooLargeBufferShouldFail()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Cannot decode UInt8: input too large."))
        }
    }
    
    func testNestedDecodeUInt8Zero() throws {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("00".hexadecimal)))
        let result = UInt8.depDecode(input: &input)
        
        let expected: UInt8 = 0
        
        XCTAssertEqual(result, expected)
    }
    
    func testNestedDecodeUInt8One() throws {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("01".hexadecimal)))
        let result = UInt8.depDecode(input: &input)
        
        let expected: UInt8 = 1
        
        XCTAssertEqual(result, expected)
    }
    
    func testNestedDecodeUInt8Max() throws {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("ff".hexadecimal)))
        let result = UInt8.depDecode(input: &input)
        
        let expected = UInt8.max
        
        XCTAssertEqual(result, expected)
    }
    
    func testNestedDecodeUInt8EmptyBufferShouldFail() throws {
        do {
            try UInt8TestsContract.testable("").testNestedDecodeUInt8EmptyBufferShouldFail()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Index out of range."))
        }
    }
    
    func testNestedDecodeTwoUInt8s() throws {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("0364".hexadecimal)))
        let result1 = UInt8.depDecode(input: &input)
        let result2 = UInt8.depDecode(input: &input)
        
        let expected1: UInt8 = 3
        let expected2: UInt8 = 100
        
        XCTAssertEqual(result1, expected1)
        XCTAssertEqual(result2, expected2)
    }
    
    func testNestedDecodeTwoUInt8sTooSmallBufferShouldFail() throws {
        do {
            try UInt8TestsContract.testable("").testNestedDecodeTwoUInt8sTooSmallBufferShouldFail()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Index out of range."))
        }
    }
}

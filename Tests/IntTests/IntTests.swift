import XCTest
import MultiversX

final class IntTests: XCTestCase {
    
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
    
    func testTopEncodeIntThousand() throws {
        var output = MXBuffer()
        let value: Int = 1000
        
        value.topEncode(output: &output)
        
        let expected = "03e8"
        
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
            try runFailableTransactions {
                var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("".hexadecimal)))
                let result = Int.depDecode(input: &input)
            }
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Index out of range."))
        }
    }
    
    func testNestedDecodeIntTooSmallBufferShouldFail() throws {
        do {
            try runFailableTransactions {
                var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("000000".hexadecimal)))
                let result = Int.depDecode(input: &input)
            }
            
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
            try runFailableTransactions {
                var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("000003e8000000".hexadecimal)))
                let result1 = Int.depDecode(input: &input)
                let result2 = Int.depDecode(input: &input)
            }
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Index out of range."))
        }
    }
}

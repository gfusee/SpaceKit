import XCTest
import MultiversX

final class BufferTests: XCTestCase {
    func testEmptyBuffer() throws {
        let buffer = MXBuffer()

        XCTAssertEqual(buffer, "")
    }
    
    func testNonEmptyBuffer() throws {
        let buffer = MXBuffer("Hello World!")
        
        XCTAssertEqual(buffer, "Hello World!")
    }
    
    func testEmptyBufferFromHexadecimalData() throws {
        let buffer = MXBuffer(data: Array("".hexadecimal))

        XCTAssertEqual(buffer, "")
    }
    
    func testNonEmptyBufferFromHexadecimalData() throws {
        let buffer = MXBuffer(data: Array("48656c6c6f20576f726c6421".hexadecimal))
        
        XCTAssertEqual(buffer, "Hello World!")
    }
    
    func testEmptyBufferCount() throws {
        let buffer = MXBuffer()

        XCTAssertEqual(buffer.count, 0)
    }
    
    func testNonEmptyBufferCount() throws {
        let buffer = MXBuffer("Hello World!")
        
        XCTAssertEqual(buffer.count, 12)
    }
    
    func testLiteralEmptyBuffer() throws {
        let buffer: MXBuffer = ""
        
        XCTAssertEqual(buffer, "")
    }
    
    func testLiteralNonEmptyBuffer() throws {
        let buffer: MXBuffer = "Hello World!"
        
        XCTAssertEqual(buffer, "Hello World!")
    }
    
    func testEmptyBufferToBytes() throws {
        let buffer: MXBuffer = ""
        let bytes = buffer.toBytes()
        
        let expected = [UInt8]()
        
        XCTAssertEqual(bytes, expected)
    }
    
    func testNonEmptyBufferToBytes() throws {
        let buffer: MXBuffer = "Hello World!"
        let bytes = buffer.toBytes()
        
        let expected = Array("Hello World!".utf8)
        
        XCTAssertEqual(bytes, expected)
    }
    
    func testBufferAppend() throws {
        var buffer: MXBuffer = "Hello"
        buffer.append(MXBuffer(" World!"))
        
        XCTAssertEqual(buffer, "Hello World!")
    }
    
    func testBufferWithBufferInterpolation() throws {
        var buffer: MXBuffer = "World!"
        buffer = "Hello \(buffer)"
        
        XCTAssertEqual(buffer, "Hello World!")
    }
    
    func testBufferWithBigUintInterpolation() throws {
        let biguint: BigUint = 100
        let buffer: MXBuffer = "Hello \(biguint)!"
        
        XCTAssertEqual(buffer, "Hello 100!")
    }
    
    func testCompareDifferentBuffers() throws {
        let buffer1 = "Hello"
        let buffer2 = "World!"
        
        XCTAssertNotEqual(buffer1, buffer2)
    }
    
    func testEmptyBufferTopEncode() throws {
        let buffer: MXBuffer = ""
        var output = MXBuffer()
        
        buffer.topEncode(output: &output)
        
        XCTAssertEqual(output, "")
    }
    
    func testNonEmptyBufferTopEncode() throws {
        let buffer: MXBuffer = "Hello World!"
        var output = MXBuffer()
        
        buffer.topEncode(output: &output)
        
        XCTAssertEqual(output, "Hello World!")
    }
    
    func testEmptyBufferTopDecode() throws {
        let input: MXBuffer = ""
        let buffer = MXBuffer.topDecode(input: input)
        
        XCTAssertEqual(buffer, "")
    }
    
    func testNonEmptyBufferTopDecode() throws {
        let input: MXBuffer = "Hello World!"
        let buffer = MXBuffer.topDecode(input: input)
        
        XCTAssertEqual(buffer, "Hello World!")
    }
}

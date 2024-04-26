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
}

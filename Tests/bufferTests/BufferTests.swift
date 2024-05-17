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
    
    func testBufferFromEmptyData() throws {
        let buffer = MXBuffer(data: [])
        
        XCTAssertEqual(buffer, "")
    }
    
    func testBufferFromNonEmptyData() throws {
        let buffer = MXBuffer(data: [4, 7, 1, 2])
        
        XCTAssertEqual(buffer.hexDescription, "04070102")
    }
    
    func testBufferFromZerosData() throws {
        let buffer = MXBuffer(data: [0, 0, 0, 0])
        
        XCTAssertEqual(buffer.hexDescription, "00000000")
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
    
    func testNonEmptyBufferGetZeroLengthSubBuffer() throws {
        let buffer: MXBuffer = "Hello World!"
        let subBuffer = buffer.getSubBuffer(startIndex: 2, length: 0)
        
        let expected: MXBuffer = ""
        
        XCTAssertEqual(subBuffer, expected)
    }
    
    func testNonEmptyBufferGetTooLongSubBufferShouldFail() throws {
        do {
            try runFailableTransactions {
                let buffer: MXBuffer = "Hello World!"
                let _ = buffer.getSubBuffer(startIndex: 2, length: 100)
            }
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Index out of range."))
        }
    }
    
    func testNonEmptyBufferSubBufferNegativeStartIndexShouldFail() throws {
        do {
            try runFailableTransactions {
                let buffer: MXBuffer = "Hello World!"
                let _ = buffer.getSubBuffer(startIndex: -1, length: 2)
            }
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Negative start position."))
        }
    }
    
    func testNonEmptyBufferSubBufferNegativeSliceLengthShouldFail() throws {
        do {
            try runFailableTransactions {
                let buffer: MXBuffer = "Hello World!"
                let _ = buffer.getSubBuffer(startIndex: 0, length: -4)
            }
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Negative slice length."))
        }
    }
    
    func testNonEmptyBufferGetSubBuffer() throws {
        let buffer: MXBuffer = "Hello World!"
        let subBuffer = buffer.getSubBuffer(startIndex: 2, length: 5)
        
        let expected: MXBuffer = "llo W"
        
        XCTAssertEqual(subBuffer, expected)
    }
    
    func testNonEmptyBufferMidToEndSubBuffer() throws {
        let buffer: MXBuffer = "Hello World!"
        let subBuffer = buffer.getSubBuffer(startIndex: buffer.count / 2, length: buffer.count / 2)
        
        let expected: MXBuffer = "World!"
        
        XCTAssertEqual(subBuffer, expected)
    }
    
    func testNonEmptyBufferGetEntireSubBuffer() throws {
        let buffer: MXBuffer = "Hello World!"
        let subBuffer = buffer.getSubBuffer(startIndex: 0, length: buffer.count)
        
        let expected: MXBuffer = "Hello World!"
        
        XCTAssertEqual(subBuffer, expected)
    }
    
    func testBufferAppended() throws {
        let buffer: MXBuffer = "Hello"
        let result = buffer.appended(MXBuffer(" World!"))
        
        XCTAssertEqual(buffer, "Hello") // We ensure that the appended doesn't change the original buffer
        XCTAssertEqual(result, "Hello World!")
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
    
    func testNestedEncodeEmptyBuffer() throws {
        var output = MXBuffer()
        let value = MXBuffer()
        
        value.depEncode(dest: &output)
        
        let expected = "00000000"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testNestedEncodeSmallBuffer() throws {
        var output = MXBuffer()
        let value: MXBuffer = "a"
        
        value.depEncode(dest: &output)
        
        let expected = "0000000161"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testNestedEncodeLongBuffer() throws {
        var output = MXBuffer()
        let value: MXBuffer = "Hello World! How's it going? I hope you're enjoying the SwiftSDK!"
        
        value.depEncode(dest: &output)
        
        let expected = "0000004148656c6c6f20576f726c642120486f77277320697420676f696e673f204920686f706520796f7527726520656e6a6f79696e672074686520537769667453444b21"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
}

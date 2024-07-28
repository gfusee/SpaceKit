import XCTest
import MultiversX

@Contract struct BufferTestsContract {
    public func testNonEmptyBufferGetTooLongSubBufferShouldFail() {
        let buffer: MXBuffer = "Hello World!"
        let _ = buffer.getSubBuffer(startIndex: 2, length: 100)
    }
    
    public func testNonEmptyBufferSubBufferNegativeStartIndexShouldFail() {
        let buffer: MXBuffer = "Hello World!"
        let _ = buffer.getSubBuffer(startIndex: -1, length: 2)
    }
    
    public func testNonEmptyBufferSubBufferNegativeSliceLengthShouldFail() {
        let buffer: MXBuffer = "Hello World!"
        let _ = buffer.getSubBuffer(startIndex: 0, length: -4)
    }
    
    public func testNestedDecodeBufferEmptyInputShouldFail() {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("".hexadecimal)))
        let result = MXBuffer(depDecode: &input)
    }
    
    public func testNestedDecodeBufferBadLengthInputShouldFail() {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("000000".hexadecimal)))
        let result = MXBuffer(depDecode: &input)
    }
    
    public func testNestedDecodeBufferTooLargeLengthInputShouldFail() {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("0000004248656c6c6f20576f726c642120486f77277320697420676f696e673f204920686f706520796f7527726520656e6a6f79696e672074686520537769667453444b21".hexadecimal)))
        let result = MXBuffer(depDecode: &input)
    }
}

final class BufferTests: ContractTestCase {
    override var initialAccounts: [WorldAccount] {
        [
            WorldAccount(address: "contract")
        ]
    }
    
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
            try BufferTestsContract.testable("contract").testNonEmptyBufferGetTooLongSubBufferShouldFail()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Index out of range."))
        }
    }
    
    func testNonEmptyBufferSubBufferNegativeStartIndexShouldFail() throws {
        do {
            try BufferTestsContract.testable("contract").testNonEmptyBufferSubBufferNegativeStartIndexShouldFail()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Negative start position."))
        }
    }
    
    func testNonEmptyBufferSubBufferNegativeSliceLengthShouldFail() throws {
        do {
            try BufferTestsContract.testable("contract").testNonEmptyBufferSubBufferNegativeSliceLengthShouldFail()
            
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
        let buffer = MXBuffer(topDecode: input)
        
        XCTAssertEqual(buffer, "")
    }
    
    func testNonEmptyBufferTopDecode() throws {
        let input: MXBuffer = "Hello World!"
        let buffer = MXBuffer(topDecode: input)
        
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
    
    func testNestedDecodeEmptyBuffer() throws {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("00000000".hexadecimal)))
        let result = MXBuffer(depDecode: &input)
        
        let expected: MXBuffer = ""
        
        XCTAssertEqual(result, expected)
    }
    
    func testNestedDecodeSmallBuffer() throws {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("0000000161".hexadecimal)))
        let result = MXBuffer(depDecode: &input)
        
        let expected: MXBuffer = "a"
        
        XCTAssertEqual(result, expected)
    }
    
    func testNestedDecodeLongBuffer() throws {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("0000004148656c6c6f20576f726c642120486f77277320697420676f696e673f204920686f706520796f7527726520656e6a6f79696e672074686520537769667453444b21".hexadecimal)))
        let result = MXBuffer(depDecode: &input)
        
        let expected: MXBuffer = "Hello World! How's it going? I hope you're enjoying the SwiftSDK!"
        
        XCTAssertEqual(result, expected)
    }
    
    func testNestedDecodeLongBufferSmallerSize() throws {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("0000004048656c6c6f20576f726c642120486f77277320697420676f696e673f204920686f706520796f7527726520656e6a6f79696e672074686520537769667453444b21".hexadecimal)))
        let result = MXBuffer(depDecode: &input)
        
        let expected: MXBuffer = "Hello World! How's it going? I hope you're enjoying the SwiftSDK"
        
        XCTAssertEqual(result, expected)
    }
    
    func testNestedDecodeBufferEmptyInputShouldFail() throws {
        do {
            try BufferTestsContract.testable("contract").testNestedDecodeBufferEmptyInputShouldFail()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Index out of range."))
        }
    }
    
    func testNestedDecodeBufferBadLengthInputShouldFail() throws {
        do {
            try BufferTestsContract.testable("contract").testNestedDecodeBufferBadLengthInputShouldFail()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Index out of range."))
        }
    }
    
    func testNestedDecodeBufferTooLargeLengthInputShouldFail() throws {
        do {
            try BufferTestsContract.testable("contract").testNestedDecodeBufferTooLargeLengthInputShouldFail()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Index out of range."))
        }
    }
    
    func testGetFixedBytesWithCorrectBuffer() throws {
        let buffer = MXBuffer(data: Array("0001020304050607".hexadecimal))
        let bytes = buffer.toBigEndianBytes8()
        
        let array = [
            bytes.0,
            bytes.1,
            bytes.2,
            bytes.3,
            bytes.4,
            bytes.5,
            bytes.6,
            bytes.7
        ]
        
        let expected: [UInt8] = [0, 1, 2, 3, 4, 5, 6, 7]
        
        XCTAssertEqual(array, expected)
    }
}

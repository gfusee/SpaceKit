import XCTest
import SpaceKit

@Controller struct IntTestsController {
    public func testTopDecodeIntTooLargeBufferShouldFail() {
        let input = Buffer(data: Array("0001020304".hexadecimal))
        _ = Int(topDecode: input)
    }
    
    public func testNestedDecodeIntEmptyBufferShouldFail() {
        var input = BufferNestedDecodeInput(buffer: Buffer(data: Array("".hexadecimal)))
        _ = Int(depDecode: &input)
    }
    
    public func testNestedDecodeIntTooSmallBufferShouldFail() {
        var input = BufferNestedDecodeInput(buffer: Buffer(data: Array("000000".hexadecimal)))
        _ = Int(depDecode: &input)
    }
    
    public func testNestedDecodeTwoIntsTooSmallBufferShouldFail() {
        var input = BufferNestedDecodeInput(buffer: Buffer(data: Array("000003e8000000".hexadecimal)))
        _ = Int(depDecode: &input)
        _ = Int(depDecode: &input)
    }
}

final class IntTests: ContractTestCase {

    override var initialAccounts: [WorldAccount] {
        [
            WorldAccount(address: "contract")
        ]
    }
    
    func testTopEncodeIntZero() throws {
        var output = Buffer()
        let value: Int = 0
        
        value.topEncode(output: &output)
        
        let expected = ""
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testTopEncodeIntOne() throws {
        var output = Buffer()
        let value: Int = 1
        
        value.topEncode(output: &output)
        
        let expected = "01"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testTopEncodeIntTen() throws {
        var output = Buffer()
        let value: Int = 10
        
        value.topEncode(output: &output)
        
        let expected = "0a"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testTopEncodeIntMinusThousand() throws {
        var output = Buffer()
        let value: Int = -1000
        
        value.topEncode(output: &output)
        
        let expected = "fc18"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testTopEncodeIntThousand() throws {
        var output = Buffer()
        let value: Int = 1000
        
        value.topEncode(output: &output)
        
        let expected = "03e8"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testTopEncodeIntMin() throws {
        var output = Buffer()
        let value: Int = Int(Int32.min)
        
        value.topEncode(output: &output)
        
        let expected = "80000000"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testTopEncodeIntMax() throws {
        var output = Buffer()
        let value: Int = Int(Int32.max)
        
        value.topEncode(output: &output)
        
        let expected = "7fffffff"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testNestedEncodeIntZero() throws {
        var output = Buffer()
        let value: Int = 0
        
        value.depEncode(dest: &output)
        
        let expected = "00000000"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testNestedEncodeIntOne() throws {
        var output = Buffer()
        let value: Int = 1
        
        value.depEncode(dest: &output)
        
        let expected = "00000001"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testNestedEncodeIntTen() throws {
        var output = Buffer()
        let value: Int = 10
        
        value.depEncode(dest: &output)
        
        let expected = "0000000a"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testNestedEncodeIntMinusThousand() throws {
        var output = Buffer()
        let value: Int = -1000
        
        value.depEncode(dest: &output)
        
        let expected = "fffffc18"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testNestedEncodeIntThousand() throws {
        var output = Buffer()
        let value: Int = 1000
        
        value.depEncode(dest: &output)
        
        let expected = "000003e8"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testNestedEncodeIntMax() throws {
        var output = Buffer()
        let value: Int = Int(Int32.max)
        
        value.depEncode(dest: &output)
        
        let expected = "7fffffff"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testTopDecodeIntEmpty() throws {
        let input = Buffer(data: Array("".hexadecimal))
        let result = Int(topDecode: input)
        
        let expected = 0
        
        XCTAssertEqual(result, expected)
    }
    
    func testTopDecodeIntZero() throws {
        let input = Buffer(data: Array("00".hexadecimal))
        let result = Int(topDecode: input)
        
        let expected = 0
        
        XCTAssertEqual(result, expected)
    }
    
    func testTopDecodeIntOne() throws {
        let input = Buffer(data: Array("01".hexadecimal))
        let result = Int(topDecode: input)
        
        let expected = 1
        
        XCTAssertEqual(result, expected)
    }
    
    func testTopDecodeIntMinusThousand() throws {
        let input = Buffer(data: Array("fc18".hexadecimal))
        let result = Int(topDecode: input)
        
        let expected = -1000
        
        XCTAssertEqual(result, expected)
    }
    
    func testTopDecodeIntThousand() throws {
        let input = Buffer(data: Array("03e8".hexadecimal))
        let result = Int(topDecode: input)
        
        let expected = 1000
        
        XCTAssertEqual(result, expected)
    }
    
    func testTopDecodeIntMin() throws {
        let input = Buffer(data: Array("80000000".hexadecimal))
        let result = Int(topDecode: input)
        
        let expected = Int(Int32.min)
        
        XCTAssertEqual(result, expected)
    }
    
    func testTopDecodeIntMax() throws {
        let input = Buffer(data: Array("7fffffff".hexadecimal))
        let result = Int(topDecode: input)
        
        let expected = Int(Int32.max)
        
        XCTAssertEqual(result, expected)
    }
    
    func testTopDecodeIntTooLargeBufferShouldFail() throws {
        do {
            try self.deployContract(IntTestsContract.self, at: "contract").testTopDecodeIntTooLargeBufferShouldFail()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Cannot decode Int: input too large."))
        }
    }
    
    func testNestedDecodeIntZero() throws {
        var input = BufferNestedDecodeInput(buffer: Buffer(data: Array("00000000".hexadecimal)))
        let result = Int(depDecode: &input)
        
        let expected = 0
        
        XCTAssertEqual(result, expected)
    }
    
    func testNestedDecodeIntOne() throws {
        var input = BufferNestedDecodeInput(buffer: Buffer(data: Array("00000001".hexadecimal)))
        let result = Int(depDecode: &input)
        
        let expected = 1
        
        XCTAssertEqual(result, expected)
    }
    
    func testNestedDecodeIntMinusThousand() throws {
        var input = BufferNestedDecodeInput(buffer: Buffer(data: Array("fffffc18".hexadecimal)))
        let result = Int(depDecode: &input)
        
        let expected = -1000
        
        XCTAssertEqual(result, expected)
    }
    
    func testNestedDecodeIntThousand() throws {
        var input = BufferNestedDecodeInput(buffer: Buffer(data: Array("000003e8".hexadecimal)))
        let result = Int(depDecode: &input)
        
        let expected = 1000
        
        XCTAssertEqual(result, expected)
    }
    
    func testNestedDecodeIntMax() throws {
        var input = BufferNestedDecodeInput(buffer: Buffer(data: Array("7fffffff".hexadecimal)))
        let result = Int(depDecode: &input)
        
        let expected = Int(Int32.max)
        
        XCTAssertEqual(result, expected)
    }
    
    func testNestedDecodeIntEmptyBufferShouldFail() throws {
        do {
            try self.deployContract(IntTestsContract.self, at: "contract").testNestedDecodeIntEmptyBufferShouldFail()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Index out of range."))
        }
    }
    
    func testNestedDecodeIntTooSmallBufferShouldFail() throws {
        do {
            try self.deployContract(IntTestsContract.self, at: "contract").testNestedDecodeIntTooSmallBufferShouldFail()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Index out of range."))
        }
    }
    
    func testNestedDecodeIntThousandTooLargeBuffer() throws {
        var input = BufferNestedDecodeInput(buffer: Buffer(data: Array("000003e800000064".hexadecimal)))
        let result = Int(depDecode: &input)
        
        let expected = 1000
        
        XCTAssertEqual(result, expected)
    }
    
    func testNestedDecodeTwoInts() throws {
        var input = BufferNestedDecodeInput(buffer: Buffer(data: Array("000003e800000064".hexadecimal)))
        let result1 = Int(depDecode: &input)
        let result2 = Int(depDecode: &input)
        
        let expected1 = 1000
        let expected2 = 100
        
        XCTAssertEqual(result1, expected1)
        XCTAssertEqual(result2, expected2)
    }
    
    func testNestedDecodeTwoIntsTooSmallBufferShouldFail() throws {
        do {
            try self.deployContract(IntTestsContract.self, at: "contract").testNestedDecodeTwoIntsTooSmallBufferShouldFail()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Index out of range."))
        }
    }
    
    func testFixedArrayToIntWithZero() throws {
        let array = getZeroedBytes8()
        let result = toBigEndianInt32(skipZerosCount: 4, from: toBytes4BigEndian(bytes8: array))
        
        let expected: Int32 = 0
        
        XCTAssertEqual(result, expected)
    }
    
    func testFixedArrayToIntWithOne() throws {
        var array = getZeroedBytes8()
        
        array.7 = 1
        
        let result = toBigEndianInt32(skipZerosCount: 3, from: toBytes4BigEndian(bytes8: array))
        
        let expected: Int32 = 1
        
        XCTAssertEqual(result, expected)
    }
    
    func testFixedArrayToIntWithTen() throws {
        var array = getZeroedBytes8()
        
        array.7 = 10
        
        let result = toBigEndianInt32(skipZerosCount: 3, from: toBytes4BigEndian(bytes8: array))
        
        let expected: Int32 = 10
        
        XCTAssertEqual(result, expected)
    }
    
    func testFixedArrayToIntWithMinusThousand() throws {
        var array = getZeroedBytes8()
        
        array.6 = 252
        array.7 = 24
        
        let result = toBigEndianInt32(skipZerosCount: 2, from: toBytes4BigEndian(bytes8: array))
        
        let expected: Int32 = -1000
        
        XCTAssertEqual(result, expected)
    }
    
    func testFixedArrayToIntWithThousand() throws {
        var array = getZeroedBytes8()
        
        array.6 = 3
        array.7 = 232
        
        let result = toBigEndianInt32(skipZerosCount: 2, from: toBytes4BigEndian(bytes8: array))
        
        let expected: Int32 = 1000
        
        XCTAssertEqual(result, expected)
    }
    
    func testFixedArrayToIntWithMin() throws {
        var array = getZeroedBytes8()
        
        array.4 = 128
        array.5 = 0
        array.6 = 0
        array.7 = 0
        
        let result = toBigEndianInt32(skipZerosCount: 0, from: toBytes4BigEndian(bytes8: array))
        
        let expected = Int32.min
        
        XCTAssertEqual(result, expected)
    }
    
    func testFixedArrayToIntWithMax() throws {
        var array = getZeroedBytes8()
        
        array.4 = 127
        array.5 = 255
        array.6 = 255
        array.7 = 255
        
        let result = toBigEndianInt32(skipZerosCount: 0, from: toBytes4BigEndian(bytes8: array))
        
        let expected = Int32.max
        
        XCTAssertEqual(result, expected)
    }
}

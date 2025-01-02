import SpaceKit
import SpaceKitTesting

@Controller public struct UInt8TestsController {
    public func testTopDecodeUInt8TooLargeBufferShouldFail() {
        let input = Buffer(data: Array("0000".hexadecimal))
        let _ = UInt8(topDecode: input)
    }
    
    public func testNestedDecodeUInt8EmptyBufferShouldFail() {
        var input = BufferNestedDecodeInput(buffer: Buffer(data: Array("".hexadecimal)))
        let _ = UInt8(depDecode: &input)
    }
    
    public func testNestedDecodeTwoUInt8sTooSmallBufferShouldFail() {
        var input = BufferNestedDecodeInput(buffer: Buffer(data: Array("03".hexadecimal)))
        let _ = UInt8(depDecode: &input)
        let _ = UInt8(depDecode: &input)
    }
}

final class UInt8Tests: ContractTestCase {

    override var initialAccounts: [WorldAccount] {
        [
            WorldAccount(
                address: "contract",
                controllers: [
                    UInt8TestsController.self
                ]
            )
        ]
    }
    
    func testTopEncodeUInt8Zero() throws {
        var output = Buffer()
        let value: UInt8 = 0
        
        value.topEncode(output: &output)
        
        let expected = ""
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testTopEncodeUInt8One() throws {
        var output = Buffer()
        let value: UInt8 = 1
        
        value.topEncode(output: &output)
        
        let expected = "01"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testTopEncodeUInt8Ten() throws {
        var output = Buffer()
        let value: UInt8 = 10
        
        value.topEncode(output: &output)
        
        let expected = "0a"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testTopEncodeUInt8Max() throws {
        var output = Buffer()
        let value = UInt8.max
        
        value.topEncode(output: &output)
        
        let expected = "ff"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testNestedEncodeUInt8Zero() throws {
        var output = Buffer()
        let value: UInt8 = 0
        
        value.depEncode(dest: &output)
        
        let expected = "00"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testNestedEncodeUInt8One() throws {
        var output = Buffer()
        let value: UInt8 = 1
        
        value.depEncode(dest: &output)
        
        let expected = "01"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testNestedEncodeUInt8Ten() throws {
        var output = Buffer()
        let value: UInt8 = 10
        
        value.depEncode(dest: &output)
        
        let expected = "0a"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testNestedEncodeUInt8Max() throws {
        var output = Buffer()
        let value = UInt8.max
        
        value.depEncode(dest: &output)
        
        let expected = "ff"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testTopDecodeUInt8EmptyBuffer() throws {
        let input = Buffer(data: Array("00".hexadecimal))
        let result = UInt8(topDecode: input)
        
        let expected: UInt8 = 0
        
        XCTAssertEqual(result, expected)
    }
    
    func testTopDecodeUInt8Zero() throws {
        let input = Buffer(data: Array("00".hexadecimal))
        let result = UInt8(topDecode: input)
        
        let expected: UInt8 = 0
        
        XCTAssertEqual(result, expected)
    }
    
    func testTopDecodeUInt8One() throws {
        let input = Buffer(data: Array("01".hexadecimal))
        let result = UInt8(topDecode: input)
        
        let expected: UInt8 = 1
        
        XCTAssertEqual(result, expected)
    }
    
    func testTopDecodeUInt8Max() throws {
        let input = Buffer(data: Array("ff".hexadecimal))
        let result = UInt8(topDecode: input)
        
        let expected = UInt8.max
        
        XCTAssertEqual(result, expected)
    }
    
    func testTopDecodeUInt8TooLargeBufferShouldFail() throws {
        do {
            try self.deployContract(at: "contract")
            let controller = self.instantiateController(UInt8TestsController.self, for: "contract")!
            
            try controller.testTopDecodeUInt8TooLargeBufferShouldFail()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Cannot decode UInt8: input too large."))
        }
    }
    
    func testNestedDecodeUInt8Zero() throws {
        var input = BufferNestedDecodeInput(buffer: Buffer(data: Array("00".hexadecimal)))
        let result = UInt8(depDecode: &input)
        
        let expected: UInt8 = 0
        
        XCTAssertEqual(result, expected)
    }
    
    func testNestedDecodeUInt8One() throws {
        var input = BufferNestedDecodeInput(buffer: Buffer(data: Array("01".hexadecimal)))
        let result = UInt8(depDecode: &input)
        
        let expected: UInt8 = 1
        
        XCTAssertEqual(result, expected)
    }
    
    func testNestedDecodeUInt8Max() throws {
        var input = BufferNestedDecodeInput(buffer: Buffer(data: Array("ff".hexadecimal)))
        let result = UInt8(depDecode: &input)
        
        let expected = UInt8.max
        
        XCTAssertEqual(result, expected)
    }
    
    func testNestedDecodeUInt8EmptyBufferShouldFail() throws {
        do {
            try self.deployContract(at: "contract")
            let controller = self.instantiateController(UInt8TestsController.self, for: "contract")!
            
            try controller.testNestedDecodeUInt8EmptyBufferShouldFail()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Index out of range."))
        }
    }
    
    func testNestedDecodeTwoUInt8s() throws {
        var input = BufferNestedDecodeInput(buffer: Buffer(data: Array("0364".hexadecimal)))
        let result1 = UInt8(depDecode: &input)
        let result2 = UInt8(depDecode: &input)
        
        let expected1: UInt8 = 3
        let expected2: UInt8 = 100
        
        XCTAssertEqual(result1, expected1)
        XCTAssertEqual(result2, expected2)
    }
    
    func testNestedDecodeTwoUInt8sTooSmallBufferShouldFail() throws {
        do {
            try self.deployContract(at: "contract")
            let controller = self.instantiateController(UInt8TestsController.self, for: "contract")!
            
            try controller.testNestedDecodeTwoUInt8sTooSmallBufferShouldFail()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Index out of range."))
        }
    }
}

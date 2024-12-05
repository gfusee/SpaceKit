@testable import SpaceKit
import XCTest

@Controller struct ArrayOfIntegersTestsController {
    
    public func testGetOutOfRangeShouldFail() {
        let array: Vector<UInt64> = [10]
        
        _ = array[1]
    }
    
    public func testTopDecodeInputTooLarge() {
        let input = Buffer(data: Array("000000000000000a01".hexadecimal))
        
        _ = Vector<UInt64>(topDecode: input)
    }
    
    public func testReplacedOutOfRangeShouldFail() {
        let array: Vector<UInt64> = [10]
        
        _ = array.replaced(at: 1, value: 100)
    }
    
}

final class ArrayOfIntegersTests: ContractTestCase {

    override var initialAccounts: [WorldAccount] {
        [
            WorldAccount(address: "contract")
        ]
    }
    
    func testEmptyArray() throws {
        let array: Vector<UInt64> = Vector()
        
        let count = array.count
        
        XCTAssertEqual(count, 0)
        XCTAssertEqual(array.buffer.count, 0)
    }
    
    func testAppendedOneElementArray() throws {
        var array: Vector<UInt64> = Vector()
        array = array.appended(10)
        
        let count = array.count
        let element = array.get(0)
        
        XCTAssertEqual(count, 1)
        XCTAssertEqual(element, 10)
        XCTAssertEqual(array.buffer.count, 8)
    }
    
    func testAppendedTwoElementsArray() throws {
        var array: Vector<UInt64> = Vector()
        array = array.appended(10)
        array = array.appended(100)
        
        let count = array.count
        let firstElement = array.get(0)
        let secondElement = array.get(1)
        
        XCTAssertEqual(count, 2)
        XCTAssertEqual(firstElement, 10)
        XCTAssertEqual(secondElement, 100)
        XCTAssertEqual(array.buffer.count, 16)
    }
    
    func testAppendedTwoElementsArrayUsingSubscript() throws {
        var array: Vector<UInt64> = Vector()
        array = array.appended(10)
        array = array.appended(100)
        
        let count = array.count
        let firstElement = array[0]
        let secondElement = array[1]
        
        XCTAssertEqual(count, 2)
        XCTAssertEqual(firstElement, 10)
        XCTAssertEqual(secondElement, 100)
    }
    
    func testTwoElementsArrayThroughLiteralAssign() throws {
        let array: Vector<UInt64> = [10, 100]
        
        let count = array.count
        let firstElement = array.get(0)
        let secondElement = array.get(1)
        
        XCTAssertEqual(count, 2)
        XCTAssertEqual(firstElement, 10)
        XCTAssertEqual(secondElement, 100)
        XCTAssertEqual(array.buffer.count, 16)
    }
    
    func testAppendedContentsOf() throws {
        var array1: Vector<UInt64> = Vector()
        array1 = array1.appended(10)
        array1 = array1.appended(100)
        
        var array2: Vector<UInt64> = Vector()
        array2 = array2.appended(5)
        array2 = array2.appended(30)
        array2 = array2.appended(0)
        
        let array = array1.appended(contentsOf: array2)
        let expected: Vector<UInt64> = [
            10,
            100,
            5,
            30,
            0
        ]
        
        XCTAssertEqual(array, expected)
    }
    
    func testEquatableWhenEqual() throws {
        let array1: Vector<UInt64> = [10, 100]
        let array2: Vector<UInt64> = [10, 100]
        
        XCTAssertEqual(array1, array2)
    }
    
    func testEquatableWhenDifferentCount() throws {
        let array1: Vector<UInt64> = [10, 100]
        let array2: Vector<UInt64> = [10]
        
        XCTAssertNotEqual(array1, array2)
    }
    
    func testEquatableWhenDifferentValues() throws {
        let array1: Vector<UInt64> = [10, 100]
        let array2: Vector<UInt64> = [10, 50]
        
        XCTAssertNotEqual(array1, array2)
    }
    
    func testPlusOperator() throws {
        var array1: Vector<UInt64> = Vector()
        array1 = array1.appended(10)
        array1 = array1.appended(100)
        
        var array2: Vector<UInt64> = Vector()
        array2 = array2.appended(5)
        array2 = array2.appended(30)
        array2 = array2.appended(0)
        
        let array = array1 + array2
        let expected: Vector<UInt64> = [
            10,
            100,
            5,
            30,
            0
        ]
        
        XCTAssertEqual(array, expected)
    }
    
    func testGetOutOfRangeShouldFail() throws {
        do {
            try self.deployContract(ArrayOfIntegersTestsContract.self, at: "contract").testGetOutOfRangeShouldFail()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Index out of range."))
        }
    }
    
    func testForLoopZeroElement() throws {
        let array: Vector<UInt64> = Vector()
        
        array.forEach { _ in XCTFail() }
    }
    
    func testForLoopOneElement() throws {
        let array: Vector<UInt64> = [10]
        
        array.forEach { XCTAssertEqual($0, 10) }
    }
    
    func testForLoopTwoElements() throws {
        let array: Vector<UInt64> = [10, 100]
        
        var heapArray: [UInt64] = []
        
        array.forEach { heapArray.append($0) }
        
        let expected: [UInt64] = [10, 100]
        
        XCTAssertEqual(heapArray, expected)
    }
    
    func testTopEncodeZeroElement() throws {
        let array: Vector<UInt64> = Vector()
        
        var output = Buffer()
        array.topEncode(output: &output)
        
        let expected: Buffer = ""
        
        XCTAssertEqual(output, expected)
    }
    
    func testTopEncodeOneElement() throws {
        let array: Vector<UInt64> = [10]
        
        var output = Buffer()
        array.topEncode(output: &output)
        
        let expected = Buffer(data: Array("000000000000000a".hexadecimal))
        
        XCTAssertEqual(output, expected)
    }
    
    func testTopEncodeTwoElements() throws {
        let array: Vector<UInt64> = [10, 100]
        
        var output = Buffer()
        array.topEncode(output: &output)
        
        let expected = Buffer(data: Array("000000000000000a0000000000000064".hexadecimal))
        
        XCTAssertEqual(output, expected)
    }
    
    func testNestedEncodeZeroElement() throws {
        let array: Vector<UInt64> = Vector()
        
        var output = Buffer()
        array.depEncode(dest: &output)
        
        let expected = Buffer(data: Array("00000000".hexadecimal))
        
        XCTAssertEqual(output, expected)
    }
    
    func testNestedEncodeOneElement() throws {
        let array: Vector<UInt64> = [10]
        
        var output = Buffer()
        array.depEncode(dest: &output)
        
        let expected = Buffer(data: Array("00000001000000000000000a".hexadecimal))
        
        XCTAssertEqual(output, expected)
    }
    
    func testNestedEncodeTwoElements() throws {
        let array: Vector<UInt64> = [10, 100]
        
        var output = Buffer()
        array.depEncode(dest: &output)
        
        let expected = Buffer(data: Array("00000002000000000000000a0000000000000064".hexadecimal))
        
        XCTAssertEqual(output, expected)
    }
    
    func testTopDecodeZeroElement() throws {
        let input = Buffer(data: Array("".hexadecimal))
        
        let array = Vector<UInt64>(topDecode: input).toArray()
        let expected: [UInt64] = []
        
        XCTAssertEqual(array, expected)
    }
    
    func testTopDecodeOneElement() throws {
        let input = Buffer(data: Array("000000000000000a".hexadecimal))
        
        let array = Vector<UInt64>(topDecode: input)
        let expected: Vector<UInt64> = [10]
        
        XCTAssertEqual(array, expected)
    }
    
    func testTopDecodeTwoElements() throws {
        let input = Buffer(data: Array("000000000000000a0000000000000064".hexadecimal))
        
        let array = Vector<UInt64>(topDecode: input)
        let expected: Vector<UInt64> = [10, 100]
        
        XCTAssertEqual(array, expected)
    }
    
    func testNestedDecodeZeroElement() throws {
        var input = BufferNestedDecodeInput(buffer: Buffer(data: Array("00000000".hexadecimal)))
        
        let array = Vector<UInt64>(depDecode: &input)
        let expected: Vector<UInt64> = []
        
        XCTAssertEqual(array, expected)
    }
    
    func testNestedDecodeOneElement() throws {
        var input = BufferNestedDecodeInput(buffer: Buffer(data: Array("00000001000000000000000a".hexadecimal)))
        
        let array = Vector<UInt64>(depDecode: &input)
        let expected: Vector<UInt64> = [10]
        
        XCTAssertEqual(array, expected)
    }
    
    func testNestedDecodeTwoElements() throws {
        var input = BufferNestedDecodeInput(buffer: Buffer(data: Array("00000002000000000000000a0000000000000064".hexadecimal)))
        
        let array = Vector<UInt64>(depDecode: &input)
        let expected: Vector<UInt64> = [10, 100]
        
        XCTAssertEqual(array, expected)
    }
    
    func testNestedDecodeTwoElementsAndInputLarger() throws {
        var input = BufferNestedDecodeInput(buffer: Buffer(data: Array("00000002000000000000000a000000000000006401".hexadecimal)))
        
        let array = Vector<UInt64>(depDecode: &input)
        let expected: Vector<UInt64> = [10, 100]
        
        XCTAssertEqual(array, expected)
        XCTAssertEqual(input.canDecodeMore(), true)
    }
    
    func testReplaceFirstElement() throws {
        let array: Vector<UInt64> = [
            10,
            100,
            5
        ]
        
        let replaced = array.replaced(at: 0, value: 30)
        
        let expected: Vector<UInt64> = [
            30,
            100,
            5
        ]
        
        XCTAssertEqual(replaced, expected)
    }
    
    func testReplaceSecondElement() throws {
        let array: Vector<UInt64> = [
            10,
            100,
            5
        ]
        
        let replaced = array.replaced(at: 1, value: 30)
        
        let expected: Vector<UInt64> = [
            10,
            30,
            5
        ]
        
        XCTAssertEqual(replaced, expected)
    }
    
    func testReplaceThirdElement() throws {
        let array: Vector<UInt64> = [
            10,
            100,
            5
        ]
        
        let replaced = array.replaced(at: 2, value: 30)
        
        let expected: Vector<UInt64> = [
            10,
            100,
            30
        ]
        
        XCTAssertEqual(replaced, expected)
    }
    
    func testReplacedOutOfRangeShouldFail() throws {
        do {
            try self.deployContract(ArrayOfIntegersTestsContract.self, at: "contract").testReplacedOutOfRangeShouldFail()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Index out of range."))
        }
    }
    
}

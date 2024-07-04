@testable import MultiversX
import XCTest

@Contract struct ArrayOfBuffersTestsContract {
    
    public func testGetOutOfRangeShouldFail() {
        let array: MXArray<MXBuffer> = ["Hey!"]
        
        _ = array[1]
    }
    
    public func testTopDecodeInputTooLarge() {
        let input = MXBuffer(data: Array("00000001610000004148656c6c6f20576f726c642120486f77277320697420676f696e673f204920686f706520796f7527726520656e6a6f79696e672074686520537769667453444b2101".hexadecimal))
        
        _ = MXArray<MXBuffer>(topDecode: input)
    }
    
    public func testReplacedOutOfRangeShouldFail() {
        let array: MXArray<MXBuffer> = ["Hey!"]
        
        _ = array.replaced(at: 1, value: "test")
    }
    
}

final class ArrayOfBuffersTests: ContractTestCase {
    
    func testEmptyArray() throws {
        let array: MXArray<MXBuffer> = MXArray()
        
        let count = array.count
        
        XCTAssertEqual(count, 0)
        XCTAssertEqual(array.buffer.count, 0)
    }
    
    func testAppendedOneElementArray() throws {
        var array: MXArray<MXBuffer> = MXArray()
        array = array.appended("Hey!")
        
        let count = array.count
        let element = array.get(0)
        
        XCTAssertEqual(count, 1)
        XCTAssertEqual(element, "Hey!")
        XCTAssertEqual(array.buffer.count, 4)
    }
    
    func testAppendedTwoElementsArray() throws {
        var array: MXArray<MXBuffer> = MXArray()
        array = array.appended("Hey!")
        array = array.appended("How's it going?")
        
        let count = array.count
        let firstElement = array.get(0)
        let secondElement = array.get(1)
        
        XCTAssertEqual(count, 2)
        XCTAssertEqual(firstElement, "Hey!")
        XCTAssertEqual(secondElement, "How's it going?")
        XCTAssertEqual(array.buffer.count, 8)
    }
    
    func testTwoElementsArrayThroughLiteralAssign() throws {
        let array: MXArray<MXBuffer> = ["Hey!", "How's it going?"]
        
        let count = array.count
        let firstElement = array.get(0)
        let secondElement = array.get(1)
        
        XCTAssertEqual(count, 2)
        XCTAssertEqual(firstElement, "Hey!")
        XCTAssertEqual(secondElement, "How's it going?")
        XCTAssertEqual(array.buffer.count, 8)
    }
    
    func testAppendedContentsOf() throws {
        var array1: MXArray<MXBuffer> = MXArray()
        array1 = array1.appended("Hey!")
        array1 = array1.appended("How's it going?")
        
        var array2: MXArray<MXBuffer> = MXArray()
        array2 = array2.appended("I hope")
        array2 = array2.appended("you're enjoying")
        array2 = array2.appended("the SwiftSDK!")
        
        let array = array1.appended(contentsOf: array2).toArray()
        let expected: [MXBuffer] = [
            "Hey!",
            "How's it going?",
            "I hope",
            "you're enjoying",
            "the SwiftSDK!"
        ]
        
        XCTAssertEqual(array, expected)
    }
    
    func testEquatableWhenEqual() throws {
        let array1: MXArray<MXBuffer> = ["Hey!", "How's it going?"]
        let array2: MXArray<MXBuffer> = ["Hey!", "How's it going?"]
        
        XCTAssertEqual(array1, array2)
    }
    
    func testEquatableWhenDifferentCount() throws {
        let array1: MXArray<MXBuffer> = ["Hey!", "How's it going?"]
        let array2: MXArray<MXBuffer> = ["Hey!"]
        
        XCTAssertNotEqual(array1, array2)
    }
    
    func testEquatableWhenDifferentValues() throws {
        let array1: MXArray<MXBuffer> = ["Hey!", "How's it going?"]
        let array2: MXArray<MXBuffer> = ["Hey!", "???"]
        
        XCTAssertNotEqual(array1, array2)
    }
    
    func testPlusOperator() throws {
        var array1: MXArray<MXBuffer> = MXArray()
        array1 = array1.appended("Hey!")
        array1 = array1.appended("How's it going?")
        
        var array2: MXArray<MXBuffer> = MXArray()
        array2 = array2.appended("I hope")
        array2 = array2.appended("you're enjoying")
        array2 = array2.appended("the SwiftSDK!")
        
        let array = (array1 + array2).toArray()
        let expected: [MXBuffer] = [
            "Hey!",
            "How's it going?",
            "I hope",
            "you're enjoying",
            "the SwiftSDK!"
        ]
        
        XCTAssertEqual(array, expected)
    }
    
    func testAppendedTwoElementsArrayUsingSubscript() throws {
        var array: MXArray<MXBuffer> = MXArray()
        array = array.appended("Hey!")
        array = array.appended("How's it going?")
        
        let count = array.count
        let firstElement = array[0]
        let secondElement = array[1]
        
        XCTAssertEqual(count, 2)
        XCTAssertEqual(firstElement, "Hey!")
        XCTAssertEqual(secondElement, "How's it going?")
    }
    
    func testGetOutOfRangeShouldFail() throws {
        do {
            try ArrayOfBuffersTestsContract.testable("").testGetOutOfRangeShouldFail()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Index out of range."))
        }
    }
    
    func testForLoopZeroElement() throws {
        let array: MXArray<MXBuffer> = MXArray()
        
        for _ in array {
            XCTFail()
        }
    }
    
    func testForLoopOneElement() throws {
        var array: MXArray<MXBuffer> = MXArray()
        array = array.appended("Hey!")
        
        for item in array {
            XCTAssertEqual(item, "Hey!")
        }
    }
    
    func testForLoopTwoElements() throws {
        var array: MXArray<MXBuffer> = MXArray()
        array = array.appended("Hey!")
        array = array.appended("How's it going?")
        
        var heapArray: [MXBuffer] = []
        
        for item in array {
            heapArray.append(item)
        }
        
        let expected: [MXBuffer] = ["Hey!", "How's it going?"]
        
        XCTAssertEqual(heapArray, expected)
    }
    
    func testTopEncodeZeroElement() throws {
        let array: MXArray<MXBuffer> = MXArray()
        
        var output = MXBuffer()
        array.topEncode(output: &output)
        
        let expected: MXBuffer = ""
        
        XCTAssertEqual(output, expected)
    }
    
    func testTopEncodeOneElement() throws {
        var array: MXArray<MXBuffer> = MXArray()
        array = array.appended("a")
        
        var output = MXBuffer()
        array.topEncode(output: &output)
        
        let expected = MXBuffer(data: Array("0000000161".hexadecimal))
        
        XCTAssertEqual(output, expected)
    }
    
    func testTopEncodeTwoElements() throws {
        var array: MXArray<MXBuffer> = MXArray()
        array = array.appended("a")
        array = array.appended("Hello World! How's it going? I hope you're enjoying the SwiftSDK!")
        
        var output = MXBuffer()
        array.topEncode(output: &output)
        
        let expected = MXBuffer(data: Array("00000001610000004148656c6c6f20576f726c642120486f77277320697420676f696e673f204920686f706520796f7527726520656e6a6f79696e672074686520537769667453444b21".hexadecimal))
        
        XCTAssertEqual(output, expected)
    }
    
    func testNestedEncodeZeroElement() throws {
        let array: MXArray<MXBuffer> = MXArray()
        
        var output = MXBuffer()
        array.depEncode(dest: &output)
        
        let expected = MXBuffer(data: Array("00000000".hexadecimal))
        
        XCTAssertEqual(output, expected)
    }
    
    func testNestedEncodeOneElement() throws {
        var array: MXArray<MXBuffer> = MXArray()
        array = array.appended("a")
        
        var output = MXBuffer()
        array.depEncode(dest: &output)
        
        let expected = MXBuffer(data: Array("000000010000000161".hexadecimal))
        
        XCTAssertEqual(output, expected)
    }
    
    func testNestedEncodeTwoElements() throws {
        var array: MXArray<MXBuffer> = MXArray()
        array = array.appended("a")
        array = array.appended("Hello World! How's it going? I hope you're enjoying the SwiftSDK!")
        
        var output = MXBuffer()
        array.depEncode(dest: &output)
        
        let expected = MXBuffer(data: Array("0000000200000001610000004148656c6c6f20576f726c642120486f77277320697420676f696e673f204920686f706520796f7527726520656e6a6f79696e672074686520537769667453444b21".hexadecimal))
        
        XCTAssertEqual(output, expected)
    }
    
    func testTopDecodeZeroElement() throws {
        let input = MXBuffer(data: Array("".hexadecimal))
        
        let array = MXArray<MXBuffer>(topDecode: input).toArray()
        let expected: [MXBuffer] = []
        
        XCTAssertEqual(array, expected)
    }
    
    func testTopDecodeOneElement() throws {
        let input = MXBuffer(data: Array("0000000161".hexadecimal))
        
        let array = MXArray<MXBuffer>(topDecode: input).toArray()
        let expected: [MXBuffer] = ["a"]
        
        XCTAssertEqual(array, expected)
    }
    
    func testTopDecodeTwoElements() throws {
        let input = MXBuffer(data: Array("00000001610000004148656c6c6f20576f726c642120486f77277320697420676f696e673f204920686f706520796f7527726520656e6a6f79696e672074686520537769667453444b21".hexadecimal))
        
        let array = MXArray<MXBuffer>(topDecode: input).toArray()
        let expected: [MXBuffer] = ["a", "Hello World! How's it going? I hope you're enjoying the SwiftSDK!"]
        
        XCTAssertEqual(array, expected)
    }
    
    func testNestedDecodeZeroElement() throws {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("00000000".hexadecimal)))
        
        let array = MXArray<MXBuffer>(depDecode: &input).toArray()
        let expected: [MXBuffer] = []
        
        XCTAssertEqual(array, expected)
    }
    
    func testNestedDecodeOneElement() throws {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("000000010000000161".hexadecimal)))
        
        let array = MXArray<MXBuffer>(depDecode: &input).toArray()
        let expected: [MXBuffer] = ["a"]
        
        XCTAssertEqual(array, expected)
    }
    
    func testNestedDecodeTwoElements() throws {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("0000000200000001610000004148656c6c6f20576f726c642120486f77277320697420676f696e673f204920686f706520796f7527726520656e6a6f79696e672074686520537769667453444b21".hexadecimal)))
        
        let array = MXArray<MXBuffer>(depDecode: &input).toArray()
        let expected: [MXBuffer] = ["a", "Hello World! How's it going? I hope you're enjoying the SwiftSDK!"]
        
        XCTAssertEqual(array, expected)
    }
    
    func testNestedDecodeTwoElementsAndInputLarger() throws {
        var input = BufferNestedDecodeInput(buffer: MXBuffer(data: Array("0000000200000001610000004148656c6c6f20576f726c642120486f77277320697420676f696e673f204920686f706520796f7527726520656e6a6f79696e672074686520537769667453444b2101".hexadecimal)))
        
        let array = MXArray<MXBuffer>(depDecode: &input).toArray()
        let expected: [MXBuffer] = ["a", "Hello World! How's it going? I hope you're enjoying the SwiftSDK!"]
        
        XCTAssertEqual(array, expected)
        XCTAssertEqual(input.canDecodeMore(), true)
    }
    
    func testReplaceFirstElement() throws {
        let array: MXArray<MXBuffer> = [
            "first",
            "second",
            "third"
        ]
        
        let replaced = array.replaced(at: 0, value: "replaced value")
        
        let expected: MXArray<MXBuffer> = [
            "replaced value",
            "second",
            "third"
        ]
        
        XCTAssertEqual(replaced, expected)
    }
    
    func testReplaceSecondElement() throws {
        let array: MXArray<MXBuffer> = [
            "first",
            "second",
            "third"
        ]
        
        let replaced = array.replaced(at: 1, value: "replaced value")
        
        let expected: MXArray<MXBuffer> = [
            "first",
            "replaced value",
            "third"
        ]
        
        XCTAssertEqual(replaced, expected)
    }
    
    func testReplaceThirdElement() throws {
        let array: MXArray<MXBuffer> = [
            "first",
            "second",
            "third"
        ]
        
        let replaced = array.replaced(at: 2, value: "replaced value")
        
        let expected: MXArray<MXBuffer> = [
            "first",
            "second",
            "replaced value"
        ]
        
        XCTAssertEqual(replaced, expected)
    }
    
    func testReplacedOutOfRangeShouldFail() throws {
        do {
            try ArrayOfBuffersTestsContract.testable("").testReplacedOutOfRangeShouldFail()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Index out of range."))
        }
    }
    
}
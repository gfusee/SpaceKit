@testable import SpaceKit
import XCTest

@Codable enum CustomCodableEnum: Equatable {
    case first(Buffer, UInt64, UInt64, Buffer)
    case second(UInt64)
    case third
}

@Contract struct ArrayOfCustomEnumsTestsContract {
    
    public func testGetOutOfRangeShouldFail() {
        let array: Vector<Buffer> = ["Hello!", "Bonjour!", "¡Hola!"]
        
        let _: Vector<CustomCodableEnum> = [
            CustomCodableEnum.first(
                "Hey!",
                10,
                100,
                "How's it going?"
            )
        ]
        
        _ = array[1]
    }
    
    public func testTopDecodeInputTooLarge() {
        let input = Buffer(data: Array("00000001610000004148656c6c6f20576f726c642120486f77277320697420676f696e673f204920686f706520796f7527726520656e6a6f79696e672074686520537769667453444b2101".hexadecimal))
        
        _ = Vector<CustomCodableEnum>(topDecode: input)
    }
    
    public func testReplacedOutOfRangeShouldFail() {
        let array: Vector<CustomCodableEnum> = [
            CustomCodableEnum.first(
                "Hey!",
                10,
                100,
                "How's it going?"
            )
        ]
        
        _ = array.replaced(
            at: 1,
            value: CustomCodableEnum.first(
                "test5",
                80,
                0,
                "test6"
            )
        )
    }
    
}

final class ArrayOfCustomEnumsTests: ContractTestCase {
    
    override var initialAccounts: [WorldAccount] {
        [
            WorldAccount(address: "contract")
        ]
    }
    
    func testEmptyArray() throws {
        let array: Vector<CustomCodableEnum> = Vector()
        
        let count = array.count
        
        XCTAssertEqual(count, 0)
        XCTAssertEqual(array.buffer.count, 0)
    }
    
    func testAppendedOneElementArray() throws {
        var array: Vector<CustomCodableEnum> = Vector()
        array = array.appended(
            CustomCodableEnum.first(
                "Hey!",
                10,
                100,
                "How's it going?"
            )
        )
        
        let count = array.count
        let element = array.get(0)
        let expected = CustomCodableEnum.first(
            "Hey!",
            10,
            100,
            "How's it going?"
        )
        
        XCTAssertEqual(count, 1)
        XCTAssertEqual(element, expected)
        XCTAssertEqual(array.buffer.count, 25)
    }
    
    func testAppendedTwoElementsArray() throws {
        var array: Vector<CustomCodableEnum> = Vector()
        array = array.appended(
            CustomCodableEnum.first(
                "Hey!",
                10,
                100,
                "How's it going?"
            )
        )
        array = array.appended(
            CustomCodableEnum.first(
                "test",
                30,
                5,
                "test2"
            )
        )
        
        let count = array.count
        let firstElement = array.get(0)
        let secondElement = array.get(1)
        
        let firstExpectedElement = CustomCodableEnum.first(
            "Hey!",
            10,
            100,
            "How's it going?"
        )
        
        let secondExpectedElement = CustomCodableEnum.first(
            "test",
            30,
            5,
            "test2"
        )
        
        XCTAssertEqual(count, 2)
        XCTAssertEqual(firstElement, firstExpectedElement)
        XCTAssertEqual(secondElement, secondExpectedElement)
        XCTAssertEqual(array.buffer.count, 50)
    }
    
    func testTwoElementsArrayThroughLiteralAssign() throws {
        let array: Vector<CustomCodableEnum> = [
            CustomCodableEnum.first(
                "Hey!",
                10,
                100,
                "How's it going?"
            ),
            CustomCodableEnum.first(
                "test",
                30,
                5,
                "test2"
            )
        ]
        
        let count = array.count
        let firstElement = array.get(0)
        let secondElement = array.get(1)
        
        let firstExpectedElement = CustomCodableEnum.first(
            "Hey!",
            10,
            100,
            "How's it going?"
        )
        
        let secondExpectedElement = CustomCodableEnum.first(
            "test",
            30,
            5,
            "test2"
        )
        
        XCTAssertEqual(count, 2)
        XCTAssertEqual(firstElement, firstExpectedElement)
        XCTAssertEqual(secondElement, secondExpectedElement)
        XCTAssertEqual(array.buffer.count, 50)
    }
    
    func testThreeDifferentCasesArray() throws {
        let array: Vector<CustomCodableEnum> = [
            CustomCodableEnum.first(
                "Hey!",
                10,
                100,
                "How's it going?"
            ),
            CustomCodableEnum.second(50),
            CustomCodableEnum.third
        ]
        
        let count = array.count
        let firstElement = array.get(0)
        let secondElement = array.get(1)
        let thirdElement = array.get(2)
        
        let firstExpectedElement = CustomCodableEnum.first(
            "Hey!",
            10,
            100,
            "How's it going?"
        )
        let secondExpectedElement = CustomCodableEnum.second(50)
        let thirdExpectedElement = CustomCodableEnum.third
        
        XCTAssertEqual(count, 3)
        XCTAssertEqual(firstElement, firstExpectedElement)
        XCTAssertEqual(secondElement, secondExpectedElement)
        XCTAssertEqual(thirdElement, thirdExpectedElement)
        XCTAssertEqual(array.buffer.count, 75)
    }
    
    func testAppendedContentsOf() throws {
        let array1: Vector<CustomCodableEnum> = [
            CustomCodableEnum.first(
                "Hey!",
                10,
                100,
                "How's it going?"
            ),
            CustomCodableEnum.first(
                "test",
                30,
                5,
                "test2"
            )
        ]
        
        let array2: Vector<CustomCodableEnum> = [
            CustomCodableEnum.first(
                "test3",
                1,
                76,
                "test4"
            ),
            CustomCodableEnum.first(
                "test5",
                80,
                0,
                "test6"
            )
        ]
        
        let array = array1.appended(contentsOf: array2)
        let expected: Vector<CustomCodableEnum> = [
            CustomCodableEnum.first(
                "Hey!",
                10,
                100,
                "How's it going?"
            ),
            CustomCodableEnum.first(
                "test",
                30,
                5,
                "test2"
            ),
            CustomCodableEnum.first(
                "test3",
                1,
                76,
                "test4"
            ),
            CustomCodableEnum.first(
                "test5",
                80,
                0,
                "test6"
            )
        ]
        
        XCTAssertEqual(array, expected)
    }
    
    func testEquatableWhenEqual() throws {
        let array1: Vector<CustomCodableEnum> = [
            CustomCodableEnum.first(
                "Hey!",
                10,
                100,
                "How's it going?"
            ),
            CustomCodableEnum.first(
                "test",
                30,
                5,
                "test2"
            )
        ]
        
        let array2: Vector<CustomCodableEnum> = [
            CustomCodableEnum.first(
                "Hey!",
                10,
                100,
                "How's it going?"
            ),
            CustomCodableEnum.first(
                "test",
                30,
                5,
                "test2"
            )
        ]
        
        XCTAssertEqual(array1, array2)
    }
    
    func testEquatableWhenDifferentCount() throws {
        let array1: Vector<CustomCodableEnum> = [
            CustomCodableEnum.first(
                "Hey!",
                10,
                100,
                "How's it going?"
            ),
            CustomCodableEnum.first(
                "test",
                30,
                5,
                "test2"
            )
        ]
        let array2: Vector<CustomCodableEnum> = [
            CustomCodableEnum.first(
                "Hey!",
                10,
                100,
                "How's it going?"
            )
        ]
        
        XCTAssertNotEqual(array1, array2)
    }
    
    func testEquatableWhenDifferentValues() throws {
        let array1: Vector<CustomCodableEnum> = [
            CustomCodableEnum.first(
                "Hey!",
                10,
                100,
                "How's it going?"
            ),
            CustomCodableEnum.first(
                "test",
                30,
                5,
                "test2"
            )
        ]
        
        let array2: Vector<CustomCodableEnum> = [
            CustomCodableEnum.first(
                "Hey!",
                99,
                100,
                "How's it going?"
            ),
            CustomCodableEnum.first(
                "test",
                30,
                5,
                "test2"
            )
        ]
        
        XCTAssertNotEqual(array1, array2)
    }
    
    func testPlusOperator() throws { // TODO: ???????? why tf there is a nested function
        func testAppendedContentsOf() throws {
            let array1: Vector<CustomCodableEnum> = [
                CustomCodableEnum.first(
                    "Hey!",
                    10,
                    100,
                    "How's it going?"
                ),
                CustomCodableEnum.first(
                    "test",
                    30,
                    5,
                    "test2"
                )
            ]
            
            let array2: Vector<CustomCodableEnum> = [
                CustomCodableEnum.first(
                    "test3",
                    1,
                    76,
                    "test4"
                ),
                CustomCodableEnum.first(
                    "test5",
                    80,
                    0,
                    "test6"
                )
            ]
            
            let array = array1 + array2
            let expected: Vector<CustomCodableEnum> = [
                CustomCodableEnum.first(
                    "Hey!",
                    10,
                    100,
                    "How's it going?"
                ),
                CustomCodableEnum.first(
                    "test",
                    30,
                    5,
                    "test2"
                ),
                CustomCodableEnum.first(
                    "test3",
                    1,
                    76,
                    "test4"
                ),
                CustomCodableEnum.first(
                    "test5",
                    80,
                    0,
                    "test6"
                )
            ]
            
            XCTAssertEqual(array, expected)
        }
    }
    
    func testAppendedTwoElementsArrayThroughSubscript() throws {
        var array: Vector<CustomCodableEnum> = Vector()
        array = array.appended(
            CustomCodableEnum.first(
                "Hey!",
                10,
                100,
                "How's it going?"
            )
        )
        array = array.appended(
            CustomCodableEnum.first(
                "test",
                30,
                5,
                "test2"
            )
        )
        
        let count = array.count
        let firstElement = array[0]
        let secondElement = array[1]
        
        let firstExpectedElement = CustomCodableEnum.first(
            "Hey!",
            10,
            100,
            "How's it going?"
        )
        
        let secondExpectedElement = CustomCodableEnum.first(
            "test",
            30,
            5,
            "test2"
        )
        
        XCTAssertEqual(count, 2)
        XCTAssertEqual(firstElement, firstExpectedElement)
        XCTAssertEqual(secondElement, secondExpectedElement)
        XCTAssertEqual(array.buffer.count, 50)
    }
    
    func testGetOutOfRangeShouldFail() throws {
        do {
            try self.deployContract(ArrayOfBuffersTestsContract.self, at: "contract").testGetOutOfRangeShouldFail()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Index out of range."))
        }
    }
    
    func testForLoopZeroElement() throws {
        let array: Vector<CustomCodableEnum> = Vector()
        
        array.forEach { _ in XCTFail() }
    }
    
    func testForLoopOneElement() throws {
        var array: Vector<CustomCodableEnum> = Vector()
        array = array.appended(
            CustomCodableEnum.first(
                "Hey!",
                10,
                100,
                "How's it going?"
            )
        )
        
        array.forEach { item in
            XCTAssertEqual(
                item,
                CustomCodableEnum.first(
                    "Hey!",
                    10,
                    100,
                    "How's it going?"
                )
            )
        }
    }
    
    func testForLoopTwoElements() throws {
        var array: Vector<CustomCodableEnum> = Vector()
        array = array.appended(
            CustomCodableEnum.first(
                "Hey!",
                10,
                100,
                "How's it going?"
            )
        )
        array = array.appended(
            CustomCodableEnum.first(
                "test",
                30,
                5,
                "test2"
            )
        )
        
        var heapArray: [CustomCodableEnum] = []
        
        array.forEach { heapArray.append($0) }
        
        let expected: [CustomCodableEnum] = [
            CustomCodableEnum.first(
                "Hey!",
                10,
                100,
                "How's it going?"
            ),
            CustomCodableEnum.first(
                "test",
                30,
                5,
                "test2"
            )
        ]
        
        XCTAssertEqual(heapArray, expected)
    }
    
    func testTopEncodeZeroElement() throws {
        let array: Vector<CustomCodableEnum> = Vector()
        
        var output = Buffer()
        array.topEncode(output: &output)
        
        let expected: Buffer = ""
        
        XCTAssertEqual(output, expected)
    }
    
    func testTopEncodeOneElement() throws {
        var array: Vector<CustomCodableEnum> = Vector()
        array = array.appended(
            CustomCodableEnum.first(
                "Hey!",
                10,
                100,
                "How's it going?"
            )
        )
        
        var output = Buffer()
        array.topEncode(output: &output)
        
        let expected = Buffer(data: Array("000000000448657921000000000000000a00000000000000640000000f486f77277320697420676f696e673f".hexadecimal))
        
        XCTAssertEqual(output, expected)
    }
    
    func testTopEncodeTwoElements() throws {
        var array: Vector<CustomCodableEnum> = Vector()
        array = array.appended(
            CustomCodableEnum.first(
                "Hey!",
                10,
                100,
                "How's it going?"
            )
        )
        array = array.appended(
            CustomCodableEnum.first(
                "test",
                30,
                5,
                "test2"
            )
        )
        
        var output = Buffer()
        array.topEncode(output: &output)
        
        let expected = Buffer(data: Array("000000000448657921000000000000000a00000000000000640000000f486f77277320697420676f696e673f000000000474657374000000000000001e0000000000000005000000057465737432".hexadecimal))
        
        XCTAssertEqual(output, expected)
    }
    
    func testTopEncodeThreeDifferentCases() throws {
        let array: Vector<CustomCodableEnum> = [
            CustomCodableEnum.first(
                "Hey!",
                10,
                100,
                "How's it going?"
            ),
            CustomCodableEnum.second(50),
            CustomCodableEnum.third
        ]
        
        var output = Buffer()
        array.topEncode(output: &output)
        
        let expected = Buffer(data: Array("000000000448657921000000000000000a00000000000000640000000f486f77277320697420676f696e673f01000000000000003202".hexadecimal))
        
        XCTAssertEqual(output, expected)
    }
    
    func testNestedEncodeZeroElement() throws {
        let array: Vector<CustomCodableEnum> = Vector()
        
        var output = Buffer()
        array.depEncode(dest: &output)
        
        let expected = Buffer(data: Array("00000000".hexadecimal))
        
        XCTAssertEqual(output, expected)
    }
    
    func testNestedEncodeOneElement() throws {
        var array: Vector<CustomCodableEnum> = Vector()
        array = array.appended(
            CustomCodableEnum.first(
                "Hey!",
                10,
                100,
                "How's it going?"
            )
        )
        
        var output = Buffer()
        array.depEncode(dest: &output)
        
        let expected = Buffer(data: Array("00000001000000000448657921000000000000000a00000000000000640000000f486f77277320697420676f696e673f".hexadecimal))
        
        XCTAssertEqual(output, expected)
    }
    
    func testNestedEncodeTwoElements() throws {
        var array: Vector<CustomCodableEnum> = Vector()
        array = array.appended(
            CustomCodableEnum.first(
                "Hey!",
                10,
                100,
                "How's it going?"
            )
        )
        array = array.appended(
            CustomCodableEnum.first(
                "test",
                30,
                5,
                "test2"
            )
        )
        
        var output = Buffer()
        array.depEncode(dest: &output)
        
        let expected = Buffer(data: Array("00000002000000000448657921000000000000000a00000000000000640000000f486f77277320697420676f696e673f000000000474657374000000000000001e0000000000000005000000057465737432".hexadecimal))
        
        XCTAssertEqual(output, expected)
    }
    
    func testNestedEncodeThreeDifferentCases() throws {
        let array: Vector<CustomCodableEnum> = [
            CustomCodableEnum.first(
                "Hey!",
                10,
                100,
                "How's it going?"
            ),
            CustomCodableEnum.second(50),
            CustomCodableEnum.third
        ]
        
        var output = Buffer()
        array.depEncode(dest: &output)
        
        let expected = Buffer(data: Array("00000003000000000448657921000000000000000a00000000000000640000000f486f77277320697420676f696e673f01000000000000003202".hexadecimal))
        
        XCTAssertEqual(output, expected)
    }
    
    func testTopDecodeZeroElement() throws {
        let input = Buffer(data: Array("".hexadecimal))
        
        let array = Vector<CustomCodableEnum>(topDecode: input)
        let expected: Vector<CustomCodableEnum> = []
        
        XCTAssertEqual(array, expected)
    }
    
    func testTopDecodeOneElement() throws {
        let input = Buffer(data: Array("000000000448657921000000000000000a00000000000000640000000f486f77277320697420676f696e673f".hexadecimal))
        
        let array = Vector<CustomCodableEnum>(topDecode: input)
        let expected: Vector<CustomCodableEnum> = [
            CustomCodableEnum.first(
                "Hey!",
                10,
                100,
                "How's it going?"
            )
        ]
        
        XCTAssertEqual(array, expected)
    }
    
    func testTopDecodeTwoElements() throws {
        let input = Buffer(data: Array("000000000448657921000000000000000a00000000000000640000000f486f77277320697420676f696e673f000000000474657374000000000000001e0000000000000005000000057465737432".hexadecimal))
        
        let array = Vector<CustomCodableEnum>(topDecode: input)
        let expected: Vector<CustomCodableEnum> = [
            CustomCodableEnum.first(
                "Hey!",
                10,
                100,
                "How's it going?"
            ),
            CustomCodableEnum.first(
                "test",
                30,
                5,
                "test2"
            )
        ]
        
        XCTAssertEqual(array, expected)
    }
    
    func testTopDecodeThreeDifferentCases() throws {
        let input = Buffer(data: Array("000000000448657921000000000000000a00000000000000640000000f486f77277320697420676f696e673f01000000000000003202".hexadecimal))
        
        let array = Vector<CustomCodableEnum>(topDecode: input)
        let expected: Vector<CustomCodableEnum> = [
            CustomCodableEnum.first(
                "Hey!",
                10,
                100,
                "How's it going?"
            ),
            CustomCodableEnum.second(50),
            CustomCodableEnum.third
        ]
        
        XCTAssertEqual(array, expected)
    }
    
    func testNestedDecodeZeroElement() throws {
        var input = BufferNestedDecodeInput(buffer: Buffer(data: Array("00000000".hexadecimal)))
        
        let array = Vector<CustomCodableEnum>(depDecode: &input)
        let expected: Vector<CustomCodableEnum> = []
        
        XCTAssertEqual(array, expected)
    }
    
    func testNestedDecodeOneElement() throws {
        var input = BufferNestedDecodeInput(buffer: Buffer(data: Array("00000001000000000448657921000000000000000a00000000000000640000000f486f77277320697420676f696e673f".hexadecimal)))
        
        let array = Vector<CustomCodableEnum>(depDecode: &input)
        let expected: Vector<CustomCodableEnum> = [
            CustomCodableEnum.first(
                "Hey!",
                10,
                100,
                "How's it going?"
            )
        ]
        
        XCTAssertEqual(array, expected)
    }
    
    func testNestedDecodeTwoElements() throws {
        var input = BufferNestedDecodeInput(buffer: Buffer(data: Array("00000002000000000448657921000000000000000a00000000000000640000000f486f77277320697420676f696e673f000000000474657374000000000000001e0000000000000005000000057465737432".hexadecimal)))
        
        let array = Vector<CustomCodableEnum>(depDecode: &input)
        let expected: Vector<CustomCodableEnum> = [
            CustomCodableEnum.first(
                "Hey!",
                10,
                100,
                "How's it going?"
            ),
            CustomCodableEnum.first(
                "test",
                30,
                5,
                "test2"
            )
        ]
        
        XCTAssertEqual(array, expected)
    }
    
    func testNestedDecodeTwoElementsAndInputLarger() throws {
        var input = BufferNestedDecodeInput(buffer: Buffer(data: Array("00000002000000000448657921000000000000000a00000000000000640000000f486f77277320697420676f696e673f000000000474657374000000000000001e000000000000000500000005746573743201".hexadecimal)))
        
        let array = Vector<CustomCodableEnum>(depDecode: &input)
        let expected: Vector<CustomCodableEnum> = [
            CustomCodableEnum.first(
                "Hey!",
                10,
                100,
                "How's it going?"
            ),
            CustomCodableEnum.first(
                "test",
                30,
                5,
                "test2"
            )
        ]
        
        XCTAssertEqual(array, expected)
        XCTAssertEqual(input.canDecodeMore(), true)
    }
    
    func testNestedDecodeThreeDifferentCases() throws {
        var input = BufferNestedDecodeInput(buffer: Buffer(data: Array("00000003000000000448657921000000000000000a00000000000000640000000f486f77277320697420676f696e673f0100000000000000320201".hexadecimal)))
        
        let array = Vector<CustomCodableEnum>(depDecode: &input)
        let expected: Vector<CustomCodableEnum> = [
            CustomCodableEnum.first(
                "Hey!",
                10,
                100,
                "How's it going?"
            ),
            CustomCodableEnum.second(50),
            CustomCodableEnum.third
        ]
        
        XCTAssertEqual(array, expected)
        XCTAssertEqual(input.canDecodeMore(), true)
    }
    
    func testNestedDecodeThreeDifferentCasesLargerBuffer() throws {
        var input = BufferNestedDecodeInput(buffer: Buffer(data: Array("00000003000000000448657921000000000000000a00000000000000640000000f486f77277320697420676f696e673f01000000000000003202".hexadecimal)))
        
        let array = Vector<CustomCodableEnum>(depDecode: &input)
        let expected: Vector<CustomCodableEnum> = [
            CustomCodableEnum.first(
                "Hey!",
                10,
                100,
                "How's it going?"
            ),
            CustomCodableEnum.second(50),
            CustomCodableEnum.third
        ]
        
        XCTAssertEqual(array, expected)
    }
    
    func testReplaceFirstElement() throws {
        let array: Vector<CustomCodableEnum> = [
            CustomCodableEnum.first(
                "Hey!",
                10,
                100,
                "How's it going?"
            ),
            CustomCodableEnum.first(
                "test",
                30,
                5,
                "test2"
            ),
            CustomCodableEnum.first(
                "test3",
                1,
                76,
                "test4"
            )
        ]
        
        let replaced = array.replaced(
            at: 0,
            value: CustomCodableEnum.first(
                "replaced value 1",
                10,
                100,
                "replaced value 2"
            )
        )
        
        let expected: Vector<CustomCodableEnum> = [
            CustomCodableEnum.first(
                "replaced value 1",
                10,
                100,
                "replaced value 2"
            ),
            CustomCodableEnum.first(
                "test",
                30,
                5,
                "test2"
            ),
            CustomCodableEnum.first(
                "test3",
                1,
                76,
                "test4"
            )
        ]
        
        XCTAssertEqual(replaced, expected)
    }
    
    func testReplaceSecondElement() throws {
        let array: Vector<CustomCodableEnum> = [
            CustomCodableEnum.first(
                "Hey!",
                10,
                100,
                "How's it going?"
            ),
            CustomCodableEnum.first(
                "test",
                30,
                5,
                "test2"
            ),
            CustomCodableEnum.first(
                "test3",
                1,
                76,
                "test4"
            )
        ]
        
        let replaced = array.replaced(
            at: 1,
            value: CustomCodableEnum.first(
                "replaced value 1",
                10,
                100,
                "replaced value 2"
            )
        )
        
        let expected: Vector<CustomCodableEnum> = [
            CustomCodableEnum.first(
                "Hey!",
                10,
                100,
                "How's it going?"
            ),
            CustomCodableEnum.first(
                "replaced value 1",
                10,
                100,
                "replaced value 2"
            ),
            CustomCodableEnum.first(
                "test3",
                1,
                76,
                "test4"
            )
        ]
        
        XCTAssertEqual(replaced, expected)
    }
    
    func testReplaceThirdElement() throws {
        let array: Vector<CustomCodableEnum> = [
            CustomCodableEnum.first(
                "Hey!",
                10,
                100,
                "How's it going?"
            ),
            CustomCodableEnum.first(
                "test",
                30,
                5,
                "test2"
            ),
            CustomCodableEnum.first(
                "test3",
                1,
                76,
                "test4"
            )
        ]
        
        let replaced = array.replaced(
            at: 2,
            value: CustomCodableEnum.first(
                "replaced value 1",
                10,
                100,
                "replaced value 2"
            )
        )
        
        let expected: Vector<CustomCodableEnum> = [
            CustomCodableEnum.first(
                "Hey!",
                10,
                100,
                "How's it going?"
            ),
            CustomCodableEnum.first(
                "test",
                30,
                5,
                "test2"
            ),
            CustomCodableEnum.first(
                "replaced value 1",
                10,
                100,
                "replaced value 2"
            )
        ]
        
        XCTAssertEqual(replaced, expected)
    }
    
    func testReplacedOutOfRangeShouldFail() throws {
        do {
            try self.deployContract(ArrayOfBuffersTestsContract.self, at: "contract").testReplacedOutOfRangeShouldFail()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Index out of range."))
        }
    }
}

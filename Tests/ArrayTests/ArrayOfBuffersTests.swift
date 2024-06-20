import MultiversX
import XCTest

@Contract struct ArrayOfBuffersTestsContract {
    
    public func testGetOutOfRangeShouldFail() {
        var array: MXArray<MXBuffer> = MXArray()
        array = array.appended("Hey!")
        
        _ = array[1]
    }
    
}

final class ArrayOfBuffersTests: ContractTestCase {
    
    func testEmptyArray() throws {
        let array: MXArray<MXBuffer> = MXArray()
        
        let count = array.count
        
        XCTAssertEqual(count, 0)
    }
    
    func testAppendedOneElementArray() throws {
        var array: MXArray<MXBuffer> = MXArray()
        array = array.appended("Hey!")
        
        let count = array.count
        let element = array.get(0)
        
        XCTAssertEqual(count, 1)
        XCTAssertEqual(element, "Hey!")
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
    
    func testGetOutOfRangeShouldFail() {
        do {
            try ArrayOfBuffersTestsContract.testable("").testGetOutOfRangeShouldFail()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Index out of range."))
        }
    }
    
}

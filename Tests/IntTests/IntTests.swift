import XCTest
import MultiversX

final class IntTests: XCTestCase {
    
    func testTopEncodeIntZero() throws {
        var output = MXBuffer()
        let value: Int = 0
        
        value.topEncode(output: &output)
        
        let expected = ""
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testTopEncodeIntOne() throws {
        var output = MXBuffer()
        let value: Int = 1
        
        value.topEncode(output: &output)
        
        let expected = "01"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testTopEncodeIntTen() throws {
        var output = MXBuffer()
        let value: Int = 10
        
        value.topEncode(output: &output)
        
        let expected = "0a"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testTopEncodeIntThousand() throws {
        var output = MXBuffer()
        let value: Int = 1000
        
        value.topEncode(output: &output)
        
        let expected = "03e8"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testTopEncodeIntMax() throws {
        var output = MXBuffer()
        let value: Int = Int(Int32.max)
        
        value.topEncode(output: &output)
        
        let expected = "7fffffff"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testNestedEncodeIntZero() throws {
        var output = MXBuffer()
        let value: Int = 0
        
        value.depEncode(dest: &output)
        
        let expected = "00000000"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testNestedEncodeIntOne() throws {
        var output = MXBuffer()
        let value: Int = 1
        
        value.depEncode(dest: &output)
        
        let expected = "00000001"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testNestedEncodeIntTen() throws {
        var output = MXBuffer()
        let value: Int = 10
        
        value.depEncode(dest: &output)
        
        let expected = "0000000a"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testNestedEncodeIntThousand() throws {
        var output = MXBuffer()
        let value: Int = 1000
        
        value.depEncode(dest: &output)
        
        let expected = "000003e8"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
    func testNestedEncodeIntMax() throws {
        var output = MXBuffer()
        let value: Int = Int(Int32.max)
        
        value.depEncode(dest: &output)
        
        let expected = "7fffffff"
        
        XCTAssertEqual(output.hexDescription, expected)
    }
    
}

import XCTest
import MultiversX

final class BigUintTests: XCTestCase {
    
    func testZeroBigUint() throws {
        let bigUint = BigUint()
        
        XCTAssertEqual(bigUint, 0)
    }
    
    func testNonZeroBigUint() throws {
        let bigUint = BigUint(value: 4)
        
        XCTAssertEqual(bigUint, 4)
    }
    
    func testZeroLiteralBigUint() throws {
        let bigUint: BigUint = 0
        
        XCTAssertEqual(bigUint, 0)
    }
    
    func testNonZeroLiteralBigUint() throws {
        let bigUint: BigUint = 4
        
        XCTAssertEqual(bigUint, 4)
    }
    
    func testCompareDifferentBigUints() throws {
        let bigUint1: BigUint = 1
        let bigUint2: BigUint = 2
        
        XCTAssertNotEqual(bigUint1, bigUint2)
    }
    
}

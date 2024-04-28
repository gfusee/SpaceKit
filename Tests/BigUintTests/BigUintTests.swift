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
    
    func testAddTwoBigUint() throws {
        let bigUint1: BigUint = 1
        let bigUint2: BigUint = 2
        
        let result = bigUint1 + bigUint2
        
        XCTAssertEqual(result, 3)
    }
    
    func testAddBigUintAndLiteral() throws {
        let bigUint1: BigUint = 1
        
        let result = bigUint1 + 2
        
        XCTAssertEqual(result, 3)
    }
    
    func testSubstractTwoBigUint() throws {
        let bigUint1: BigUint = 1
        let bigUint2: BigUint = 2
        
        let result = bigUint2 - bigUint1
        
        XCTAssertEqual(result, 1)
    }
    
    func testSubstractTwoBigUintNegativeShouldFail() throws {
        let bigUint1: BigUint = 1
        let bigUint2: BigUint = 2
        
        let _ = bigUint1 - bigUint2
        
        XCTAssertEqual(MultiversX.API.errorMessage, "Cannot substract because the result would be negative.")
    }
    
    func testMultiplyTwoBigUint() throws {
        let bigUint1: BigUint = 2
        let bigUint2: BigUint = 3
        
        let result = bigUint1 * bigUint2
        
        XCTAssertEqual(result, 6)
    }
    
    func testDivideTwoBigUint() throws {
        let bigUint1: BigUint = 10
        let bigUint2: BigUint = 2
        
        let result = bigUint1 / bigUint2
        
        XCTAssertEqual(result, 5)
    }
    
    func testDivideTwoBigUintTruncated() throws {
        let bigUint1: BigUint = 10
        let bigUint2: BigUint = 3
        
        let result = bigUint1 / bigUint2
        
        XCTAssertEqual(result, 3)
    }
    
    func testDivideTwoBigUintLeftSideLessThanRightSide() throws {
        let bigUint1: BigUint = 1
        let bigUint2: BigUint = 2
        
        let result = bigUint1 / bigUint2
        
        XCTAssertEqual(result, 0)
    }
    
    func testDivideTwoBigUintZeroRightSideShouldFail() throws {
        let bigUint1: BigUint = 1
        let bigUint2: BigUint = 0
        
        let _ = bigUint1 / bigUint2
        
        XCTAssertEqual(MultiversX.API.errorMessage, "Cannot divide by zero.")
    }
    
    func testModuloTwoBigUint() throws {
        let bigUint1: BigUint = 10
        let bigUint2: BigUint = 2
        
        let result = bigUint1 % bigUint2
        
        XCTAssertEqual(result, 0)
    }
    
    func testModuloTwoBigUintNotZeroResult() throws {
        let bigUint1: BigUint = 10
        let bigUint2: BigUint = 3
        
        let result = bigUint1 % bigUint2
        
        XCTAssertEqual(result, 1)
    }
    
    func testModuloTwoBigUintLeftSideLessThanRightSide() throws {
        let bigUint1: BigUint = 2
        let bigUint2: BigUint = 5
        
        let result = bigUint1 % bigUint2
        
        XCTAssertEqual(result, 2)
    }
    
    func testModuloTwoBigUintZeroRightSideShouldFail() throws {
        let bigUint1: BigUint = 1
        let bigUint2: BigUint = 0
        
        let _ = bigUint1 % bigUint2
        
        XCTAssertEqual(MultiversX.API.errorMessage, "Cannot divide by zero (modulo).")
    }
    
    func testCompareGreaterTrue() throws {
        let bigUint1: BigUint = 5
        let bigUint2: BigUint = 2
        
        XCTAssert(bigUint1 > bigUint2)
    }
    
    func testCompareGreaterFalse() throws {
        let bigUint1: BigUint = 2
        let bigUint2: BigUint = 5
        
        XCTAssertFalse(bigUint1 > bigUint2)
    }
    
    func testCompareGreaterFalseWhenEqual() throws {
        let bigUint1: BigUint = 5
        let bigUint2: BigUint = 5
        
        XCTAssertFalse(bigUint1 > bigUint2)
    }
    
    func testCompareGreaterOrEqualTrue() throws {
        let bigUint1: BigUint = 5
        let bigUint2: BigUint = 2
        
        XCTAssert(bigUint1 >= bigUint2)
    }
    
    func testCompareGreaterOrEqualTrueWhenEqual() throws {
        let bigUint1: BigUint = 5
        let bigUint2: BigUint = 5
        
        XCTAssert(bigUint1 >= bigUint2)
    }
    
    func testCompareGreaterOrEqualFalse() throws {
        let bigUint1: BigUint = 2
        let bigUint2: BigUint = 5
        
        XCTAssertFalse(bigUint1 >= bigUint2)
    }
    
    func testCompareLessTrue() throws {
        let bigUint1: BigUint = 2
        let bigUint2: BigUint = 5
        
        XCTAssert(bigUint1 < bigUint2)
    }
    
    func testCompareLessFalse() throws {
        let bigUint1: BigUint = 5
        let bigUint2: BigUint = 2
        
        XCTAssertFalse(bigUint1 < bigUint2)
    }
    
    func testCompareLessFalseWhenEqual() throws {
        let bigUint1: BigUint = 5
        let bigUint2: BigUint = 5
        
        XCTAssertFalse(bigUint1 < bigUint2)
    }
}

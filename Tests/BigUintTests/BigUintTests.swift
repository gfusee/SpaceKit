import XCTest
import Space

@Contract struct BigUintTestsContract {
    public func testSubstractTwoBigUintNegativeShouldFail() {
        let bigUint1: BigUint = 1
        let bigUint2: BigUint = 2
        let _ = bigUint1 - bigUint2
    }
    
    public func testModuloTwoBigUintZeroRightSideShouldFail() {
        let bigUint1: BigUint = 1
        let bigUint2: BigUint = 0
        let _ = bigUint1 % bigUint2
    }
    
    public func testDivideTwoBigUintZeroRightSideShouldFail() {
        let bigUint1: BigUint = 1
        let bigUint2: BigUint = 0
        let _ = bigUint1 / bigUint2
    }
    
    public func testAddBigUintAndNegativeLiteralShouldFail() {
        let bigUint: BigUint = 1
        let integer = -1
        
        let _ = bigUint + integer
    }
    
    public func testAddNegativeLiteralAndBigUintShouldFail() {
        let bigUint: BigUint = 1
        let integer = -1
        
        let _ = integer + bigUint
    }
    
    public func testRemoveBigUintAndNegativeLiteralShouldFail() {
        let bigUint: BigUint = 1
        let integer = -1
        
        let _ = bigUint - integer
    }
    
    public func testRemoveNegativeLiteralAndBigUintShouldFail() {
        let bigUint: BigUint = 1
        let integer = -1
        
        let _ = integer - bigUint
    }
}

final class BigUintTests: ContractTestCase {

    override var initialAccounts: [WorldAccount] {
        [
            WorldAccount(address: "contract")
        ]
    }
    
    func testZeroBigUint() throws {
        let bigUint = BigUint()
        
        XCTAssertEqual(bigUint, 0)
    }
    
    func testNonZeroBigUint() throws {
        let bigUint: BigUint = 4
        
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
    
    func testCompareBigUintAndUInt8() throws {
        let bigUint: BigUint = 1
        let integer: UInt8 = 1
        
        XCTAssert(bigUint == integer)
    }
    
    func testCompareUInt8AndBigUint() throws {
        let bigUint: BigUint = 1
        let integer: UInt8 = 1
        
        XCTAssert(integer == bigUint)
    }
    
    func testCompareBigUintAndUInt16() throws {
        let bigUint: BigUint = 1
        let integer: UInt16 = 1
        
        XCTAssert(bigUint == integer)
    }
    
    func testCompareUInt16AndBigUint() throws {
        let bigUint: BigUint = 1
        let integer: UInt16 = 1
        
        XCTAssert(integer == bigUint)
    }
    
    func testCompareBigUintAndUInt32() throws {
        let bigUint: BigUint = 1
        let integer: UInt32 = 1
        
        XCTAssert(bigUint == integer)
    }
    
    func testCompareUInt32AndBigUint() throws {
        let bigUint: BigUint = 1
        let integer: UInt32 = 1
        
        XCTAssert(integer == bigUint)
    }
    
    func testCompareBigUintAndUInt64() throws {
        let bigUint: BigUint = 1
        let integer: UInt64 = 1
        
        XCTAssert(bigUint == integer)
    }
    
    func testCompareUInt64AndBigUint() throws {
        let bigUint: BigUint = 1
        let integer: UInt64 = 1
        
        XCTAssert(integer == bigUint)
    }
    
    func testCompareBigUintAndLiteralInteger() throws {
        let bigUint: BigUint = 1
        let integer = 1
        
        XCTAssert(bigUint == integer)
    }
    
    func testCompareLiteralIntegerAndBigUint() throws {
        let bigUint: BigUint = 1
        let integer = 1
        
        XCTAssert(integer == bigUint)
    }
    
    func testNotEqualBigUintAndUInt8() throws {
        let bigUint: BigUint = 5
        let integer: UInt8 = 5
        let differentInteger: UInt8 = 3

        XCTAssertFalse(bigUint != integer)
        XCTAssert(bigUint != differentInteger)
    }

    func testNotEqualBigUintAndUInt16() throws {
        let bigUint: BigUint = 5
        let integer: UInt16 = 5
        let differentInteger: UInt16 = 3

        XCTAssertFalse(bigUint != integer)
        XCTAssert(bigUint != differentInteger)
    }

    func testNotEqualBigUintAndUInt32() throws {
        let bigUint: BigUint = 5
        let integer: UInt32 = 5
        let differentInteger: UInt32 = 3

        XCTAssertFalse(bigUint != integer)
        XCTAssert(bigUint != differentInteger)
    }

    func testNotEqualBigUintAndUInt64() throws {
        let bigUint: BigUint = 5
        let integer: UInt64 = 5
        let differentInteger: UInt64 = 3

        XCTAssertFalse(bigUint != integer)
        XCTAssert(bigUint != differentInteger)
    }

    func testNotEqualBigUintAndLiteralInteger() throws {
        let bigUint: BigUint = 5
        let integer = 5
        let differentInteger = 3

        XCTAssertFalse(bigUint != integer)
        XCTAssert(bigUint != differentInteger)
    }
    
    func testAddTwoBigUint() throws {
        let bigUint1: BigUint = 1
        let bigUint2: BigUint = 2
        
        let result = bigUint1 + bigUint2
        
        XCTAssertEqual(result, 3)
    }
    
    func testAddBigUintAndUInt8() throws {
        let bigUint: BigUint = 1
        let integer: UInt8 = 2
        
        let result = bigUint + integer
        
        XCTAssertEqual(result, 3)
    }
    
    func testAddUInt8AndBigUint() throws {
        let bigUint: BigUint = 1
        let integer: UInt8 = 2
        
        let result = integer + bigUint
        
        XCTAssertEqual(result, 3)
    }
    
    func testAddBigUintAndUInt16() throws {
        let bigUint: BigUint = 1
        let integer: UInt16 = 2
        
        let result = bigUint + integer
        
        XCTAssertEqual(result, 3)
    }
    
    func testAddUInt16AndBigUint() throws {
        let bigUint: BigUint = 1
        let integer: UInt16 = 2
        
        let result = integer + bigUint
        
        XCTAssertEqual(result, 3)
    }
    
    func testAddBigUintAndUInt32() throws {
        let bigUint: BigUint = 1
        let integer: UInt32 = 2
        
        let result = bigUint + integer
        
        XCTAssertEqual(result, 3)
    }
    
    func testAddUInt32AndBigUint() throws {
        let bigUint: BigUint = 1
        let integer: UInt32 = 2
        
        let result = integer + bigUint
        
        XCTAssertEqual(result, 3)
    }
    
    func testAddUInt64AndBigUint() throws {
        let bigUint: BigUint = 1
        let integer: UInt64 = 2
        
        let result = integer + bigUint
        
        XCTAssertEqual(result, 3)
    }
    
    func testAddBigUintAndUInt64() throws {
        let bigUint: BigUint = 1
        let integer: UInt64 = 2
        
        let result = bigUint + integer
        
        XCTAssertEqual(result, 3)
    }
    
    func testAddBigUintAndLiteralInt() throws {
        let bigUint: BigUint = 1
        let integer = 2
        
        let result = bigUint + integer
        
        XCTAssertEqual(result, 3)
    }
    
    func testAddLiteralIntAndBigUint() throws {
        let bigUint: BigUint = 1
        let integer = 2
        
        let result = integer + bigUint
        
        XCTAssertEqual(result, 3)
    }
    
    func testRemoveBigUintAndUInt8() throws {
        let bigUint: BigUint = 2
        let integer: UInt8 = 1
        
        let result = bigUint - integer
        
        XCTAssertEqual(result, 1)
    }
    
    func testRemoveUInt8AndBigUint() throws {
        let bigUint: BigUint = 1
        let integer: UInt8 = 2
        
        let result = integer - bigUint
        
        XCTAssertEqual(result, 1)
    }
    
    func testRemoveBigUintAndUInt16() throws {
        let bigUint: BigUint = 2
        let integer: UInt16 = 1
        
        let result = bigUint - integer
        
        XCTAssertEqual(result, 1)
    }
    
    func testRemoveUInt16AndBigUint() throws {
        let bigUint: BigUint = 1
        let integer: UInt16 = 2
        
        let result = integer - bigUint
        
        XCTAssertEqual(result, 1)
    }
    
    func testRemoveBigUintAndUInt32() throws {
        let bigUint: BigUint = 2
        let integer: UInt32 = 1
        
        let result = bigUint - integer
        
        XCTAssertEqual(result, 1)
    }
    
    func testRemoveUInt32AndBigUint() throws {
        let bigUint: BigUint = 1
        let integer: UInt32 = 2
        
        let result = integer - bigUint
        
        XCTAssertEqual(result, 1)
    }
    
    func testRemoveUInt64AndBigUint() throws {
        let bigUint: BigUint = 1
        let integer: UInt64 = 2
        
        let result = integer - bigUint
        
        XCTAssertEqual(result, 1)
    }
    
    func testRemoveBigUintAndUInt64() throws {
        let bigUint: BigUint = 2
        let integer: UInt64 = 1
        
        let result = bigUint - integer
        
        XCTAssertEqual(result, 1)
    }
    
    func testRemoveBigUintAndLiteralInt() throws {
        let bigUint: BigUint = 2
        let integer = 1
        
        let result = bigUint - integer
        
        XCTAssertEqual(result, 1)
    }
    
    func testRemoveLiteralIntAndBigUint() throws {
        let bigUint: BigUint = 1
        let integer = 2
        
        let result = integer - bigUint
        
        XCTAssertEqual(result, 1)
    }
    
    func testRemoveBigUintAndNegativeLiteralInt() throws {
        do {
            try BigUintTestsContract.testable("contract").testRemoveBigUintAndNegativeLiteralShouldFail()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Cannot convert negative Int64 to BigUint."))
        }
    }
    
    func testRemoveNegativeLiteralIntAndBigUint() throws {
        do {
            try BigUintTestsContract.testable("contract").testRemoveNegativeLiteralAndBigUintShouldFail()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Cannot convert negative Int64 to BigUint."))
        }
    }
    
    func testAddAssignBigUint() throws {
        var result: BigUint = 1
        let bigUint: BigUint = 2
        
        result += bigUint
        
        XCTAssertEqual(result, 3)
    }
    
    func testAddAssignBigUintLiteral() throws {
        var result: BigUint = 1
        
        result += 2
        
        XCTAssertEqual(result, 3)
    }
    
    func testAddAssignBigUintAndUInt8() throws {
        var result: BigUint = 1
        let addend: UInt8 = 2

        result += addend

        XCTAssertEqual(result, 3)
    }

    func testAddAssignBigUintAndUInt16() throws {
        var result: BigUint = 1
        let addend: UInt16 = 2

        result += addend

        XCTAssertEqual(result, 3)
    }

    func testAddAssignBigUintAndUInt32() throws {
        var result: BigUint = 1
        let addend: UInt32 = 2

        result += addend

        XCTAssertEqual(result, 3)
    }

    func testAddAssignBigUintAndUInt64() throws {
        var result: BigUint = 1
        let addend: UInt64 = 2

        result += addend

        XCTAssertEqual(result, 3)
    }

    func testAddAssignBigUintAndLiteralInteger() throws {
        var result: BigUint = 1
        let addend = 2

        result += addend

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
        do {
            try BigUintTestsContract.testable("contract").testSubstractTwoBigUintNegativeShouldFail()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "cannot subtract because result would be negative"))
        }
    }
    
    func testSubstractAssignBigUint() throws {
        var result: BigUint = 5
        let bigUint: BigUint = 2
        
        result -= bigUint
        
        XCTAssertEqual(result, 3)
    }
    
    func testSubstractAssignBigUintLiteral() throws {
        var result: BigUint = 5
        
        result -= 2
        
        XCTAssertEqual(result, 3)
    }
    
    func testSubtractAssignBigUintAndUInt8() throws {
        var result: BigUint = 5
        let subtrahend: UInt8 = 2

        result -= subtrahend

        XCTAssertEqual(result, 3)
    }

    func testSubtractAssignBigUintAndUInt16() throws {
        var result: BigUint = 5
        let subtrahend: UInt16 = 2

        result -= subtrahend

        XCTAssertEqual(result, 3)
    }

    func testSubtractAssignBigUintAndUInt32() throws {
        var result: BigUint = 5
        let subtrahend: UInt32 = 2

        result -= subtrahend

        XCTAssertEqual(result, 3)
    }

    func testSubtractAssignBigUintAndUInt64() throws {
        var result: BigUint = 5
        let subtrahend: UInt64 = 2

        result -= subtrahend

        XCTAssertEqual(result, 3)
    }

    func testSubtractAssignBigUintAndLiteralInteger() throws {
        var result: BigUint = 5
        let subtrahend = 2

        result -= subtrahend

        XCTAssertEqual(result, 3)
    }
    
    func testMultiplyTwoBigUint() throws {
        let bigUint1: BigUint = 2
        let bigUint2: BigUint = 3
        
        let result = bigUint1 * bigUint2
        
        XCTAssertEqual(result, 6)
    }
    
    func testMultiplyBigUintAndUInt8() throws {
        let bigUint: BigUint = 2
        let integer: UInt8 = 3
        
        let result = bigUint * integer
        
        XCTAssertEqual(result, 6)
    }
    
    func testMultiplyUInt8AndBigUint() throws {
        let bigUint: BigUint = 2
        let integer: UInt8 = 3
        
        let result = integer * bigUint
        
        XCTAssertEqual(result, 6)
    }
    
    func testMultiplyBigUintAndUInt16() throws {
        let bigUint: BigUint = 2
        let integer: UInt16 = 3
        
        let result = bigUint * integer
        
        XCTAssertEqual(result, 6)
    }
    
    func testMultiplyUInt16AndBigUint() throws {
        let bigUint: BigUint = 2
        let integer: UInt16 = 3
        
        let result = integer * bigUint
        
        XCTAssertEqual(result, 6)
    }
    
    func testMultiplyBigUintAndUInt32() throws {
        let bigUint: BigUint = 2
        let integer: UInt32 = 3
        
        let result = bigUint * integer
        
        XCTAssertEqual(result, 6)
    }
    
    func testMultiplyUInt32AndBigUint() throws {
        let bigUint: BigUint = 2
        let integer: UInt32 = 3
        
        let result = integer * bigUint
        
        XCTAssertEqual(result, 6)
    }
    
    func testMultiplyBigUintAndUInt64() throws {
        let bigUint: BigUint = 2
        let integer: UInt64 = 3
        
        let result = bigUint * integer
        
        XCTAssertEqual(result, 6)
    }
    
    func testMultiplyUInt64AndBigUint() throws {
        let bigUint: BigUint = 2
        let integer: UInt64 = 3
        
        let result = integer * bigUint
        
        XCTAssertEqual(result, 6)
    }
    
    func testMultiplyBigUintAndLiteralInteger() throws {
        let bigUint: BigUint = 2
        let integer = 3
        
        let result = bigUint * integer
        
        XCTAssertEqual(result, 6)
    }
    
    func testMultiplyLiteralIntegerAndBigUint() throws {
        let bigUint: BigUint = 2
        let integer = 3
        
        let result = integer * bigUint
        
        XCTAssertEqual(result, 6)
    }
    
    func testMultiplyAssignBigUint() throws {
        var result: BigUint = 2
        let bigUint: BigUint = 3
        
        result *= bigUint
        
        XCTAssertEqual(result, 6)
    }
    
    func testMultiplyAssignBigUintLiteral() throws {
        var result: BigUint = 2
        
        result *= 3
        
        XCTAssertEqual(result, 6)
    }
    
    func testMultiplyAssignBigUintAndUInt8() throws {
        var result: BigUint = 3
        let multiplier: UInt8 = 2

        result *= multiplier

        XCTAssertEqual(result, 6)
    }

    func testMultiplyAssignBigUintAndUInt16() throws {
        var result: BigUint = 3
        let multiplier: UInt16 = 2

        result *= multiplier

        XCTAssertEqual(result, 6)
    }

    func testMultiplyAssignBigUintAndUInt32() throws {
        var result: BigUint = 3
        let multiplier: UInt32 = 2

        result *= multiplier

        XCTAssertEqual(result, 6)
    }

    func testMultiplyAssignBigUintAndUInt64() throws {
        var result: BigUint = 3
        let multiplier: UInt64 = 2

        result *= multiplier

        XCTAssertEqual(result, 6)
    }

    func testMultiplyAssignBigUintAndLiteralInteger() throws {
        var result: BigUint = 3
        let multiplier = 2

        result *= multiplier

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
        do {
            try BigUintTestsContract.testable("contract").testDivideTwoBigUintZeroRightSideShouldFail()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Cannot divide by zero."))
        }
    }
    
    func testDivideAssignTwoBigUint() throws {
        var result: BigUint = 6
        let divisor: BigUint = 2

        result /= divisor

        XCTAssertEqual(result, 3)
    }
    
    func testDivideAssignBigUintAndUInt8() throws {
        var result: BigUint = 6
        let divisor: UInt8 = 2

        result /= divisor

        XCTAssertEqual(result, 3)
    }

    func testDivideAssignBigUintAndUInt16() throws {
        var result: BigUint = 6
        let divisor: UInt16 = 2

        result /= divisor

        XCTAssertEqual(result, 3)
    }

    func testDivideAssignBigUintAndUInt32() throws {
        var result: BigUint = 6
        let divisor: UInt32 = 2

        result /= divisor

        XCTAssertEqual(result, 3)
    }

    func testDivideAssignBigUintAndUInt64() throws {
        var result: BigUint = 6
        let divisor: UInt64 = 2

        result /= divisor

        XCTAssertEqual(result, 3)
    }

    func testDivideAssignBigUintAndLiteralInteger() throws {
        var result: BigUint = 6
        let divisor = 2

        result /= divisor

        XCTAssertEqual(result, 3)
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
    
    func testModuloBigUintAndUInt8() throws {
        let bigUint: BigUint = 10
        let integer: UInt8 = 3
        
        let result = bigUint % integer
        
        XCTAssertEqual(result, 1)
    }
    
    func testModuloUInt8AndBigUint() throws {
        let bigUint: BigUint = 3
        let integer: UInt8 = 10
        
        let result = integer % bigUint
        
        XCTAssertEqual(result, 1)
    }
    
    func testModuloBigUintAndUInt16() throws {
        let bigUint: BigUint = 10
        let integer: UInt16 = 3
        
        let result = bigUint % integer
        
        XCTAssertEqual(result, 1)
    }
    
    func testModuloUInt16AndBigUint() throws {
        let bigUint: BigUint = 3
        let integer: UInt16 = 10
        
        let result = integer % bigUint
        
        XCTAssertEqual(result, 1)
    }
    
    func testModuloBigUintAndUInt32() throws {
        let bigUint: BigUint = 10
        let integer: UInt32 = 3
        
        let result = bigUint % integer
        
        XCTAssertEqual(result, 1)
    }
    
    func testModuloUInt32AndBigUint() throws {
        let bigUint: BigUint = 3
        let integer: UInt32 = 10
        
        let result = integer % bigUint
        
        XCTAssertEqual(result, 1)
    }
    
    func testModuloBigUintAndUInt64() throws {
        let bigUint: BigUint = 10
        let integer: UInt64 = 3
        
        let result = bigUint % integer
        
        XCTAssertEqual(result, 1)
    }
    
    func testModuloUInt64AndBigUint() throws {
        let bigUint: BigUint = 3
        let integer: UInt64 = 10
        
        let result = integer % bigUint
        
        XCTAssertEqual(result, 1)
    }
    
    func testModuloBigUintAndLiteralInteger() throws {
        let bigUint: BigUint = 10
        let integer = 3
        
        let result = bigUint % integer
        
        XCTAssertEqual(result, 1)
    }
    
    func testModuloLiteralIntegerAndBigUint() throws {
        let bigUint: BigUint = 3
        let integer = 10
        
        let result = integer % bigUint
        
        XCTAssertEqual(result, 1)
    }
    
    func testModuloTwoBigUintZeroRightSideShouldFail() throws {
        do {
            try BigUintTestsContract.testable("contract").testModuloTwoBigUintZeroRightSideShouldFail()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Cannot divide by zero (modulo)."))
        }
    }
    
    func testModuloAssignTwoBigUints() throws {
        var result: BigUint = 5
        let divisor: BigUint = 2

        result %= divisor

        XCTAssertEqual(result, 1)
    }
    
    func testModuloAssignBigUintAndUInt8() throws {
        var result: BigUint = 5
        let divisor: UInt8 = 2

        result %= divisor

        XCTAssertEqual(result, 1)
    }

    func testModuloAssignBigUintAndUInt16() throws {
        var result: BigUint = 5
        let divisor: UInt16 = 2

        result %= divisor

        XCTAssertEqual(result, 1)
    }

    func testModuloAssignBigUintAndUInt32() throws {
        var result: BigUint = 5
        let divisor: UInt32 = 2

        result %= divisor

        XCTAssertEqual(result, 1)
    }

    func testModuloAssignBigUintAndUInt64() throws {
        var result: BigUint = 5
        let divisor: UInt64 = 2

        result %= divisor

        XCTAssertEqual(result, 1)
    }

    func testModuloAssignBigUintAndLiteralInteger() throws {
        var result: BigUint = 5
        let divisor = 2

        result %= divisor

        XCTAssertEqual(result, 1)
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
    
    func testCompareGreaterBigUintAndUInt8() throws {
        let bigUint: BigUint = 5
        let integer: UInt8 = 2
        let integer2: UInt8 = 6
        
        XCTAssert(bigUint > integer)
        XCTAssertFalse(bigUint > integer2)
    }
    
    func testCompareGreaterUInt8AndBigUint() throws {
        let bigUint: BigUint = 2
        let bigUint2: BigUint = 6
        let integer: UInt8 = 5
        
        XCTAssert(integer > bigUint)
        XCTAssertFalse(integer > bigUint2)
    }
    
    func testCompareGreaterBigUintAndUInt16() throws {
        let bigUint: BigUint = 5
        let integer: UInt16 = 2
        let integer2: UInt16 = 6
        
        XCTAssert(bigUint > integer)
        XCTAssertFalse(bigUint > integer2)
    }
    
    func testCompareGreaterUInt16AndBigUint() throws {
        let bigUint: BigUint = 2
        let bigUint2: BigUint = 6
        let integer: UInt16 = 5
        
        XCTAssert(integer > bigUint)
        XCTAssertFalse(integer > bigUint2)
    }
    
    func testCompareGreaterBigUintAndUInt32() throws {
        let bigUint: BigUint = 5
        let integer: UInt32 = 2
        let integer2: UInt32 = 6
        
        XCTAssert(bigUint > integer)
        XCTAssertFalse(bigUint > integer2)
    }
    
    func testCompareGreaterUInt32AndBigUint() throws {
        let bigUint: BigUint = 2
        let bigUint2: BigUint = 6
        let integer: UInt32 = 5
        
        XCTAssert(integer > bigUint)
        XCTAssertFalse(integer > bigUint2)
    }
    
    func testCompareGreaterBigUintAndUInt64() throws {
        let bigUint: BigUint = 5
        let integer: UInt64 = 2
        let integer2: UInt64 = 6
        
        XCTAssert(bigUint > integer)
        XCTAssertFalse(bigUint > integer2)
    }
    
    func testCompareGreaterUInt64AndBigUint() throws {
        let bigUint: BigUint = 2
        let bigUint2: BigUint = 6
        let integer: UInt64 = 5
        
        XCTAssert(integer > bigUint)
        XCTAssertFalse(integer > bigUint2)
    }
    
    func testCompareGreaterBigUintAndLiteralInteger() throws {
        let bigUint: BigUint = 5
        let integer = 2
        let integer2 = 6
        
        XCTAssert(bigUint > integer)
        XCTAssertFalse(bigUint > integer2)
    }
    
    func testCompareGreaterLiteralIntegerAndBigUint() throws {
        let bigUint: BigUint = 2
        let bigUint2: BigUint = 6
        let integer: UInt64 = 5
        
        XCTAssert(integer > bigUint)
        XCTAssertFalse(integer > bigUint2)
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
    
    func testCompareGreaterOrEqualBigUintAndUInt8() throws {
        let bigUint: BigUint = 5
        let integer: UInt8 = 5
        let integer2: UInt8 = 6
        let integer3: UInt8 = 4
        
        XCTAssert(bigUint >= integer3)
        XCTAssert(bigUint >= integer)
        XCTAssertFalse(bigUint >= integer2)
    }

    func testCompareGreaterOrEqualUInt8AndBigUint() throws {
        let bigUint: BigUint = 5
        let bigUint2: BigUint = 6
        let integer: UInt8 = 5
        let integer3: UInt8 = 4
        
        XCTAssert(integer >= integer3)
        XCTAssert(integer >= bigUint)
        XCTAssertFalse(integer >= bigUint2)
    }

    func testCompareGreaterOrEqualBigUintAndUInt16() throws {
        let bigUint: BigUint = 5
        let integer: UInt16 = 5
        let integer2: UInt16 = 6
        let integer3: UInt16 = 4
        
        XCTAssert(bigUint >= integer3)
        XCTAssert(bigUint >= integer)
        XCTAssertFalse(bigUint >= integer2)
    }

    func testCompareGreaterOrEqualUInt16AndBigUint() throws {
        let bigUint: BigUint = 5
        let bigUint2: BigUint = 6
        let integer: UInt16 = 5
        let integer3: UInt16 = 4
        
        XCTAssert(integer >= integer3)
        XCTAssert(integer >= bigUint)
        XCTAssertFalse(integer >= bigUint2)
    }

    func testCompareGreaterOrEqualBigUintAndUInt32() throws {
        let bigUint: BigUint = 5
        let integer: UInt32 = 5
        let integer2: UInt32 = 6
        let integer3: UInt32 = 4
        
        XCTAssert(bigUint >= integer3)
        XCTAssert(bigUint >= integer)
        XCTAssertFalse(bigUint >= integer2)
    }

    func testCompareGreaterOrEqualUInt32AndBigUint() throws {
        let bigUint: BigUint = 5
        let bigUint2: BigUint = 6
        let integer: UInt32 = 5
        let integer3: UInt32 = 4
        
        XCTAssert(integer >= integer3)
        XCTAssert(integer >= bigUint)
        XCTAssertFalse(integer >= bigUint2)
    }

    func testCompareGreaterOrEqualBigUintAndUInt64() throws {
        let bigUint: BigUint = 5
        let integer: UInt64 = 5
        let integer2: UInt64 = 6
        let integer3: UInt64 = 4
        
        XCTAssert(bigUint >= integer3)
        XCTAssert(bigUint >= integer)
        XCTAssertFalse(bigUint >= integer2)
    }

    func testCompareGreaterOrEqualUInt64AndBigUint() throws {
        let bigUint: BigUint = 5
        let bigUint2: BigUint = 6
        let integer: UInt64 = 5
        let integer3: UInt64 = 4
        
        XCTAssert(integer >= integer3)
        XCTAssert(integer >= bigUint)
        XCTAssertFalse(integer >= bigUint2)
    }

    func testCompareGreaterOrEqualBigUintAndLiteralInteger() throws {
        let bigUint: BigUint = 5
        let integer = 5
        let integer2 = 6
        let integer3 = 4
        
        XCTAssert(bigUint >= integer3)
        XCTAssert(bigUint >= integer)
        XCTAssertFalse(bigUint >= integer2)
    }

    func testCompareGreaterOrEqualLiteralIntegerAndBigUint() throws {
        let bigUint: BigUint = 5
        let bigUint2: BigUint = 6
        let integer = 5
        let integer3 = 4
        
        XCTAssert(integer >= integer3)
        XCTAssert(integer >= bigUint)
        XCTAssertFalse(integer >= bigUint2)
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
    
    func testCompareLessThanBigUintAndUInt8() throws {
        let bigUint: BigUint = 5
        let integer: UInt8 = 5

        XCTAssertFalse(bigUint < integer)
    }

    func testCompareLessThanUInt8AndBigUint() throws {
        let bigUint: BigUint = 5
        let integer3: UInt8 = 4
        let integer: UInt8 = 5
        let integer2: UInt8 = 6

        XCTAssert(integer3 < bigUint)
        XCTAssertFalse(integer < bigUint)
        XCTAssertFalse(integer2 < bigUint)
    }

    func testCompareLessThanBigUintAndUInt16() throws {
        let bigUint: BigUint = 5
        let integer: UInt16 = 5

        XCTAssertFalse(bigUint < integer)
    }

    func testCompareLessThanUInt16AndBigUint() throws {
        let bigUint: BigUint = 5
        let integer3: UInt16 = 4
        let integer: UInt16 = 5
        let integer2: UInt16 = 6

        XCTAssert(integer3 < bigUint)
        XCTAssertFalse(integer < bigUint)
        XCTAssertFalse(integer2 < bigUint)
    }

    func testCompareLessThanBigUintAndUInt32() throws {
        let bigUint: BigUint = 5
        let integer: UInt32 = 5

        XCTAssertFalse(bigUint < integer)
    }

    func testCompareLessThanUInt32AndBigUint() throws {
        let bigUint: BigUint = 5
        let integer3: UInt32 = 4
        let integer: UInt32 = 5
        let integer2: UInt32 = 6

        XCTAssert(integer3 < bigUint)
        XCTAssertFalse(integer < bigUint)
        XCTAssertFalse(integer2 < bigUint)
    }

    func testCompareLessThanBigUintAndUInt64() throws {
        let bigUint: BigUint = 5
        let integer: UInt64 = 5

        XCTAssertFalse(bigUint < integer)
    }

    func testCompareLessThanUInt64AndBigUint() throws {
        let bigUint: BigUint = 5
        let integer3: UInt64 = 4
        let integer: UInt64 = 5
        let integer2: UInt64 = 6

        XCTAssert(integer3 < bigUint)
        XCTAssertFalse(integer < bigUint)
        XCTAssertFalse(integer2 < bigUint)
    }

    func testCompareLessThanBigUintAndLiteralInteger() throws {
        let bigUint: BigUint = 5
        let integer = 5

        XCTAssertFalse(bigUint < integer)
    }

    func testCompareLessThanLiteralIntegerAndBigUint() throws {
        let bigUint: BigUint = 5
        let integer3 = 4
        let integer = 5
        let integer2 = 6

        XCTAssert(integer3 < bigUint)
        XCTAssertFalse(integer < bigUint)
        XCTAssertFalse(integer2 < bigUint)
    }
    
    func testCompareLessOrEqualBigUintAndUInt8() throws {
        let bigUint: BigUint = 5
        let integer: UInt8 = 5

        XCTAssert(bigUint <= integer)
    }

    func testCompareLessOrEqualUInt8AndBigUint() throws {
        let bigUint: BigUint = 5
        let integer2: UInt8 = 4
        let integer: UInt8 = 5
        let integer3: UInt8 = 6

        XCTAssert(integer2 <= bigUint)
        XCTAssert(integer <= bigUint)
        XCTAssertFalse(integer3 <= bigUint)
    }

    func testCompareLessOrEqualBigUintAndUInt16() throws {
        let bigUint: BigUint = 5
        let integer: UInt16 = 5

        XCTAssert(bigUint <= integer)
    }

    func testCompareLessOrEqualUInt16AndBigUint() throws {
        let bigUint: BigUint = 5
        let integer2: UInt16 = 4
        let integer: UInt16 = 5
        let integer3: UInt16 = 6

        XCTAssert(integer2 <= bigUint)
        XCTAssert(integer <= bigUint)
        XCTAssertFalse(integer3 <= bigUint)
    }

    func testCompareLessOrEqualBigUintAndUInt32() throws {
        let bigUint: BigUint = 5
        let integer: UInt32 = 5

        XCTAssert(bigUint <= integer)
    }

    func testCompareLessOrEqualUInt32AndBigUint() throws {
        let bigUint: BigUint = 5
        let integer2: UInt32 = 4
        let integer: UInt32 = 5
        let integer3: UInt32 = 6

        XCTAssert(integer2 <= bigUint)
        XCTAssert(integer <= bigUint)
        XCTAssertFalse(integer3 <= bigUint)
    }

    func testCompareLessOrEqualBigUintAndUInt64() throws {
        let bigUint: BigUint = 5
        let integer: UInt64 = 5

        XCTAssert(bigUint <= integer)
    }

    func testCompareLessOrEqualUInt64AndBigUint() throws {
        let bigUint: BigUint = 5
        let integer2: UInt64 = 4
        let integer: UInt64 = 5
        let integer3: UInt64 = 6

        XCTAssert(integer2 <= bigUint)
        XCTAssert(integer <= bigUint)
        XCTAssertFalse(integer3 <= bigUint)
    }

    func testCompareLessOrEqualBigUintAndLiteralInteger() throws {
        let bigUint: BigUint = 5
        let integer = 5

        XCTAssert(bigUint <= integer)
    }

    func testCompareLessOrEqualLiteralIntegerAndBigUint() throws {
        let bigUint: BigUint = 5
        let integer2 = 4
        let integer = 5
        let integer3 = 6

        XCTAssert(integer2 <= bigUint)
        XCTAssert(integer <= bigUint)
        XCTAssertFalse(integer3 <= bigUint)
    }

    
    func testZeroBigUintTopEncode() throws {
        let bigUint: BigUint = 0
        var output = Buffer()
        
        bigUint.topEncode(output: &output)
        
        XCTAssertEqual(output.hexDescription, "")
    }
    
    func testNonZeroBigUintTopEncode() throws {
        let bigUint: BigUint = 10
        var output = Buffer()
        
        bigUint.topEncode(output: &output)
        
        XCTAssertEqual(output.hexDescription, "0a")
    }
    
    func testZeroBigUintNestedEncode() throws {
        let bigUint: BigUint = 0
        var output = Buffer()
        
        bigUint.depEncode(dest: &output)
        
        XCTAssertEqual(output.hexDescription, "00000000")
    }
    
    func testNonZeroBigUintNestedEncode() throws {
        let bigUint: BigUint = 1000
        var output = Buffer()
        
        bigUint.depEncode(dest: &output)
        
        XCTAssertEqual(output.hexDescription, "0000000203e8")
    }
    
    func testZeroBigUintTopDecodeFromEmptyInput() throws {
        let input: Buffer = ""
        let bigUint = BigUint(topDecode: input)
        
        XCTAssertEqual(bigUint, 0)
    }
    
    func testZeroBigUintTopDecodeFromNonEmptyInput() throws {
        let input = Buffer(data: Array("00".hexadecimal))
        let bigUint = BigUint(topDecode: input)
        
        XCTAssertEqual(bigUint, 0)
    }
    
    func testNonZeroBigUintTopDecode() throws {
        let input = Buffer(data: Array("0a".hexadecimal))
        let bigUint = BigUint(topDecode: input)
        
        XCTAssertEqual(bigUint, 10)
    }
    
    func testZeroBigUintNestedDecodeFromNonEmptyInput() throws {
        var input = BufferNestedDecodeInput(buffer: Buffer(data: Array("00000000".hexadecimal)))
        let bigUint = BigUint(depDecode: &input)
        
        let expected: BigUint = 0
        
        XCTAssertEqual(bigUint, expected)
    }
    
    func testOneBigUintNestedDecodeFromNonEmptyInput() throws {
        var input = BufferNestedDecodeInput(buffer: Buffer(data: Array("0000000101".hexadecimal)))
        let bigUint = BigUint(depDecode: &input)
        
        let expected: BigUint = 1
        
        XCTAssertEqual(bigUint, expected)
    }
    
    func testTenBigUintNestedDecodeFromNonEmptyInput() throws {
        var input = BufferNestedDecodeInput(buffer: Buffer(data: Array("000000010a".hexadecimal)))
        let bigUint = BigUint(depDecode: &input)
        
        let expected: BigUint = 10
        
        XCTAssertEqual(bigUint, expected)
    }
    
    func testThousandBigUintNestedDecodeFromNonEmptyInput() throws {
        var input = BufferNestedDecodeInput(buffer: Buffer(data: Array("0000000203e8".hexadecimal)))
        let bigUint = BigUint(depDecode: &input)
        
        let expected: BigUint = 1000
        
        XCTAssertEqual(bigUint, expected)
    }
    
    func testZeroBigUintToInt64() throws {
        let value: BigUint = 0
        let result = value.toInt64()
        
        let expected: Int64 = 0
        
        XCTAssertEqual(result, expected)
    }
    
    func testNonZeroBigUintToInt64() throws {
        let value: BigUint = 1
        let result = value.toInt64()
        
        let expected: Int64 = 1
        
        XCTAssertEqual(result, expected)
    }
    
    func testMaxInt32BigUintToInt64() throws {
        let value = BigUint(value: Int64(Int32.max))
        let result = value.toInt64()
        
        let expected = Int64(Int32.max)
        
        XCTAssertEqual(result, expected)
    }
    
    func testMaxInt64BigUintToInt64() throws {
        let value = BigUint(value: Int64.max)
        let result = value.toInt64()
        
        let expected = Int64.max
        
        XCTAssertEqual(result, expected)
    }
    
    func testMoreThanInt64BigUintToInt64() throws {
        let value = BigUint(value: Int64.max) + 1
        let result = value.toInt64()
        
        XCTAssertEqual(result, nil)
    }
    
    func testZeroUInt8ToBigUint() throws {
        let result = BigUint(value: UInt8(0))
        
        let expected: BigUint = 0
        
        XCTAssertEqual(result, expected)
    }
    
    func testOneUInt8ToBigUint() throws {
        let result = BigUint(value: UInt8(1))
        
        let expected: BigUint = 1
        
        XCTAssertEqual(result, expected)
    }
    
    func testMaxUInt8ToBigUint() throws {
        let result = BigUint(value: UInt8.max)
        
        let expected: BigUint = 255
        
        XCTAssertEqual(result, expected)
    }
    
    func testZeroUInt16ToBigUint() throws {
        let result = BigUint(value: UInt16(0))
        
        let expected: BigUint = 0
        
        XCTAssertEqual(result, expected)
    }
    
    func testOneUInt16ToBigUint() throws {
        let result = BigUint(value: UInt16(1))
        
        let expected: BigUint = 1
        
        XCTAssertEqual(result, expected)
    }
    
    func testMaxUInt16ToBigUint() throws {
        let result = BigUint(value: UInt16.max)
        
        let expected: BigUint = 65535
        
        XCTAssertEqual(result, expected)
    }
    
    func testZeroInt32ToBigUint() throws {
        let result = BigUint(value: Int32(0))
        
        let expected: BigUint = 0
        
        XCTAssertEqual(result, expected)
    }
    
    func testOneInt32ToBigUint() throws {
        let result = BigUint(value: Int32(1))
        
        let expected: BigUint = 1
        
        XCTAssertEqual(result, expected)
    }
    
    func testInt32MidToBigUint() throws {
        var result = Buffer()
        BigUint(value: Int32.max / 2).topEncode(output: &result)
        
        let expected = Buffer(data: Array("3fffffff".hexadecimal))
        
        XCTAssertEqual(result, expected)
    }
    
    func testInt32MidPlusOneToBigUint() throws {
        var result = Buffer()
        BigUint(value: (Int32.max / 2) + 1).topEncode(output: &result)
        
        let expected = Buffer(data: Array("40000000".hexadecimal))
        
        XCTAssertEqual(result, expected)
    }
    
    func testMaxInt32ToBigUint() throws {
        var result = Buffer()
        BigUint(value: Int32.max).topEncode(output: &result)
        
        let expected = Buffer(data: Array("7fffffff".hexadecimal))
        
        XCTAssertEqual(result, expected)
    }
    
    func testZeroUInt32ToBigUint() throws {
        let result = BigUint(value: UInt32(0))
        
        let expected: BigUint = 0
        
        XCTAssertEqual(result, expected)
    }
    
    func testOneUInt32ToBigUint() throws {
        let result = BigUint(value: UInt32(1))
        
        let expected: BigUint = 1
        
        XCTAssertEqual(result, expected)
    }
    
    func testMaxUInt32ToBigUint() throws {
        let result = BigUint(value: UInt32.max)
        
        let expected: BigUint = 4294967295
        
        XCTAssertEqual(result, expected)
    }
    
    func testZeroInt64ToBigUint() throws {
        let result = BigUint(value: Int64(0))
        
        let expected: BigUint = 0
        
        XCTAssertEqual(result, expected)
    }
    
    func testOneInt64ToBigUint() throws {
        let result = BigUint(value: Int64(1))
        
        let expected: BigUint = 1
        
        XCTAssertEqual(result, expected)
    }
    
    func testInt64MidToBigUint() throws {
        var result = Buffer()
        BigUint(value: Int64.max / 2).topEncode(output: &result)
        
        let expected = Buffer(data: Array("3fffffffffffffff".hexadecimal))
        
        XCTAssertEqual(result, expected)
    }
    
    func testInt64MidPlusOneToBigUint() throws {
        var result = Buffer()
        BigUint(value: (Int64.max / 2) + 1).topEncode(output: &result)
        
        let expected = Buffer(data: Array("4000000000000000".hexadecimal))
        
        XCTAssertEqual(result, expected)
    }
    
    func testMaxInt64ToBigUint() throws {
        var result = Buffer()
        BigUint(value: Int64.max).topEncode(output: &result)
        
        let expected = Buffer(data: Array("7fffffffffffffff".hexadecimal))
        
        XCTAssertEqual(result, expected)
    }
    
    func testZeroUInt64ToBigUint() throws {
        let result = BigUint(value: UInt64(0))
        
        let expected: BigUint = 0
        
        XCTAssertEqual(result, expected)
    }
    
    func testOneUInt64ToBigUint() throws {
        let result = BigUint(value: UInt64(1))
        
        let expected: BigUint = 1
        
        XCTAssertEqual(result, expected)
    }
    
    func testUInt64MidToBigUint() throws {
        var result = Buffer()
        BigUint(value: UInt64.max / 2).topEncode(output: &result)
        
        let expected = Buffer(data: Array("7fffffffffffffff".hexadecimal))
        
        XCTAssertEqual(result, expected)
    }
    
    func testUInt64MidPlusOneToBigUint() throws {
        var result = Buffer()
        BigUint(value: (UInt64.max / 2) + 1).topEncode(output: &result)
        
        let expected = Buffer(data: Array("8000000000000000".hexadecimal))
        
        XCTAssertEqual(result, expected)
    }
    
    func testMaxUInt64ToBigUint() throws {
        var result = Buffer()
        BigUint(value: UInt64.max).topEncode(output: &result)
        
        let expected = Buffer(data: Array("ffffffffffffffff".hexadecimal))
        
        XCTAssertEqual(result, expected)
    }
}

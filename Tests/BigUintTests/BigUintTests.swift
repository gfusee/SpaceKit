import XCTest
import SpaceKit

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
    
    func testAddTwoBigUint() throws {
        let bigUint1: BigUint = 1
        let bigUint2: BigUint = 2
        
        let result = bigUint1 + bigUint2
        
        XCTAssertEqual(result, 3)
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
            try self.deployContract(BigUintTestsContract.self, at: "contract").testSubstractTwoBigUintNegativeShouldFail()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "cannot subtract because result would be negative"))
        }
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
        do {
            try self.deployContract(BigUintTestsContract.self, at: "contract").testDivideTwoBigUintZeroRightSideShouldFail()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Cannot divide by zero."))
        }
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
        do {
            try self.deployContract(BigUintTestsContract.self, at: "contract").testModuloTwoBigUintZeroRightSideShouldFail()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Cannot divide by zero (modulo)."))
        }
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

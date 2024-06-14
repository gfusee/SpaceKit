import XCTest
import MultiversX

@Contract
struct Factorial {
    public func factorial(value: BigUint) -> BigUint {
        let one: BigUint = 1
        
        if value == 0 {
            return one
        }
        
        var result: BigUint = 1
        var x: BigUint = 1
        
        while x <= value {
            result = result * x
            x = x + 1
        }
        
        return result
    }
}

final class FactorialTests: ContractTestCase {
    
    func testZero() throws {
        let contract = try Factorial.testable("factorial")
        
        let result = try contract.factorial(value: 0)
        
        XCTAssertEqual(result, 1)
    }
    
    func testOne() throws {
        let contract = try Factorial.testable("factorial")
        
        let result = try contract.factorial(value: 1)
        
        XCTAssertEqual(result, 1)
    }
    
    func testTen() throws {
        let contract = try Factorial.testable("factorial")
        
        let result = try contract.factorial(value: 10)
        
        XCTAssertEqual(result, 3628800)
    }
    
}

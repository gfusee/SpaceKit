import XCTest
import MultiversX

@Contract struct ErrorTestsContract {
    public func testUserErrorStopsTheExecution() {
        let bigUint1: BigUint = 1
        let bigUint2: BigUint = 2
        
        let _ = bigUint1 - bigUint2
        fatalError("This line should not be executed because the above line throws an user error.")
    }
}

final class ErrorTests: ContractTestCase {
    
    func testUserErrorStopsTheExecution() throws {
        do {
            try ErrorTestsContract.testable("").testUserErrorStopsTheExecution()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Cannot substract because the result would be negative."))
        }
    }
    
}

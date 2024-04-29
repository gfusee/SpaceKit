import XCTest
import MultiversX

final class ErrorTests: XCTestCase {
    
    func testUserErrorStopsTheExecution() throws {
        do {
            try runFailableTransactions {
                let bigUint1: BigUint = 1
                let bigUint2: BigUint = 2
                
                let _ = bigUint1 - bigUint2
                fatalError("This line should not be executed because the above line throws an user error.")
            }
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "Cannot substract because the result would be negative."))
        }
    }
    
}

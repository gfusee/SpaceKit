import XCTest
import SpaceKit

@Controller struct ErrorTestsController {
    public func testUserErrorStopsTheExecution() {
        let bigUint1: BigUint = 1
        let bigUint2: BigUint = 2
        
        let _ = bigUint1 - bigUint2
        fatalError("This line should not be executed because the above line throws an user error.")
    }
}

final class ErrorTests: ContractTestCase {

    override var initialAccounts: [WorldAccount] {
        [
            WorldAccount(
                address: "contract",
                controllers: [
                    ErrorTestsController.self
                ]
            )
        ]
    }
    
    func testUserErrorStopsTheExecution() throws {
        do {
            try self.deployContract(at: "contract")
            let controller = self.instantiateController(ErrorTestsController.self, for: "contract")!
            
            try controller.testUserErrorStopsTheExecution()
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .userError(message: "cannot subtract because result would be negative"))
        }
    }
    
}

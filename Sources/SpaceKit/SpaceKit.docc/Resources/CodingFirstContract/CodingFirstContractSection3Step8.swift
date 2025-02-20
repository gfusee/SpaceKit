import SpaceKit
import Counter
import SpaceKitTesting

let COUNTER_ADDRESS = "counter"

final class CounterTests: ContractTestCase {
    override var initialAccounts: [WorldAccount] {
        [
            WorldAccount(
                address: COUNTER_ADDRESS,
                controllers: [
                    CounterController.self
                ]
            )
        ]
    }
    
    func testDeployCounterInitialValueZero() throws {
        try self.deployContract(
            at: COUNTER_ADDRESS,
            arguments: [
                0 // Initial value
            ]
        )
        
        let controller = self.instantiateController(
            CounterController.self,
            for: COUNTER_ADDRESS
        )!
    }
}

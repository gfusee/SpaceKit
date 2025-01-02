import SpaceKit
import SpaceKitTesting

@Controller public struct CounterController {
    @Storage(key: "globalCounter") var globalCounter: BigUint
    
    public mutating func increaseByOne() {
        self.globalCounter += 1
    }
    
    public mutating func increaseByOneThrowError() {
        self.globalCounter += 1
        
        smartContractError(message: "This is an user error.")
    }
    
    public func getGlobalCounterValue() -> Buffer {
        "The global counter is: \(self.globalCounter)"
    }
}

final class ContractStorageTests: ContractTestCase {

    override var initialAccounts: [WorldAccount] {
        [
            WorldAccount(
                address: "counter",
                controllers: [
                    CounterController.self
                ]
            ),
            WorldAccount(
                address: "counter1",
                controllers: [
                    CounterController.self
                ]
            ),
            WorldAccount(
                address: "counter2",
                controllers: [
                    CounterController.self
                ]
            )
        ]
    }
    
    func testGetCounterBeforeAnyIncrease() throws {
        try self.deployContract(at: "counter")
        let controller = self.instantiateController(CounterController.self, for: "counter")!
        
        let globalCounterValue = try controller.getGlobalCounterValue()
        
        XCTAssertEqual(globalCounterValue, "The global counter is: 0")
    }
    
    func testIncreaseCounterOnce() throws {
        try self.deployContract(at: "counter")
        var controller = self.instantiateController(CounterController.self, for: "counter")!
        
        try controller.increaseByOne()
        
        let globalCounterValue = try controller.getGlobalCounterValue()
        
        XCTAssertEqual(globalCounterValue, "The global counter is: 1")
    }
    
    func testIncreaseCounterTwice() throws {
        try self.deployContract(at: "counter")
        var controller = self.instantiateController(CounterController.self, for: "counter")!
        
        try controller.increaseByOne()
        try controller.increaseByOne()
        
        let globalCounterValue = try controller.getGlobalCounterValue()
        
        XCTAssertEqual(globalCounterValue, "The global counter is: 2")
    }
    
    func testIncreaseCounterTwoContracts() throws {
        try self.deployContract(at: "counter1")
        var controller1 = self.instantiateController(CounterController.self, for: "counter1")!
        
        try controller1.increaseByOne()
        
        try self.deployContract(at: "counter2")
        var controller2 = self.instantiateController(CounterController.self, for: "counter2")!
        try controller2.increaseByOne()
        try controller2.increaseByOne()
        
        let controller1GlobalCounterValue = try controller1.getGlobalCounterValue()
        let controller2GlobalCounterValue = try controller2.getGlobalCounterValue()
        
        XCTAssertEqual(controller1GlobalCounterValue, "The global counter is: 1")
        XCTAssertEqual(controller2GlobalCounterValue, "The global counter is: 2")
    }
    
    func testIncreaseCounterErrorInTransactionShouldRevert() throws {
        try self.deployContract(at: "counter")
        var controller = self.instantiateController(CounterController.self, for: "counter")!
        
        try? controller.increaseByOneThrowError()
        
        let globalCounterValue = try controller.getGlobalCounterValue()
        
        XCTAssertEqual(globalCounterValue, "The global counter is: 0")
    }
    
}

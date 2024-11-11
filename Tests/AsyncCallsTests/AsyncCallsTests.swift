import XCTest
import Space

@Contract struct CalleeContract {
    @Storage(key: "counter") var counter: BigUint
    
    public mutating func increaseCounter() {
        self.counter += 1
    }
    
    public mutating func increaseCounterBy(value: BigUint) {
        self.counter += value
    }
    
    public func returnValueNoInput() -> Buffer {
        return "Hello World!"
    }
    
    public mutating func increaseCounterAndFail() {
        self.counter += 1
        
        smartContractError(message: "Oh no!")
    }
    
    public func getCounter() -> BigUint {
        self.counter
    }
}

@Proxy enum CalleeContractProxy {
    case increaseCounter
    case increaseCounterBy(value: BigUint)
    case increaseCounterAndFail
    case returnValueNoInput
}

@Contract struct AsyncCallsTestsContract {
    @Storage(key: "counter") var counter: BigUint
    
    public func asyncCallIncreaseCounter(receiver: Address) {
        CalleeContractProxy
            .increaseCounter
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000
            )
    }
    
    public func asyncCallIncreaseCounterBy(
        receiver: Address,
        value: BigUint
    ) {
        CalleeContractProxy
            .increaseCounterBy(value: value)
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000
            )
    }
    
    public mutating func asyncCallIncreaseCounterAndFail(receiver: Address) {
        self.counter += 100
        
        CalleeContractProxy
            .increaseCounterAndFail
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000
            )
        
        self.counter += 150
    }
    
    public func getCounter() -> BigUint {
        self.counter
    }
}

final class AsyncCallsTests: ContractTestCase {

    override var initialAccounts: [WorldAccount] {
        [
            WorldAccount(address: "callee"),
            WorldAccount(address: "caller")
        ]
    }
    
    func testIncreaseCounter() throws {
        let callee = try CalleeContract.testable("callee")
        let caller = try AsyncCallsTestsContract.testable("caller")
        
        try caller.asyncCallIncreaseCounter(receiver: "callee")
        
        let counter = try callee.getCounter()
        
        XCTAssertEqual(counter, 1)
    }
    
    func testIncreaseCounterBy() throws {
        let callee = try CalleeContract.testable("callee")
        let caller = try AsyncCallsTestsContract.testable("caller")
        
        try caller.asyncCallIncreaseCounterBy(
            receiver: "callee",
            value: 150
        )
        
        let counter = try callee.getCounter()
        
        XCTAssertEqual(counter, 150)
    }
    
    func testChangeStorageAndStartFailableAsyncCall() throws {
        let callee = try CalleeContract.testable("callee")
        var caller = try AsyncCallsTestsContract.testable("caller")
        
        try caller.asyncCallIncreaseCounterAndFail(
            receiver: "callee"
        )
        
        let calleeCounter = try callee.getCounter()
        let callerCounter = try caller.getCounter()
        
        XCTAssertEqual(calleeCounter, 0)
        XCTAssertEqual(callerCounter, 250)
    }
}

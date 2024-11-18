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
    
    public mutating func returnEgldValue() -> BigUint {
        let value = Message.egldValue
        self.counter += value
        
        return value
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
    case returnEgldValue
    case getCounter
}

@Contract struct AsyncCallsTestsContract {
    @Storage(key: "counter") var counter: BigUint
    @Storage(key: "storedErrorCode") var storedErrorCode: UInt32
    @Storage(key: "storedErrorMessage") var storedErrorMessage: Buffer
    
    public func asyncCallIncreaseCounter(receiver: Address) {
        CalleeContractProxy
            .increaseCounter
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000
            )
    }
    
    public func asyncCallIncreaseCounterWithSimpleCallback(receiver: Address) {
        CalleeContractProxy
            .increaseCounter
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                callback: self.$simpleCallback(gasForCallback: 5_000_000)
            )
    }
    
    public func asyncCallIncreaseCounterWithCallbackWithOneParameter(
        receiver: Address,
        callbackValue: BigUint
    ) {
        CalleeContractProxy
            .increaseCounter
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                callback: self.$callbackWithOneParameter(
                    value: callbackValue,
                    gasForCallback: 5_000_000
                )
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
    
    public mutating func asyncCallIncreaseCounterAndFailWithCallback(receiver: Address) {
        self.counter += 100
        
        CalleeContractProxy
            .increaseCounterAndFail
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                callback: self.$callbackWithResult(gasForCallback: 5_000_000)
            )
        
        self.counter += 150
    }
    
    public func asyncCallGetCounterWithCallback(receiver: Address) {
        CalleeContractProxy
            .getCounter
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                callback: self.$callbackWithResult(gasForCallback: 5_000_000)
            )
    }
    
    public func asyncCallReturnEgldValueNoCallback(
        receiver: Address,
        paymentValue: BigUint
    ) {
        CalleeContractProxy
            .returnEgldValue
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                egldValue: paymentValue
            )
    }
    
    public func asyncCallIncreaseCounterAndFailWithEgld(
        receiver: Address,
        paymentValue: BigUint
    ) {
        CalleeContractProxy
            .increaseCounterAndFail
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                egldValue: paymentValue,
                callback: self.$increaseCounterAndFailWithEgldCallback(gasForCallback: 15_000_000)
            )
    }
    
    public func getCounter() -> BigUint {
        self.counter
    }
    
    public func getStoredErrorCode() -> UInt32 {
        self.storedErrorCode
    }
    
    public func getStoredErrorMessage() -> Buffer {
        self.storedErrorMessage
    }
    
    @Callback public mutating func simpleCallback() {
        self.counter += 1
    }
    
    @Callback public mutating func callbackWithOneParameter(value: BigUint) {
        self.counter += value
    }
    
    @Callback public mutating func callbackWithResult() {
        let result: AsyncCallResult<BigUint> = Message.asyncCallResult()
        
        switch result {
        case .success(let value):
            self.counter += value
        case .error(let asyncCallError):
            self.storedErrorCode = asyncCallError.errorCode
            self.storedErrorMessage = asyncCallError.errorMessage
        }
    }
    
    @Callback public mutating func increaseCounterAndFailWithEgldCallback() {
        let result: AsyncCallResult<BigUint> = Message.asyncCallResult()
        
        switch result {
        case .success(_):
            break
        case .error(_):
            self.counter = Blockchain.getBalance(address: Blockchain.getSCAddress())
        }
    }
}

final class AsyncCallsTests: ContractTestCase {

    override var initialAccounts: [WorldAccount] {
        [
            WorldAccount(address: "callee"),
            WorldAccount(
                address: "caller",
                balance: 1000
            )
        ]
    }
    
    func testIncreaseCounter() throws {
        let callee = try CalleeContract.testable("callee")
        let caller = try AsyncCallsTestsContract.testable("caller")
        
        try caller.asyncCallIncreaseCounter(receiver: "callee")
        
        let counter = try callee.getCounter()
        
        XCTAssertEqual(counter, 1)
    }
    
    func testIncreaseCounterWithSimpleCallback() throws {
        let callee = try CalleeContract.testable("callee")
        let caller = try AsyncCallsTestsContract.testable("caller")
        
        try caller.asyncCallIncreaseCounterWithSimpleCallback(receiver: "callee")
        
        let calleeCounter = try callee.getCounter()
        let callerCounter = try caller.getCounter()
        
        XCTAssertEqual(calleeCounter, 1)
        XCTAssertEqual(callerCounter, 1)
    }
    
    func testIncreaseCounterWithCallbackWithOneParameter() throws {
        let callee = try CalleeContract.testable("callee")
        let caller = try AsyncCallsTestsContract.testable("caller")
        
        try caller.asyncCallIncreaseCounterWithCallbackWithOneParameter(
            receiver: "callee",
            callbackValue: 50
        )
        
        let calleeCounter = try callee.getCounter()
        let callerCounter = try caller.getCounter()
        
        XCTAssertEqual(calleeCounter, 1)
        XCTAssertEqual(callerCounter, 50)
    }
    
    func testIncreaseCounterWithCallbackWithResult() throws {
        var callee = try CalleeContract.testable("callee")
        let caller = try AsyncCallsTestsContract.testable("caller")
        
        try callee.increaseCounterBy(value: 100)
        
        try caller.asyncCallGetCounterWithCallback(receiver: "callee")
        
        let calleeCounter = try callee.getCounter()
        let callerCounter = try caller.getCounter()
        
        XCTAssertEqual(calleeCounter, 100)
        XCTAssertEqual(callerCounter, 100)
    }
    
    func testIncreaseCounterWithCallback() throws {
        let callee = try CalleeContract.testable("callee")
        let caller = try AsyncCallsTestsContract.testable("caller")
        
        try caller.asyncCallIncreaseCounterWithSimpleCallback(receiver: "callee")
        
        let calleeCounter = try callee.getCounter()
        let callerCounter = try caller.getCounter()
        
        XCTAssertEqual(calleeCounter, 1)
        XCTAssertEqual(callerCounter, 1)
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
    
    func testChangeStorageAndStartFailableAsyncCallWithCallback() throws {
        let callee = try CalleeContract.testable("callee")
        var caller = try AsyncCallsTestsContract.testable("caller")
        
        try caller.asyncCallIncreaseCounterAndFailWithCallback(
            receiver: "callee"
        )
        
        let calleeCounter = try callee.getCounter()
        let callerCounter = try caller.getCounter()
        
        let callerStoredErrorCode = try caller.getStoredErrorCode()
        let callerStoredErrorMessage = try caller.getStoredErrorMessage()
        
        XCTAssertEqual(calleeCounter, 0)
        XCTAssertEqual(callerCounter, 250)
        
        XCTAssertEqual(callerStoredErrorCode, 4)
        XCTAssertEqual(callerStoredErrorMessage, "Oh no!")
    }
    
    func testReturnEgldNoCallback() throws {
        let callee = try CalleeContract.testable("callee")
        let caller = try AsyncCallsTestsContract.testable("caller")
        
        try caller.asyncCallReturnEgldValueNoCallback(receiver: "callee", paymentValue: 150)
        
        let calleeCounter = try callee.getCounter()
        let calleeBalance = self.getAccount(address: "callee")?.balance
        let callerBalance = self.getAccount(address: "caller")?.balance
        
        XCTAssertEqual(calleeCounter, 150)
        XCTAssertEqual(calleeBalance, 150)
        XCTAssertEqual(callerBalance, 850)
    }
    
    func testIncreaseCounterAndFailWithEgldWithCallback() throws {
        let callee = try CalleeContract.testable("callee")
        let caller = try AsyncCallsTestsContract.testable("caller")
        
        try caller.asyncCallIncreaseCounterAndFailWithEgld(receiver: "callee", paymentValue: 150)
        
        let calleeCounter = try callee.getCounter()
        let callerCounter = try caller.getCounter()
        let calleeBalance = self.getAccount(address: "callee")?.balance
        let callerBalance = self.getAccount(address: "caller")?.balance
        
        XCTAssertEqual(calleeCounter, 0)
        XCTAssertEqual(callerCounter, 1000)
        XCTAssertEqual(calleeBalance, 0)
        XCTAssertEqual(callerBalance, 1000)
    }
}

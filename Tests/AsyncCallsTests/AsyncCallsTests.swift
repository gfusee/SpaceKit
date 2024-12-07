import XCTest
import SpaceKit

@Controller struct CalleeController {
    @Storage(key: "counter") var counter: BigUint
    @Storage(key: "address") var address: Address
    
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
    
    public mutating func storeCaller() {
        self.address = Message.caller
    }
    
    public mutating func returnEgldValue() -> BigUint {
        let value = Message.egldValue
        self.counter += value
        
        return value
    }
    
    public func getCounter() -> BigUint {
        self.counter
    }
    
    public func getAddress() ->  Address {
        self.address
    }
}

@Proxy enum CalleeControllerProxy {
    case increaseCounter
    case increaseCounterBy(value: BigUint)
    case increaseCounterAndFail
    case storeCaller
    case returnValueNoInput
    case returnEgldValue
    case getCounter
}

@Controller struct AsyncCallsTestsController {
    @Storage(key: "counter") var counter: BigUint
    @Storage(key: "address") var address: Address
    @Storage(key: "storedErrorCode") var storedErrorCode: UInt32
    @Storage(key: "storedErrorMessage") var storedErrorMessage: Buffer
    
    public func asyncCallIncreaseCounter(receiver: Address) {
        CalleeControllerProxy
            .increaseCounter
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000
            )
    }
    
    public func asyncCallIncreaseCounterWithSimpleCallback(receiver: Address) {
        CalleeControllerProxy
            .increaseCounter
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                callback: self.$simpleCallback(gasForCallback: 5_000_000)
            )
    }
    
    public func multiAsyncCallIncreaseCounterWithSimpleCallback(receiver: Address) {
        CalleeControllerProxy
            .increaseCounter
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                callback: self.$simpleCallback(gasForCallback: 5_000_000)
            )
        
        CalleeControllerProxy
            .increaseCounter
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                callback: self.$simpleCallback(gasForCallback: 5_000_000)
            )
        
        CalleeControllerProxy
            .increaseCounter
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                callback: self.$simpleCallback(gasForCallback: 5_000_000)
            )
    }
    
    public func multiAsyncCallIncreaseCounterWithSimpleCallbackOneNoCallback(receiver: Address) {
        CalleeControllerProxy
            .increaseCounter
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                callback: self.$simpleCallback(gasForCallback: 5_000_000)
            )
        
        CalleeControllerProxy
            .increaseCounter
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                callback: self.$simpleCallback(gasForCallback: 5_000_000)
            )
        
        CalleeControllerProxy
            .increaseCounter
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                callback: self.$simpleCallback(gasForCallback: 5_000_000)
            )
        
        CalleeControllerProxy
            .increaseCounter
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000
            )
    }
    
    public func asyncCallIncreaseCounterWithCallbackWithOneParameter(
        receiver: Address,
        callbackValue: BigUint
    ) {
        CalleeControllerProxy
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
        CalleeControllerProxy
            .increaseCounterBy(value: value)
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000
            )
    }
    
    public mutating func asyncCallIncreaseCounterAndFail(receiver: Address) {
        self.counter += 100
        
        CalleeControllerProxy
            .increaseCounterAndFail
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000
            )
        
        self.counter += 150
    }
    
    public mutating func asyncCallIncreaseCounterAndFailWithCallback(receiver: Address) {
        self.counter += 100
        
        CalleeControllerProxy
            .increaseCounterAndFail
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                callback: self.$callbackWithResult(gasForCallback: 5_000_000)
            )
        
        self.counter += 150
    }
    
    public func asyncCallGetCounterWithCallback(receiver: Address) {
        CalleeControllerProxy
            .getCounter
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                callback: self.$callbackWithResult(gasForCallback: 5_000_000)
            )
    }
    
    public func multiAsyncCallGetCounterWithCallback(receiver: Address) {
        CalleeControllerProxy
            .getCounter
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                callback: self.$callbackWithResult(gasForCallback: 5_000_000)
            )
        
        CalleeControllerProxy
            .getCounter
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                callback: self.$callbackWithResult(gasForCallback: 5_000_000)
            )
        
        CalleeControllerProxy
            .getCounter
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                callback: self.$callbackWithResult(gasForCallback: 5_000_000)
            )
    }
    
    public func multiAsyncCallGetCounterWithDifferentCallbacks(receiver: Address) {
        CalleeControllerProxy
            .getCounter
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                callback: self.$simpleCallback(gasForCallback: 5_000_000)
            )
        
        CalleeControllerProxy
            .getCounter
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                callback: self.$simpleCallback(gasForCallback: 5_000_000)
            )
        
        CalleeControllerProxy
            .getCounter
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                callback: self.$callbackWithResult(gasForCallback: 5_000_000)
            )
    }
    
    public func multiAsyncCallGetCounterWithCallbackOneFailure(receiver: Address) {
        CalleeControllerProxy
            .getCounter
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                callback: self.$callbackWithResult(gasForCallback: 5_000_000)
            )
        
        CalleeControllerProxy
            .increaseCounterAndFail
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                callback: self.$callbackWithResult(gasForCallback: 5_000_000)
            )
        
        CalleeControllerProxy
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
        CalleeControllerProxy
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
        CalleeControllerProxy
            .increaseCounterAndFail
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                egldValue: paymentValue,
                callback: self.$increaseCounterAndFailWithEgldCallback(gasForCallback: 15_000_000)
            )
    }
    
    public func asyncCallStoreCallerNoCallback(
        receiver: Address
    ) {
        CalleeControllerProxy
            .storeCaller
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000
            )
    }
    
    public func asyncCallStoreCallerWithCallback(
        receiver: Address
    ) {
        CalleeControllerProxy
            .storeCaller
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                callback: self.$storeCallerCallback(gasForCallback: 10_000_000)
            )
    }
    
    public func asyncCallIncreaseCounterAndFailWithStoreCallerCallback(
        receiver: Address
    ) {
        CalleeControllerProxy
            .increaseCounterAndFail
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                callback: self.$storeCallerCallback(gasForCallback: 10_000_000)
            )
    }
    
    public func getCounter() -> BigUint {
        self.counter
    }
    
    public func getAddress() ->  Address {
        self.address
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
    
    @Callback public mutating func storeCallerCallback() {
        self.address = Message.caller
    }
}

final class AsyncCallsTests: ContractTestCase {

    override var initialAccounts: [WorldAccount] {
        [
            WorldAccount(
                address: "callee",
                controllers: [
                    CalleeController.self
                ]
            ),
            WorldAccount(
                address: "caller",
                balance: 1000,
                controllers: [
                    AsyncCallsTestsController.self
                ]
            )
        ]
    }
    
    func testIncreaseCounter() throws {
        try! self.deployContract(at: "callee")
        let calleeController = self.instantiateController(CalleeController.self, for: "callee")!
        
        try self.deployContract(at: "caller")
        let callerController = self.instantiateController(AsyncCallsTestsController.self, for: "caller")!
        
        try callerController.asyncCallIncreaseCounter(receiver: "callee")
        
        let counter = try calleeController.getCounter()
        
        XCTAssertEqual(counter, 1)
    }
    
    func testIncreaseCounterWithSimpleCallback() throws {
        try self.deployContract(at: "callee")
        let calleeController = self.instantiateController(CalleeController.self, for: "callee")!
        
        try self.deployContract(at: "caller")
        let callerController = self.instantiateController(AsyncCallsTestsController.self, for: "caller")!
        
        try callerController.asyncCallIncreaseCounterWithSimpleCallback(receiver: "callee")
        
        let calleeCounter = try calleeController.getCounter()
        let callerCounter = try callerController.getCounter()
        
        XCTAssertEqual(calleeCounter, 1)
        XCTAssertEqual(callerCounter, 1)
    }
    
    func testMultiIncreaseCounterWithSimpleCallback() throws {
        try self.deployContract(at: "callee")
        let calleeController = self.instantiateController(CalleeController.self, for: "callee")!
        
        try self.deployContract(at: "caller")
        let callerController = self.instantiateController(AsyncCallsTestsController.self, for: "caller")!
        
        try callerController.multiAsyncCallIncreaseCounterWithSimpleCallback(receiver: "callee")
        
        let calleeCounter = try calleeController.getCounter()
        let callerCounter = try callerController.getCounter()
        
        XCTAssertEqual(calleeCounter, 3)
        XCTAssertEqual(callerCounter, 3)
    }
    
    func testMultiIncreaseCounterWithSimpleCallbackOneNoCallback() throws {
        try self.deployContract(at: "callee")
        let calleeController = self.instantiateController(CalleeController.self, for: "callee")!
        
        try self.deployContract(at: "caller")
        let callerController = self.instantiateController(AsyncCallsTestsController.self, for: "caller")!
        
        try callerController.multiAsyncCallIncreaseCounterWithSimpleCallbackOneNoCallback(receiver: "callee")
        
        let calleeCounter = try calleeController.getCounter()
        let callerCounter = try callerController.getCounter()
        
        XCTAssertEqual(calleeCounter, 4)
        XCTAssertEqual(callerCounter, 3)
    }
    
    func testIncreaseCounterWithCallbackWithOneParameter() throws {
        try self.deployContract(at: "callee")
        let calleeController = self.instantiateController(CalleeController.self, for: "callee")!
        
        try self.deployContract(at: "caller")
        let callerController = self.instantiateController(AsyncCallsTestsController.self, for: "caller")!
        
        try callerController.asyncCallIncreaseCounterWithCallbackWithOneParameter(
            receiver: "callee",
            callbackValue: 50
        )
        
        let calleeCounter = try calleeController.getCounter()
        let callerCounter = try callerController.getCounter()
        
        XCTAssertEqual(calleeCounter, 1)
        XCTAssertEqual(callerCounter, 50)
    }
    
    func testIncreaseCounterWithCallbackWithResult() throws {
        try self.deployContract(at: "callee")
        var calleeController = self.instantiateController(CalleeController.self, for: "callee")!
        
        try self.deployContract(at: "caller")
        let callerController = self.instantiateController(AsyncCallsTestsController.self, for: "caller")!
        
        try calleeController.increaseCounterBy(value: 100)
        
        try callerController.asyncCallGetCounterWithCallback(receiver: "callee")
        
        let calleeCounter = try calleeController.getCounter()
        let callerCounter = try callerController.getCounter()
        
        XCTAssertEqual(calleeCounter, 100)
        XCTAssertEqual(callerCounter, 100)
    }
    
    func testMultiIncreaseCounterWithCallbackWithResult() throws {
        try self.deployContract(at: "callee")
        var calleeController = self.instantiateController(CalleeController.self, for: "callee")!
        
        try self.deployContract(at: "caller")
        let callerController = self.instantiateController(AsyncCallsTestsController.self, for: "caller")!
        
        try calleeController.increaseCounterBy(value: 100)
        
        try callerController.multiAsyncCallGetCounterWithCallback(receiver: "callee")
        
        let calleeCounter = try calleeController.getCounter()
        let callerCounter = try callerController.getCounter()
        
        XCTAssertEqual(calleeCounter, 100)
        XCTAssertEqual(callerCounter, 300)
    }
    
    func testMultiIncreaseCounterWithDifferentCallbacks() throws {
        try self.deployContract(at: "callee")
        var calleeController = self.instantiateController(CalleeController.self, for: "callee")!
        
        try self.deployContract(at: "caller")
        let callerController = self.instantiateController(AsyncCallsTestsController.self, for: "caller")!
        
        try calleeController.increaseCounterBy(value: 100)
        
        try callerController.multiAsyncCallGetCounterWithDifferentCallbacks(receiver: "callee")
        
        let calleeCounter = try calleeController.getCounter()
        let callerCounter = try callerController.getCounter()
        
        XCTAssertEqual(calleeCounter, 100)
        XCTAssertEqual(callerCounter, 102)
    }
    
    func testMultiIncreaseCounterWithCallbackWithResultOneFailure() throws {
        try self.deployContract(at: "callee")
        var calleeController = self.instantiateController(CalleeController.self, for: "callee")!
        
        try self.deployContract(at: "caller")
        let callerController = self.instantiateController(AsyncCallsTestsController.self, for: "caller")!
        
        try calleeController.increaseCounterBy(value: 100)
        
        try callerController.multiAsyncCallGetCounterWithCallbackOneFailure(receiver: "callee")
        
        let calleeCounter = try calleeController.getCounter()
        let callerCounter = try callerController.getCounter()
        
        let callerStoredErrorCode = try callerController.getStoredErrorCode()
        let callerStoredErrorMessage = try callerController.getStoredErrorMessage()
        
        XCTAssertEqual(calleeCounter, 100)
        XCTAssertEqual(callerCounter, 200)
        
        XCTAssertEqual(callerStoredErrorCode, 4)
        XCTAssertEqual(callerStoredErrorMessage, "Oh no!")
    }
    
    func testIncreaseCounterWithCallback() throws {
        try self.deployContract(at: "callee")
        let calleeController = self.instantiateController(CalleeController.self, for: "callee")!
        
        try self.deployContract(at: "caller")
        let callerController = self.instantiateController(AsyncCallsTestsController.self, for: "caller")!
        
        try callerController.asyncCallIncreaseCounterWithSimpleCallback(receiver: "callee")
        
        let calleeCounter = try calleeController.getCounter()
        let callerCounter = try callerController.getCounter()
        
        XCTAssertEqual(calleeCounter, 1)
        XCTAssertEqual(callerCounter, 1)
    }
    
    func testIncreaseCounterBy() throws {
        try self.deployContract(at: "callee")
        let calleeController = self.instantiateController(CalleeController.self, for: "callee")!
        
        try self.deployContract(at: "caller")
        let callerController = self.instantiateController(AsyncCallsTestsController.self, for: "caller")!
        
        try callerController.asyncCallIncreaseCounterBy(
            receiver: "callee",
            value: 150
        )
        
        let counter = try calleeController.getCounter()
        
        XCTAssertEqual(counter, 150)
    }
    
    func testChangeStorageAndStartFailableAsyncCall() throws {
        try self.deployContract(at: "callee")
        let calleeController = self.instantiateController(CalleeController.self, for: "callee")!
        
        try self.deployContract(at: "caller")
        var callerController = self.instantiateController(AsyncCallsTestsController.self, for: "caller")!
        
        try callerController.asyncCallIncreaseCounterAndFail(
            receiver: "callee"
        )
        
        let calleeCounter = try calleeController.getCounter()
        let callerCounter = try callerController.getCounter()
        
        XCTAssertEqual(calleeCounter, 0)
        XCTAssertEqual(callerCounter, 250)
    }
    
    func testChangeStorageAndStartFailableAsyncCallWithCallback() throws {
        try self.deployContract(at: "callee")
        let calleeController = self.instantiateController(CalleeController.self, for: "callee")!
        
        try self.deployContract(at: "caller")
        var callerController = self.instantiateController(AsyncCallsTestsController.self, for: "caller")!
        
        try callerController.asyncCallIncreaseCounterAndFailWithCallback(
            receiver: "callee"
        )
        
        let calleeCounter = try calleeController.getCounter()
        let callerCounter = try callerController.getCounter()
        
        let callerStoredErrorCode = try callerController.getStoredErrorCode()
        let callerStoredErrorMessage = try callerController.getStoredErrorMessage()
        
        XCTAssertEqual(calleeCounter, 0)
        XCTAssertEqual(callerCounter, 250)
        
        XCTAssertEqual(callerStoredErrorCode, 4)
        XCTAssertEqual(callerStoredErrorMessage, "Oh no!")
    }
    
    func testReturnEgldNoCallback() throws {
        try self.deployContract(at: "callee")
        let calleeController = self.instantiateController(CalleeController.self, for: "callee")!
        
        try self.deployContract(at: "caller")
        let callerController = self.instantiateController(AsyncCallsTestsController.self, for: "caller")!
        
        try callerController.asyncCallReturnEgldValueNoCallback(receiver: "callee", paymentValue: 150)
        
        let calleeCounter = try calleeController.getCounter()
        let calleeBalance = self.getAccount(address: "callee")?.balance
        let callerBalance = self.getAccount(address: "caller")?.balance
        
        XCTAssertEqual(calleeCounter, 150)
        XCTAssertEqual(calleeBalance, 150)
        XCTAssertEqual(callerBalance, 850)
    }
    
    func testIncreaseCounterAndFailWithEgldWithCallback() throws {
        try self.deployContract(at: "callee")
        let calleeController = self.instantiateController(CalleeController.self, for: "callee")!
        
        try self.deployContract(at: "caller")
        let callerController = self.instantiateController(AsyncCallsTestsController.self, for: "caller")!
        
        try callerController.asyncCallIncreaseCounterAndFailWithEgld(receiver: "callee", paymentValue: 150)
        
        let calleeCounter = try calleeController.getCounter()
        let callerCounter = try callerController.getCounter()
        let calleeBalance = self.getAccount(address: "callee")?.balance
        let callerBalance = self.getAccount(address: "caller")?.balance
        
        XCTAssertEqual(calleeCounter, 0)
        XCTAssertEqual(callerCounter, 1000)
        XCTAssertEqual(calleeBalance, 0)
        XCTAssertEqual(callerBalance, 1000)
    }
    
    func testAsyncCallStoreCallerNoCallback() throws {
        try self.deployContract(at: "callee")
        let calleeController = self.instantiateController(CalleeController.self, for: "callee")!
        
        try self.deployContract(at: "caller")
        let callerController = self.instantiateController(AsyncCallsTestsController.self, for: "caller")!
        
        try callerController.asyncCallStoreCallerNoCallback(receiver: "callee")
        
        let calleeStoredAddress = try calleeController.getAddress()
        
        XCTAssertEqual(calleeStoredAddress, "caller")
    }
    
    func testAsyncCallStoreCallerWithCallback() throws {
        try self.deployContract(at: "callee")
        let calleeController = self.instantiateController(CalleeController.self, for: "callee")!
        
        try self.deployContract(at: "caller")
        let callerController = self.instantiateController(AsyncCallsTestsController.self, for: "caller")!
        
        try callerController.asyncCallStoreCallerWithCallback(receiver: "callee")
        
        let calleeStoredAddress = try calleeController.getAddress()
        let callerStoredAddress = try callerController.getAddress()
        
        XCTAssertEqual(calleeStoredAddress, "caller")
        XCTAssertEqual(callerStoredAddress, "callee")
    }
    
    func testAsyncCallIncreaseCounterAndFailWithStoreCallerCallback() throws {
        try self.deployContract(at: "callee")
        
        try self.deployContract(at: "caller")
        let callerController = self.instantiateController(AsyncCallsTestsController.self, for: "caller")!
        
        try callerController.asyncCallIncreaseCounterAndFailWithStoreCallerCallback(receiver: "callee")
        
        let callerStoredAddress = try callerController.getAddress()
        
        XCTAssertEqual(callerStoredAddress, "callee")
    }
}

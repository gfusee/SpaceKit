import SpaceKitTesting

@Controller public struct CalleeController {
    @Storage(key: "counter") var counter: BigUint
    @Storage(key: "address") var address: Address
    @Storage(key: "lastReceivedTokens") var lastReceivedTokens: Vector<TokenPayment>
    
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
    
    public mutating func receiveTokens() {
        self.lastReceivedTokens = Message.allEsdtTransfers
    }
    
    public func getLastReceivedTokens() -> Vector<TokenPayment> {
        self.lastReceivedTokens
    }
    
    public func getCounter() -> BigUint {
        self.counter
    }
    
    public func getAddress() ->  Address {
        self.address
    }
}

@Proxy enum CalleeProxy {
    case increaseCounter
    case increaseCounterBy(value: BigUint)
    case increaseCounterAndFail
    case storeCaller
    case returnValueNoInput
    case returnEgldValue
    case receiveTokens
    case getCounter
}

@Controller public struct AsyncCallsTestsController {
    @Storage(key: "counter") var counter: BigUint
    @Storage(key: "address") var address: Address
    @Storage(key: "storedErrorCode") var storedErrorCode: UInt32
    @Storage(key: "storedErrorMessage") var storedErrorMessage: Buffer
    
    public func asyncCallIncreaseCounter(receiver: Address) {
        CalleeProxy
            .increaseCounter
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000
            )
    }
    
    public func asyncCallIncreaseCounterWithSimpleCallback(receiver: Address) {
        CalleeProxy
            .increaseCounter
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                callback: self.$simpleCallback(gasForCallback: 5_000_000)
            )
    }
    
    public func multiAsyncCallIncreaseCounterWithSimpleCallback(receiver: Address) {
        CalleeProxy
            .increaseCounter
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                callback: self.$simpleCallback(gasForCallback: 5_000_000)
            )
        
        CalleeProxy
            .increaseCounter
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                callback: self.$simpleCallback(gasForCallback: 5_000_000)
            )
        
        CalleeProxy
            .increaseCounter
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                callback: self.$simpleCallback(gasForCallback: 5_000_000)
            )
    }
    
    public func multiAsyncCallIncreaseCounterWithSimpleCallbackOneNoCallback(receiver: Address) {
        CalleeProxy
            .increaseCounter
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                callback: self.$simpleCallback(gasForCallback: 5_000_000)
            )
        
        CalleeProxy
            .increaseCounter
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                callback: self.$simpleCallback(gasForCallback: 5_000_000)
            )
        
        CalleeProxy
            .increaseCounter
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                callback: self.$simpleCallback(gasForCallback: 5_000_000)
            )
        
        CalleeProxy
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
        CalleeProxy
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
        CalleeProxy
            .increaseCounterBy(value: value)
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000
            )
    }
    
    public mutating func asyncCallIncreaseCounterAndFail(receiver: Address) {
        self.counter += 100
        
        CalleeProxy
            .increaseCounterAndFail
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000
            )
        
        self.counter += 150
    }
    
    public mutating func asyncCallIncreaseCounterAndFailWithCallback(receiver: Address) {
        self.counter += 100
        
        CalleeProxy
            .increaseCounterAndFail
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                callback: self.$callbackWithResult(gasForCallback: 5_000_000)
            )
        
        self.counter += 150
    }
    
    public func asyncCallGetCounterWithCallback(receiver: Address) {
        CalleeProxy
            .getCounter
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                callback: self.$callbackWithResult(gasForCallback: 5_000_000)
            )
    }
    
    public func multiAsyncCallGetCounterWithCallback(receiver: Address) {
        CalleeProxy
            .getCounter
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                callback: self.$callbackWithResult(gasForCallback: 5_000_000)
            )
        
        CalleeProxy
            .getCounter
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                callback: self.$callbackWithResult(gasForCallback: 5_000_000)
            )
        
        CalleeProxy
            .getCounter
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                callback: self.$callbackWithResult(gasForCallback: 5_000_000)
            )
    }
    
    public func multiAsyncCallGetCounterWithDifferentCallbacks(receiver: Address) {
        CalleeProxy
            .getCounter
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                callback: self.$simpleCallback(gasForCallback: 5_000_000)
            )
        
        CalleeProxy
            .getCounter
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                callback: self.$simpleCallback(gasForCallback: 5_000_000)
            )
        
        CalleeProxy
            .getCounter
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                callback: self.$callbackWithResult(gasForCallback: 5_000_000)
            )
    }
    
    public func multiAsyncCallGetCounterWithCallbackOneFailure(receiver: Address) {
        CalleeProxy
            .getCounter
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                callback: self.$callbackWithResult(gasForCallback: 5_000_000)
            )
        
        CalleeProxy
            .increaseCounterAndFail
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                callback: self.$callbackWithResult(gasForCallback: 5_000_000)
            )
        
        CalleeProxy
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
        CalleeProxy
            .returnEgldValue
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                egldValue: paymentValue
            )
    }
    
    public func asyncCallMultipleReturnEgldValueNoCallback(
        receiver: Address,
        promisesCount: UInt8,
        paymentValue: BigUint
    ) {
        for _ in 0..<promisesCount {
            CalleeProxy
                .returnEgldValue
                .registerPromise(
                    receiver: receiver,
                    gas: 10_000_000,
                    egldValue: paymentValue
                )
        }
    }
    
    public func asyncCallIncreaseCounterAndFailWithEgld(
        receiver: Address,
        paymentValue: BigUint
    ) {
        CalleeProxy
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
        CalleeProxy
            .storeCaller
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000
            )
    }
    
    public func asyncCallStoreCallerWithCallback(
        receiver: Address
    ) {
        CalleeProxy
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
        CalleeProxy
            .increaseCounterAndFail
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                callback: self.$storeCallerCallback(gasForCallback: 10_000_000)
            )
    }
    
    public func asyncCallSendTokensNoCallback(
        receiver: Address
    ) {
        CalleeProxy
            .receiveTokens
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                esdtTransfers: Message.allEsdtTransfers
            )
    }
    
    public func asyncCallMultipleSendTokensNoCallback(
        receiver: Address,
        promisesCount: UInt8,
        tokens: Vector<TokenPayment>
    ) {
        for _ in 0..<promisesCount {
            CalleeProxy
                .receiveTokens
                .registerPromise(
                    receiver: receiver,
                    gas: 10_000_000,
                    esdtTransfers: tokens
                )
        }
    }
    
    public func asyncCallSendTokensFailNoCallback(
        receiver: Address
    ) {
        CalleeProxy
            .increaseCounterAndFail
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                esdtTransfers: Message.allEsdtTransfers
            )
    }
    
    public func asyncCallSendTokensFailWithCallback(
        receiver: Address
    ) {
        CalleeProxy
            .increaseCounterAndFail
            .registerPromise(
                receiver: receiver,
                gas: 10_000_000,
                esdtTransfers: Message.allEsdtTransfers,
                callback: self.$sendTokensFailureCallback(caller: Message.caller, gasForCallback: 15_000_000)
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
    
    @Callback public func sendTokensFailureCallback(caller: Address) {
        let result: AsyncCallResult<IgnoreValue> = Message.asyncCallResult()
        
        switch result {
        case .success(_):
            fatalError("Must not be executed")
        case .error(_):
            let returnedTokens = Message.allEsdtTransfers
            
            caller.send(payments: returnedTokens)
        }
    }
}

final class AsyncCallsTests: ContractTestCase {

    override var initialAccounts: [WorldAccount] {
        [
            WorldAccount(
                address: "user",
                esdtBalances: [
                    "WEGLD-abcdef": [
                        EsdtBalance(nonce: 0, balance: 1000)
                    ],
                    "SFT-abcdef": [
                        EsdtBalance(nonce: 2, balance: 1000),
                        EsdtBalance(nonce: 10, balance: 1000)
                    ],
                    "OTHER-abcdef": [
                        EsdtBalance(nonce: 3, balance: 1000),
                    ]
                ]
            ),
            WorldAccount(
                address: "callee",
                controllers: [
                    CalleeController.self
                ]
            ),
            WorldAccount(
                address: "caller",
                balance: 1000,
                esdtBalances: [
                    "FUNG-abcdef": [
                        EsdtBalance(nonce: 0, balance: 1000)
                    ]
                ],
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
    
    func testReturnEgldInsufficientBalanceShouldFail() throws {
        try self.deployContract(at: "callee")
        
        try self.deployContract(at: "caller")
        let callerController = self.instantiateController(AsyncCallsTestsController.self, for: "caller")!
        
        do {
            try callerController.asyncCallReturnEgldValueNoCallback(receiver: "callee", paymentValue: 10000)
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .executionFailed(reason: "insufficient balance"))
        }
    }
    
    func testMultipleReturnEgldInsufficientBalanceShouldFail() throws {
        try self.deployContract(at: "callee")
        let calleeController = self.instantiateController(CalleeController.self, for: "callee")!
        
        try self.deployContract(at: "caller")
        let callerController = self.instantiateController(AsyncCallsTestsController.self, for: "caller")!
        
        do {
            try callerController.asyncCallMultipleReturnEgldValueNoCallback(receiver: "callee", promisesCount: 11, paymentValue: 100)
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .executionFailed(reason: "insufficient balance"))
        }
        
        let calleeCounter = try calleeController.getCounter()
        let calleeBalance = self.getAccount(address: "callee")?.balance
        let callerBalance = self.getAccount(address: "caller")?.balance
        
        XCTAssertEqual(calleeCounter, 0)
        XCTAssertEqual(calleeBalance, 0)
        XCTAssertEqual(callerBalance, 1000)
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
    
    func testSendOneFungibleTokenNoCallback() throws {
        try self.deployContract(at: "callee")
        let calleeController = self.instantiateController(CalleeController.self, for: "callee")!
        
        try self.deployContract(at: "caller")
        let callerController = self.instantiateController(AsyncCallsTestsController.self, for: "caller")!
        
        var esdtValue: Vector<TokenPayment> = Vector()
        
        esdtValue = esdtValue.appended(
            TokenPayment(
                tokenIdentifier: "WEGLD-abcdef",
                nonce: 0,
                amount: 100
            )
        )
        
        try callerController.asyncCallSendTokensNoCallback(
            receiver: "callee",
            transactionInput: ContractCallTransactionInput(
                callerAddress: "user",
                esdtValue: esdtValue
            )
        )
        
        let calleeLastReceivedTokens = try calleeController.getLastReceivedTokens()
        
        let userWEGLDBalance = self.getAccount(address: "user")!
            .getEsdtBalance(
                tokenIdentifier: "WEGLD-abcdef",
                nonce: 0
            )
        let callerWEGLDBalance = self.getAccount(address: "caller")!
            .getEsdtBalance(
                tokenIdentifier: "WEGLD-abcdef",
                nonce: 0
            )
        let calleeWEGLDBalance = self.getAccount(address: "callee")!
            .getEsdtBalance(
                tokenIdentifier: "WEGLD-abcdef",
                nonce: 0
            )
        
        var expectedCalleeLastReceivedTokens: Vector<TokenPayment> = Vector()
        let expectedUserWEGLDBalance: BigUint = 900
        let expectedCallerWEGLDBalance: BigUint = 0
        let expectedCalleeWEGLDBalance: BigUint = 100
        
        expectedCalleeLastReceivedTokens = expectedCalleeLastReceivedTokens.appended(
            TokenPayment(
                tokenIdentifier: "WEGLD-abcdef",
                nonce: 0,
                amount: 100
            )
        )
        
        XCTAssertEqual(calleeLastReceivedTokens, expectedCalleeLastReceivedTokens)
        XCTAssertEqual(userWEGLDBalance, expectedUserWEGLDBalance)
        XCTAssertEqual(callerWEGLDBalance, expectedCallerWEGLDBalance)
        XCTAssertEqual(calleeWEGLDBalance, expectedCalleeWEGLDBalance)
    }
    
    func testSendOneFungibleTokenNotEnoughBalanceShouldFail() throws {
        try self.deployContract(at: "callee")
        let calleeController = self.instantiateController(CalleeController.self, for: "callee")!
        
        try self.deployContract(at: "caller")
        let callerController = self.instantiateController(AsyncCallsTestsController.self, for: "caller")!
        
        var esdtValue: Vector<TokenPayment> = Vector()
        
        esdtValue = esdtValue.appended(
            TokenPayment(
                tokenIdentifier: "FUNG-abcdef",
                nonce: 0,
                amount: 10000
            )
        )
        
        do {
            try callerController.asyncCallMultipleSendTokensNoCallback(
                receiver: "callee",
                promisesCount: 1,
                tokens: esdtValue
            )
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .executionFailed(reason: "insufficient esdt balance"))
        }
        
        
        let calleeLastReceivedTokens = try calleeController.getLastReceivedTokens()
        
        let callerFUNGBalance = self.getAccount(address: "caller")!
            .getEsdtBalance(
                tokenIdentifier: "FUNG-abcdef",
                nonce: 0
            )
        let calleeFUNGBalance = self.getAccount(address: "callee")!
            .getEsdtBalance(
                tokenIdentifier: "FUNG-abcdef",
                nonce: 0
            )
        
        let expectedCalleeLastReceivedTokens: Vector<TokenPayment> = Vector()
        let expectedCallerFUNGBalance: BigUint = 1000
        let expectedCalleeFUNGBalance: BigUint = 0
        
        XCTAssertEqual(calleeLastReceivedTokens, expectedCalleeLastReceivedTokens)
        XCTAssertEqual(callerFUNGBalance, expectedCallerFUNGBalance)
        XCTAssertEqual(calleeFUNGBalance, expectedCalleeFUNGBalance)
    }
    
    func testMultipleSendOneFungibleTokenNotEnoughBalanceShouldFail() throws {
        try self.deployContract(at: "callee")
        let calleeController = self.instantiateController(CalleeController.self, for: "callee")!
        
        try self.deployContract(at: "caller")
        let callerController = self.instantiateController(AsyncCallsTestsController.self, for: "caller")!
        
        var esdtValue: Vector<TokenPayment> = Vector()
        
        esdtValue = esdtValue.appended(
            TokenPayment(
                tokenIdentifier: "FUNG-abcdef",
                nonce: 0,
                amount: 100
            )
        )
        
        do {
            try callerController.asyncCallMultipleSendTokensNoCallback(
                receiver: "callee",
                promisesCount: 11,
                tokens: esdtValue
            )
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .executionFailed(reason: "insufficient esdt balance"))
        }
        
        
        let calleeLastReceivedTokens = try calleeController.getLastReceivedTokens()
        
        let callerFUNGBalance = self.getAccount(address: "caller")!
            .getEsdtBalance(
                tokenIdentifier: "FUNG-abcdef",
                nonce: 0
            )
        let calleeFUNGBalance = self.getAccount(address: "callee")!
            .getEsdtBalance(
                tokenIdentifier: "FUNG-abcdef",
                nonce: 0
            )
        
        let expectedCalleeLastReceivedTokens: Vector<TokenPayment> = Vector()
        let expectedCallerFUNGBalance: BigUint = 1000
        let expectedCalleeFUNGBalance: BigUint = 0
        
        XCTAssertEqual(calleeLastReceivedTokens, expectedCalleeLastReceivedTokens)
        XCTAssertEqual(callerFUNGBalance, expectedCallerFUNGBalance)
        XCTAssertEqual(calleeFUNGBalance, expectedCalleeFUNGBalance)
    }
    
    func testSendOneFungibleTokenFailNoCallback() throws {
        try self.deployContract(at: "callee")
        
        try self.deployContract(at: "caller")
        let callerController = self.instantiateController(AsyncCallsTestsController.self, for: "caller")!
        
        var esdtValue: Vector<TokenPayment> = Vector()
        
        esdtValue = esdtValue.appended(
            TokenPayment(
                tokenIdentifier: "WEGLD-abcdef",
                nonce: 0,
                amount: 100
            )
        )
        
        try callerController.asyncCallSendTokensFailNoCallback(
            receiver: "callee",
            transactionInput: ContractCallTransactionInput(
                callerAddress: "user",
                esdtValue: esdtValue
            )
        )
        
        let userWEGLDBalance = self.getAccount(address: "user")!
            .getEsdtBalance(
                tokenIdentifier: "WEGLD-abcdef",
                nonce: 0
            )
        let callerWEGLDBalance = self.getAccount(address: "caller")!
            .getEsdtBalance(
                tokenIdentifier: "WEGLD-abcdef",
                nonce: 0
            )
        let calleeWEGLDBalance = self.getAccount(address: "callee")!
            .getEsdtBalance(
                tokenIdentifier: "WEGLD-abcdef",
                nonce: 0
            )
        
        let expectedUserWEGLDBalance: BigUint = 900
        let expectedCallerWEGLDBalance: BigUint = 100
        let expectedCalleeWEGLDBalance: BigUint = 0
        
        XCTAssertEqual(userWEGLDBalance, expectedUserWEGLDBalance)
        XCTAssertEqual(callerWEGLDBalance, expectedCallerWEGLDBalance)
        XCTAssertEqual(calleeWEGLDBalance, expectedCalleeWEGLDBalance)
    }
    
    func testSendOneFungibleTokenFailWithCallback() throws {
        try self.deployContract(at: "callee")
        
        try self.deployContract(at: "caller")
        let callerController = self.instantiateController(AsyncCallsTestsController.self, for: "caller")!
        
        var esdtValue: Vector<TokenPayment> = Vector()
        
        esdtValue = esdtValue.appended(
            TokenPayment(
                tokenIdentifier: "WEGLD-abcdef",
                nonce: 0,
                amount: 100
            )
        )
        
        try callerController.asyncCallSendTokensFailWithCallback(
            receiver: "callee",
            transactionInput: ContractCallTransactionInput(
                callerAddress: "user",
                esdtValue: esdtValue
            )
        )
        
        let userWEGLDBalance = self.getAccount(address: "user")!
            .getEsdtBalance(
                tokenIdentifier: "WEGLD-abcdef",
                nonce: 0
            )
        let callerWEGLDBalance = self.getAccount(address: "caller")!
            .getEsdtBalance(
                tokenIdentifier: "WEGLD-abcdef",
                nonce: 0
            )
        let calleeWEGLDBalance = self.getAccount(address: "callee")!
            .getEsdtBalance(
                tokenIdentifier: "WEGLD-abcdef",
                nonce: 0
            )
        
        let expectedUserWEGLDBalance: BigUint = 1000
        let expectedCallerWEGLDBalance: BigUint = 0
        let expectedCalleeWEGLDBalance: BigUint = 0
        
        XCTAssertEqual(userWEGLDBalance, expectedUserWEGLDBalance)
        XCTAssertEqual(callerWEGLDBalance, expectedCallerWEGLDBalance)
        XCTAssertEqual(calleeWEGLDBalance, expectedCalleeWEGLDBalance)
    }
    
    func testSendMultiTokensNoCallback() throws {
        try self.deployContract(at: "callee")
        let calleeController = self.instantiateController(CalleeController.self, for: "callee")!
        
        try self.deployContract(at: "caller")
        let callerController = self.instantiateController(AsyncCallsTestsController.self, for: "caller")!
        
        var esdtValue: Vector<TokenPayment> = Vector()
        
        esdtValue = esdtValue.appended(
            TokenPayment(
                tokenIdentifier: "SFT-abcdef",
                nonce: 2,
                amount: 100
            )
        )
        
        esdtValue = esdtValue.appended(
            TokenPayment(
                tokenIdentifier: "SFT-abcdef",
                nonce: 10,
                amount: 150
            )
        )
        
        esdtValue = esdtValue.appended(
            TokenPayment(
                tokenIdentifier: "OTHER-abcdef",
                nonce: 3,
                amount: 200
            )
        )
        
        try callerController.asyncCallSendTokensNoCallback(
            receiver: "callee",
            transactionInput: ContractCallTransactionInput(
                callerAddress: "user",
                esdtValue: esdtValue
            )
        )
        
        let calleeLastReceivedTokens = try calleeController.getLastReceivedTokens()
        
        let userSFT2Balance = self.getAccount(address: "user")!
            .getEsdtBalance(
                tokenIdentifier: "SFT-abcdef",
                nonce: 2
            )
        let callerSFT2Balance = self.getAccount(address: "caller")!
            .getEsdtBalance(
                tokenIdentifier: "SFT-abcdef",
                nonce: 2
            )
        let calleeSFT2Balance = self.getAccount(address: "callee")!
            .getEsdtBalance(
                tokenIdentifier: "SFT-abcdef",
                nonce: 2
            )
        
        let userSFT10Balance = self.getAccount(address: "user")!
            .getEsdtBalance(
                tokenIdentifier: "SFT-abcdef",
                nonce: 10
            )
        let callerSFT10Balance = self.getAccount(address: "caller")!
            .getEsdtBalance(
                tokenIdentifier: "SFT-abcdef",
                nonce: 10
            )
        let calleeSFT10Balance = self.getAccount(address: "callee")!
            .getEsdtBalance(
                tokenIdentifier: "SFT-abcdef",
                nonce: 10
            )
        
        let userOtherBalance = self.getAccount(address: "user")!
            .getEsdtBalance(
                tokenIdentifier: "OTHER-abcdef",
                nonce: 3
            )
        let callerOtherBalance = self.getAccount(address: "caller")!
            .getEsdtBalance(
                tokenIdentifier: "OTHER-abcdef",
                nonce: 3
            )
        let calleeOtherBalance = self.getAccount(address: "callee")!
            .getEsdtBalance(
                tokenIdentifier: "OTHER-abcdef",
                nonce: 3
            )
        
        var expectedCalleeLastReceivedTokens: Vector<TokenPayment> = Vector()
        
        let expectedUserSFT2Balance: BigUint = 900
        let expectedCallerSFT2Balance: BigUint = 0
        let expectedCalleeSFT2Balance: BigUint = 100
        
        let expectedUserSFT10Balance: BigUint = 850
        let expectedCallerSFT10Balance: BigUint = 0
        let expectedCalleeSFT10Balance: BigUint = 150
        
        let expectedUserOtherBalance: BigUint = 800
        let expectedCallerOtherBalance: BigUint = 0
        let expectedCalleeOtherBalance: BigUint = 200
        
        expectedCalleeLastReceivedTokens = expectedCalleeLastReceivedTokens.appended(
            TokenPayment(
                tokenIdentifier: "SFT-abcdef",
                nonce: 2,
                amount: 100
            )
        )
        
        expectedCalleeLastReceivedTokens = expectedCalleeLastReceivedTokens.appended(
            TokenPayment(
                tokenIdentifier: "SFT-abcdef",
                nonce: 10,
                amount: 150
            )
        )
        
        expectedCalleeLastReceivedTokens = expectedCalleeLastReceivedTokens.appended(
            TokenPayment(
                tokenIdentifier: "OTHER-abcdef",
                nonce: 3,
                amount: 200
            )
        )
        
        XCTAssertEqual(calleeLastReceivedTokens, expectedCalleeLastReceivedTokens)
        
        XCTAssertEqual(userSFT2Balance, expectedUserSFT2Balance)
        XCTAssertEqual(callerSFT2Balance, expectedCallerSFT2Balance)
        XCTAssertEqual(calleeSFT2Balance, expectedCalleeSFT2Balance)
        
        XCTAssertEqual(userSFT10Balance, expectedUserSFT10Balance)
        XCTAssertEqual(callerSFT10Balance, expectedCallerSFT10Balance)
        XCTAssertEqual(calleeSFT10Balance, expectedCalleeSFT10Balance)
        
        XCTAssertEqual(userOtherBalance, expectedUserOtherBalance)
        XCTAssertEqual(callerOtherBalance, expectedCallerOtherBalance)
        XCTAssertEqual(calleeOtherBalance, expectedCalleeOtherBalance)
    }
    
    func testSendMultiTokensFailWithCallback() throws {
        try self.deployContract(at: "callee")
        
        try self.deployContract(at: "caller")
        let callerController = self.instantiateController(AsyncCallsTestsController.self, for: "caller")!
        
        var esdtValue: Vector<TokenPayment> = Vector()
        
        esdtValue = esdtValue.appended(
            TokenPayment(
                tokenIdentifier: "SFT-abcdef",
                nonce: 2,
                amount: 100
            )
        )
        
        esdtValue = esdtValue.appended(
            TokenPayment(
                tokenIdentifier: "SFT-abcdef",
                nonce: 10,
                amount: 150
            )
        )
        
        esdtValue = esdtValue.appended(
            TokenPayment(
                tokenIdentifier: "OTHER-abcdef",
                nonce: 3,
                amount: 200
            )
        )
        
        try callerController.asyncCallSendTokensFailWithCallback(
            receiver: "callee",
            transactionInput: ContractCallTransactionInput(
                callerAddress: "user",
                esdtValue: esdtValue
            )
        )
        
        let userSFT2Balance = self.getAccount(address: "user")!
            .getEsdtBalance(
                tokenIdentifier: "SFT-abcdef",
                nonce: 2
            )
        let callerSFT2Balance = self.getAccount(address: "caller")!
            .getEsdtBalance(
                tokenIdentifier: "SFT-abcdef",
                nonce: 2
            )
        let calleeSFT2Balance = self.getAccount(address: "callee")!
            .getEsdtBalance(
                tokenIdentifier: "SFT-abcdef",
                nonce: 2
            )
        
        let userSFT10Balance = self.getAccount(address: "user")!
            .getEsdtBalance(
                tokenIdentifier: "SFT-abcdef",
                nonce: 10
            )
        let callerSFT10Balance = self.getAccount(address: "caller")!
            .getEsdtBalance(
                tokenIdentifier: "SFT-abcdef",
                nonce: 10
            )
        let calleeSFT10Balance = self.getAccount(address: "callee")!
            .getEsdtBalance(
                tokenIdentifier: "SFT-abcdef",
                nonce: 10
            )
        
        let userOtherBalance = self.getAccount(address: "user")!
            .getEsdtBalance(
                tokenIdentifier: "OTHER-abcdef",
                nonce: 3
            )
        let callerOtherBalance = self.getAccount(address: "caller")!
            .getEsdtBalance(
                tokenIdentifier: "OTHER-abcdef",
                nonce: 3
            )
        let calleeOtherBalance = self.getAccount(address: "callee")!
            .getEsdtBalance(
                tokenIdentifier: "OTHER-abcdef",
                nonce: 3
            )
        
        let expectedUserSFT2Balance: BigUint = 1000
        let expectedCallerSFT2Balance: BigUint = 0
        let expectedCalleeSFT2Balance: BigUint = 0
        
        let expectedUserSFT10Balance: BigUint = 1000
        let expectedCallerSFT10Balance: BigUint = 0
        let expectedCalleeSFT10Balance: BigUint = 0
        
        let expectedUserOtherBalance: BigUint = 1000
        let expectedCallerOtherBalance: BigUint = 0
        let expectedCalleeOtherBalance: BigUint = 0
        
        XCTAssertEqual(userSFT2Balance, expectedUserSFT2Balance)
        XCTAssertEqual(callerSFT2Balance, expectedCallerSFT2Balance)
        XCTAssertEqual(calleeSFT2Balance, expectedCalleeSFT2Balance)
        
        XCTAssertEqual(userSFT10Balance, expectedUserSFT10Balance)
        XCTAssertEqual(callerSFT10Balance, expectedCallerSFT10Balance)
        XCTAssertEqual(calleeSFT10Balance, expectedCalleeSFT10Balance)
        
        XCTAssertEqual(userOtherBalance, expectedUserOtherBalance)
        XCTAssertEqual(callerOtherBalance, expectedCallerOtherBalance)
        XCTAssertEqual(calleeOtherBalance, expectedCalleeOtherBalance)
    }
    
    func testSendMultiTokensFailNoCallback() throws {
        try self.deployContract(at: "callee")
        
        try self.deployContract(at: "caller")
        let callerController = self.instantiateController(AsyncCallsTestsController.self, for: "caller")!
        
        var esdtValue: Vector<TokenPayment> = Vector()
        
        esdtValue = esdtValue.appended(
            TokenPayment(
                tokenIdentifier: "SFT-abcdef",
                nonce: 2,
                amount: 100
            )
        )
        
        esdtValue = esdtValue.appended(
            TokenPayment(
                tokenIdentifier: "SFT-abcdef",
                nonce: 10,
                amount: 150
            )
        )
        
        esdtValue = esdtValue.appended(
            TokenPayment(
                tokenIdentifier: "OTHER-abcdef",
                nonce: 3,
                amount: 200
            )
        )
        
        try callerController.asyncCallSendTokensFailNoCallback(
            receiver: "callee",
            transactionInput: ContractCallTransactionInput(
                callerAddress: "user",
                esdtValue: esdtValue
            )
        )
        
        let userSFT2Balance = self.getAccount(address: "user")!
            .getEsdtBalance(
                tokenIdentifier: "SFT-abcdef",
                nonce: 2
            )
        let callerSFT2Balance = self.getAccount(address: "caller")!
            .getEsdtBalance(
                tokenIdentifier: "SFT-abcdef",
                nonce: 2
            )
        let calleeSFT2Balance = self.getAccount(address: "callee")!
            .getEsdtBalance(
                tokenIdentifier: "SFT-abcdef",
                nonce: 2
            )
        
        let userSFT10Balance = self.getAccount(address: "user")!
            .getEsdtBalance(
                tokenIdentifier: "SFT-abcdef",
                nonce: 10
            )
        let callerSFT10Balance = self.getAccount(address: "caller")!
            .getEsdtBalance(
                tokenIdentifier: "SFT-abcdef",
                nonce: 10
            )
        let calleeSFT10Balance = self.getAccount(address: "callee")!
            .getEsdtBalance(
                tokenIdentifier: "SFT-abcdef",
                nonce: 10
            )
        
        let userOtherBalance = self.getAccount(address: "user")!
            .getEsdtBalance(
                tokenIdentifier: "OTHER-abcdef",
                nonce: 3
            )
        let callerOtherBalance = self.getAccount(address: "caller")!
            .getEsdtBalance(
                tokenIdentifier: "OTHER-abcdef",
                nonce: 3
            )
        let calleeOtherBalance = self.getAccount(address: "callee")!
            .getEsdtBalance(
                tokenIdentifier: "OTHER-abcdef",
                nonce: 3
            )
        
        let expectedUserSFT2Balance: BigUint = 900
        let expectedCallerSFT2Balance: BigUint = 100
        let expectedCalleeSFT2Balance: BigUint = 0
        
        let expectedUserSFT10Balance: BigUint = 850
        let expectedCallerSFT10Balance: BigUint = 150
        let expectedCalleeSFT10Balance: BigUint = 0
        
        let expectedUserOtherBalance: BigUint = 800
        let expectedCallerOtherBalance: BigUint = 200
        let expectedCalleeOtherBalance: BigUint = 0
        
        XCTAssertEqual(userSFT2Balance, expectedUserSFT2Balance)
        XCTAssertEqual(callerSFT2Balance, expectedCallerSFT2Balance)
        XCTAssertEqual(calleeSFT2Balance, expectedCalleeSFT2Balance)
        
        XCTAssertEqual(userSFT10Balance, expectedUserSFT10Balance)
        XCTAssertEqual(callerSFT10Balance, expectedCallerSFT10Balance)
        XCTAssertEqual(calleeSFT10Balance, expectedCalleeSFT10Balance)
        
        XCTAssertEqual(userOtherBalance, expectedUserOtherBalance)
        XCTAssertEqual(callerOtherBalance, expectedCallerOtherBalance)
        XCTAssertEqual(calleeOtherBalance, expectedCalleeOtherBalance)
    }
}

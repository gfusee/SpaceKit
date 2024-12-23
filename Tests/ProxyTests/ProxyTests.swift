import SpaceKit
import SpaceKitTesting

@Proxy enum CalleeProxy {
    case endpointWithoutParameter
    case endpointWithOneParameter(arg: BigUint), endpointOnTheSameLine(arg: Buffer)
    case endpointWithMultipleParameters(firstArg: Int32, secondArg: Buffer)
    case endpointWithNonNamedParameters(Int32, Buffer)
    case throwError
    case returnEgldValue
    case returnAllEsdtTransfers
    case callEndpointWithMultipleParameters(calleeAddress: Address, firstArg: Int32, secondArg: Buffer)
    case callThrowError(calleeAddress: Address)
}

@Controller struct CalleeController {
    public mutating func endpointWithoutParameter() {}
    
    public mutating func endpointWithOneParameter(arg: BigUint) -> BigUint {
        return arg
    }
    
    public mutating func endpointOnTheSameLine(arg: Buffer) -> Buffer {
        return arg
    }
    
    public mutating func endpointWithMultipleParameters(firstArg: Int32, secondArg: Buffer) -> Buffer {
        var result = Buffer()
        
        for _ in 0...firstArg {
            result = result + secondArg
        }
        
        return result
    }
    
    public mutating func endpointWithNonNamedParameters(firstArg: Int32, secondArg: Buffer) -> Buffer {
        var result = Buffer()
        
        for _ in 0...firstArg {
            result = result + secondArg
        }
        
        return result
    }
    
    public mutating func throwError() {
        smartContractError(message: "This is an error")
    }
    
    public mutating func returnEgldValue() -> BigUint {
        return Message.egldValue
    }
    
    public mutating func returnAllEsdtTransfers() -> Vector<TokenPayment> {
        return Message.allEsdtTransfers
    }
    
    public mutating func callEndpointWithMultipleParameters(calleeAddress: Address, firstArg: Int32, secondArg: Buffer) -> Buffer {
        return CalleeProxy.endpointWithMultipleParameters(firstArg: firstArg, secondArg: secondArg).call(receiver: calleeAddress)
    }
    
    public mutating func callThrowError(calleeAddress: Address) {
        CalleeProxy.throwError.callAndIgnoreResult(receiver: calleeAddress)
    }
}

@Controller struct CallerController {
    public mutating func callEndpointWithoutParameter(calleeAddress: Address) {
        CalleeProxy.endpointWithoutParameter.callAndIgnoreResult(receiver: calleeAddress)
    }
    
    public mutating func callEndpointWithOneParameter(calleeAddress: Address, arg: BigUint) -> BigUint {
        return CalleeProxy.endpointWithOneParameter(arg: arg).call(receiver: calleeAddress)
    }
    
    public mutating func callEndpointOnTheSameLine(calleeAddress: Address, arg: Buffer) -> Buffer {
        return CalleeProxy.endpointOnTheSameLine(arg: arg).call(receiver: calleeAddress)
    }
    
    public mutating func callEndpointWithMultipleParameters(calleeAddress: Address, firstArg: Int32, secondArg: Buffer) -> Buffer {
        return CalleeProxy.endpointWithMultipleParameters(firstArg: firstArg, secondArg: secondArg).call(receiver: calleeAddress)
    }
    
    public mutating func callEndpointWithMultipleParametersNonNamed(calleeAddress: Address, firstArg: Int32, secondArg: Buffer) -> Buffer {
        return CalleeProxy.endpointWithNonNamedParameters(firstArg, secondArg).call(receiver: calleeAddress)
    }
    
    public mutating func callEndpointThrowError(calleeAddress: Address) {
        CalleeProxy.throwError.callAndIgnoreResult(receiver: calleeAddress)
    }
    
    public mutating func callReturnEgldValue(calleeAddress: Address, egldValue: BigUint) -> BigUint {
        return CalleeProxy.returnEgldValue.call(receiver: calleeAddress, egldValue: egldValue)
    }
    
    public mutating func callReturnAllEsdtTransfers(calleeAddress: Address, esdtTransfers: Vector<TokenPayment>) -> Vector<TokenPayment> {
        return CalleeProxy.returnAllEsdtTransfers.call(receiver: calleeAddress, esdtTransfers: esdtTransfers)
    }
    
    public mutating func callNestedCallEndpointWithMultipleParameters(calleeAddress: Address, secondCalleeAddress: Address, firstArg: Int32, secondArg: Buffer) -> Buffer {
        return CalleeProxy.callEndpointWithMultipleParameters(calleeAddress: secondCalleeAddress, firstArg: firstArg, secondArg: secondArg).call(receiver: calleeAddress)
    }
    
    public mutating func callNestedCallThrowError(calleeAddress: Address, secondCalleeAddress: Address) {
        CalleeProxy.callThrowError(calleeAddress: secondCalleeAddress).callAndIgnoreResult(receiver: calleeAddress)
    }
}

final class ProxyTests: ContractTestCase {
    
    override var initialAccounts: [WorldAccount] {
        [
            WorldAccount(
                address: "callee",
                controllers: [
                    CalleeController.self
                ]
            ),
            WorldAccount(
                address: "callee2",
                controllers: [
                    CalleeController.self
                ]
            ),
            WorldAccount(
                address: "calleeNotRegistered"
            ),
            WorldAccount(
                address: "caller",
                controllers: [
                    CallerController.self
                ]
            ),
            WorldAccount(
                address: "callerWithBalance",
                balance: 150,
                controllers: [
                    CallerController.self
                ]
            ),
            WorldAccount(
                address: "callerWithEsdtBalances",
                esdtBalances: [
                    "WEGLD-abcdef": [
                        EsdtBalance(nonce: 0, balance: 100)
                    ],
                    "SFT-abcdef": [
                        EsdtBalance(nonce: 1, balance: 100),
                        EsdtBalance(nonce: 2, balance: 100)
                    ]
                ],
                controllers: [
                    CallerController.self
                ]
            )
        ]
    }
    
    func testCallEndpointWithoutParameter() throws {
        try self.deployContract(at: "callee")
        
        try self.deployContract(at: "caller")
        var callerController = self.instantiateController(CallerController.self, for: "caller")!
        
        try callerController.callEndpointWithoutParameter(calleeAddress: "callee")
    }
    
    func testCallEndpointWithOneParameter() throws {
        try self.deployContract(at: "callee")
        
        try self.deployContract(at: "caller")
        var callerController = self.instantiateController(CallerController.self, for: "caller")!
        
        let result = try callerController.callEndpointWithOneParameter(calleeAddress: "callee", arg: 5)
        
        XCTAssertEqual(result, 5)
    }
    
    func testCallEndpointOnTheSameLine() throws {
        try self.deployContract(at: "callee")
        
        try self.deployContract(at: "caller")
        var callerController = self.instantiateController(CallerController.self, for: "caller")!
        
        let result = try callerController.callEndpointOnTheSameLine(calleeAddress: "callee", arg: "buffer")
        
        XCTAssertEqual(result, "buffer")
    }
    
    func testCallEndpointWithMultipleParameters() throws {
        try self.deployContract(at: "callee")
        
        try self.deployContract(at: "caller")
        var callerController = self.instantiateController(CallerController.self, for: "caller")!
        
        let result = try callerController.callEndpointWithMultipleParameters(calleeAddress: "callee", firstArg: 2, secondArg: "buffer")
        
        XCTAssertEqual(result, "bufferbufferbuffer")
    }
    
    func testCallEndpointWithNonNamedParameters() throws {
        try self.deployContract(at: "callee")
        
        try self.deployContract(at: "caller")
        var callerController = self.instantiateController(CallerController.self, for: "caller")!
        
        let result = try callerController.callEndpointWithMultipleParametersNonNamed(calleeAddress: "callee", firstArg: 2, secondArg: "buffer")
        
        XCTAssertEqual(result, "bufferbufferbuffer")
    }
    
    func testCallEndpointCalleeNotRegistered() throws {
        try self.deployContract(at: "caller")
        var callerController = self.instantiateController(CallerController.self, for: "caller")!
        
        do {
            try callerController.callEndpointWithoutParameter(calleeAddress: "calleeNotRegistered")
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .worldError(message: "Contract not registered for address: \(self.getAccount(address: "calleeNotRegistered")!.addressData.hexEncodedString())"))
        }
    }
    
    func testCallEndpointThrowError() throws {
        try self.deployContract(at: "callee")
        
        try self.deployContract(at: "caller")
        var callerController = self.instantiateController(CallerController.self, for: "caller")!
        
        do {
            try callerController.callEndpointThrowError(calleeAddress: "callee")
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .executionFailed(reason: "execution failed"))
        }
    }
    
    func testCallReturnEgldNotEnoughCallerBalance() throws {
        try self.deployContract(at: "callee")
        
        try self.deployContract(at: "caller")
        var callerController = self.instantiateController(CallerController.self, for: "caller")!
        
        do {
            let _ = try callerController.callReturnEgldValue(calleeAddress: "callee", egldValue: 100)
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .executionFailed(reason: "insufficient balance"))
        }
    }
    
    func testCallReturnEgld() throws {
        try self.deployContract(at: "callee")
        
        try self.deployContract(at: "callerWithBalance")
        var callerController = self.instantiateController(CallerController.self, for: "callerWithBalance")!
        
        let result = try callerController.callReturnEgldValue(calleeAddress: "callee", egldValue: 100)
        
        XCTAssertEqual(self.getAccount(address: "callerWithBalance")!.balance, 50)
        XCTAssertEqual(self.getAccount(address: "callee")!.balance, 100)
        XCTAssertEqual(result, 100)
    }
    
    func testCallNestedCallEndpointWithMultipleParameters() throws {
        try self.deployContract(at: "callee")
        try self.deployContract(at: "callee2")
        
        try self.deployContract(at: "caller")
        var callerController = self.instantiateController(CallerController.self, for: "caller")!
        
        let result = try callerController.callNestedCallEndpointWithMultipleParameters(calleeAddress: "callee", secondCalleeAddress: "callee2", firstArg: 2, secondArg: "buffer")
        
        XCTAssertEqual(result, "bufferbufferbuffer")
    }
    
    func testCallNestedEndpointThrowError() throws {
        try self.deployContract(at: "callee")
        try self.deployContract(at: "callee2")
        
        try self.deployContract(at: "caller")
        var callerController = self.instantiateController(CallerController.self, for: "caller")!
        
        do {
            try callerController.callNestedCallThrowError(calleeAddress: "callee", secondCalleeAddress: "callee2")
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .executionFailed(reason: "execution failed"))
        }
    }
}

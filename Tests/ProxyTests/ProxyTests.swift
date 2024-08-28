import Space
import XCTest

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

@Contract struct CalleeContract {
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
    
    public mutating func returnAllEsdtTransfers() -> MXArray<TokenPayment> {
        return Message.allEsdtTransfers
    }
    
    public mutating func callEndpointWithMultipleParameters(calleeAddress: Address, firstArg: Int32, secondArg: Buffer) -> Buffer {
        return CalleeProxy.endpointWithMultipleParameters(firstArg: firstArg, secondArg: secondArg).call(receiver: calleeAddress)
    }
    
    public mutating func callThrowError(calleeAddress: Address) {
        CalleeProxy.throwError.callAndIgnoreResult(receiver: calleeAddress)
    }
}

@Contract struct CallerContract {
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
    
    public mutating func callReturnAllEsdtTransfers(calleeAddress: Address, esdtTransfers: MXArray<TokenPayment>) -> MXArray<TokenPayment> {
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
            WorldAccount(address: "callee"),
            WorldAccount(address: "callee2"),
            WorldAccount(address: "caller"),
            WorldAccount(
                address: "callerWithBalance",
                balance: 150
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
                ]
            )
        ]
    }
    
    func testCallEndpointWithoutParameter() throws {
        let _ = try CalleeContract.testable("callee")
        var caller = try CallerContract.testable("caller")
        
        try caller.callEndpointWithoutParameter(calleeAddress: "callee")
    }
    
    func testCallEndpointWithOneParameter() throws {
        let _ = try CalleeContract.testable("callee")
        var caller = try CallerContract.testable("caller")
        
        let result = try caller.callEndpointWithOneParameter(calleeAddress: "callee", arg: 5)
        
        XCTAssertEqual(result, 5)
    }
    
    func testCallEndpointOnTheSameLine() throws {
        let _ = try CalleeContract.testable("callee")
        var caller = try CallerContract.testable("caller")
        
        let result = try caller.callEndpointOnTheSameLine(calleeAddress: "callee", arg: "buffer")
        
        XCTAssertEqual(result, "buffer")
    }
    
    func testCallEndpointWithMultipleParameters() throws {
        let _ = try CalleeContract.testable("callee")
        var caller = try CallerContract.testable("caller")
        
        let result = try caller.callEndpointWithMultipleParameters(calleeAddress: "callee", firstArg: 2, secondArg: "buffer")
        
        XCTAssertEqual(result, "bufferbufferbuffer")
    }
    
    func testCallEndpointWithNonNamedParameters() throws {
        let _ = try CalleeContract.testable("callee")
        var caller = try CallerContract.testable("caller")
        
        let result = try caller.callEndpointWithMultipleParametersNonNamed(calleeAddress: "callee", firstArg: 2, secondArg: "buffer")
        
        XCTAssertEqual(result, "bufferbufferbuffer")
    }
    
    func testCallEndpointCalleeNotRegistered() throws {
        var caller = try CallerContract.testable("caller")
        
        do {
            try caller.callEndpointWithoutParameter(calleeAddress: "callee")
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .worldError(message: "Contract not registered for address: \(self.getAccount(address: "callee")!.addressData.hexEncodedString())"))
        }
    }
    
    func testCallEndpointThrowError() throws {
        let _ = try CalleeContract.testable("callee")
        var caller = try CallerContract.testable("caller")
        
        do {
            try caller.callEndpointThrowError(calleeAddress: "callee")
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .executionFailed(reason: "execution failed"))
        }
    }
    
    func testCallReturnEgldNotEnoughCallerBalance() throws {
        let _ = try CalleeContract.testable("callee")
        var caller = try CallerContract.testable("caller")
        
        do {
            let _ = try caller.callReturnEgldValue(calleeAddress: "callee", egldValue: 100)
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .executionFailed(reason: "insufficient balance"))
        }
    }
    
    func testCallReturnEgld() throws {
        let _ = try CalleeContract.testable("callee")
        var caller = try CallerContract.testable("callerWithBalance")
        
        let result = try caller.callReturnEgldValue(calleeAddress: "callee", egldValue: 100)
        
        XCTAssertEqual(self.getAccount(address: "callerWithBalance")!.balance, 50)
        XCTAssertEqual(self.getAccount(address: "callee")!.balance, 100)
        XCTAssertEqual(result, 100)
    }
    
    func testCallNestedCallEndpointWithMultipleParameters() throws {
        let _ = try CalleeContract.testable("callee")
        let _ = try CalleeContract.testable("callee2")
        var caller = try CallerContract.testable("caller")
        
        let result = try caller.callNestedCallEndpointWithMultipleParameters(calleeAddress: "callee", secondCalleeAddress: "callee2", firstArg: 2, secondArg: "buffer")
        
        XCTAssertEqual(result, "bufferbufferbuffer")
    }
    
    func testCallNestedEndpointThrowError() throws {
        let _ = try CalleeContract.testable("callee")
        let _ = try CalleeContract.testable("callee2")
        var caller = try CallerContract.testable("caller")
        
        do {
            try caller.callNestedCallThrowError(calleeAddress: "callee", secondCalleeAddress: "callee2")
            
            XCTFail()
        } catch {
            XCTAssertEqual(error, .executionFailed(reason: "execution failed"))
        }
    }
}

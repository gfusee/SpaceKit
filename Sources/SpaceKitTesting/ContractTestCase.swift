#if canImport(XCTest)
import XCTest
import SpaceKit

open class ContractTestCase: XCTestCase {
    open var initialAccounts: [WorldAccount] {
        get {
            return []
        }
    }
    
    open override func setUp() {
        super.setUp()
        
        API.globalLock.lock()
        
        var world = WorldState()
        world.setAccounts(accounts: self.initialAccounts)
        
        API.worldState = world
    }
    
    open override func tearDown() {
        super.tearDown()
        
        API.globalLock.unlock()
    }
    
    final public func getAccount(address: String) -> WorldAccount? {
        let addressData = address.toAddressData()
        
        return API.getAccount(addressData: addressData)
    }
    
    final public func getTokenAttributes(
        tokenIdentifier: Buffer,
        nonce: UInt64
    ) -> Buffer {
        let result = Buffer()
        
        API.getTokenAttributes(
            tokenIdentifierHandle: tokenIdentifier.handle,
            nonce: nonce,
            resultHandle: result.handle
        )
        
        return result
    }
    
    final public func deployContract(
        at address: String,
        arguments: [any TopEncodeMulti & TopDecodeMulti] = [],
        transactionInput: ContractCallTransactionInput? = nil,
        transactionOutput: TransactionOutput = TransactionOutput()
    ) throws(TransactionError) {
        let transactionInput = transactionInput ?? ContractCallTransactionInput()
        
        let actualTransactionInput = transactionInput.toTransactionInput(
            contractAddress: address,
            arguments: arguments
        )
        
        try runTestCall(
            contractAddress: address,
            endpointName: "init",
            transactionInput: actualTransactionInput,
            transactionOutput: transactionOutput
        ) {
            let ownerAddress = transactionInput.callerAddress?.toAddressData() ?? address.toAddressData()
            API.setCurrentSCOwnerAddress(owner: ownerAddress)

            guard var selector = self.getAccount(address: address)?.controllers as? [ContractEndpointSelector.Type] else {
                API.throwFunctionNotFoundError()
            }
            
            guard selector._callEndpoint(name: "init") else {
                API.throwFunctionNotFoundError()
            }
        }
    }
    
    final public func instantiateController<T: SwiftVMCompatibleContract>(
        _ controllerType: T.Type,
        for address: String
    ) -> T.TestableContractType? {
        guard let accountControllers = self.getAccount(address: address)?.controllers else {
            return nil
        }
        
        guard accountControllers.first(where: { $0 == controllerType }) != nil else {
            return nil
        }
        
        return T.TestableContractType.init(address: address)
    }
    
}

#endif

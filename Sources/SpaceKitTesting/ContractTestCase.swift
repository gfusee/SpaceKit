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
        API.setBlockInfos(
            nonce: 0,
            timestamp: 0,
            round: 0,
            epoch: 0,
            randomSeed: Data(Array(repeating: UInt8(0), count: RANDOM_SEED_LENGTH))
        )
    }
    
    open override func tearDown() {
        super.tearDown()
        
        API.globalLock.unlock()
    }
    
    final public func getAccount(address: String) -> WorldAccount? {
        let addressData = address.toAddressData()
        
        return API.getAccount(addressData: addressData)
    }
    
    final public func getTokenAttributes<T: TopDecode>(
        tokenIdentifier: TokenIdentifier,
        nonce: UInt64
    ) -> T {
        let resultRaw = Buffer()
        
        API.getGlobalTokenAttributes(
            tokenIdentifierHandle: tokenIdentifier.buffer.handle,
            nonce: nonce,
            resultHandle: resultRaw.handle
        )
        
        return T(topDecode: resultRaw)
    }
    
    package func setBlockInfos(
        nonce: UInt64? = nil,
        timestamp: UInt64? = nil,
        round: UInt64? = nil,
        epoch: UInt64? = nil,
        randomSeed: Data? = nil
    ) {
        API.setBlockInfos(
            nonce: nonce,
            timestamp: timestamp,
            round: round,
            epoch: epoch,
            randomSeed: randomSeed
        )
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

#if !WASM && canImport(XCTest)
import XCTest

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
    
    final public func deployContract<T: ContractEndpointSelector & SwiftVMCompatibleContract>(
        _ contractType: T.Type,
        at address: String,
        arguments: [TopEncodeMulti & TopDecodeMulti] = [],
        transactionInput: ContractCallTransactionInput? = nil,
        transactionOutput: TransactionOutput = TransactionOutput()
    ) throws(TransactionError) -> T.TestableContractType {
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

            T.__contractInit()

            API.registerContractEndpointSelectorForContractAddress(
                contractAddress: ownerAddress,
                selector: T()
            )
        }
        
        return T.TestableContractType(address: address)
    }
    
}

#endif

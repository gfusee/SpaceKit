#if !WASM && TESTING
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
    
}

#endif

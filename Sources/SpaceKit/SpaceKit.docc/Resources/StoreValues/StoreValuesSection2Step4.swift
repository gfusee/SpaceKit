import SpaceKit

@Contract struct MyContract {
    @Mapping<Address, UInt64>(key: "storedIntegerForUser") var storedIntegerForUser
    
    public func increaseStoredValue() {
        let caller = Message.caller
        
        self.storedIntegerForUser[caller] = self.storedIntegerForUser[caller] + 1
    }
}

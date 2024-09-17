import Space

@Contract struct MyContract {
    @Mapping<Address, UInt64>(key: "storedIntegerForUser") var storedIntegerForUser
    
    public func increaseStoredValue() {
        let caller = Message.caller
        
        guard self.storedIntegerForUser[caller] < 100 else {
            self.storedIntegerForUser[caller] = 0
            return
        }
        
        self.storedIntegerForUser[caller] = self.storedIntegerForUser[caller] + 1
    }
    
    public func getStoredIntegerForUser(user: Address) -> UInt64 {
        return self.storedIntegerForUser[user]
    }
}

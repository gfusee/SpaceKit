import Space

@Contract struct MyContract {
    @Storage(key: "storedInteger") var storedInteger: UInt64
    
    public func increaseStoredValue() {
        guard self.storedInteger < 100 else {
            self.storedInteger = 0
            return
        }
        
        self.storedInteger = self.storedInteger + 1
    }
}

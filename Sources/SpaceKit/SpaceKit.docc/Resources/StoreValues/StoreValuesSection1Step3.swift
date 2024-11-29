import SpaceKit

@Contract struct MyContract {
    @Storage(key: "storedInteger") var storedInteger: UInt64
    
    public func increaseStoredValue() {
        self.storedInteger = self.storedInteger + 1
    }
}

import SpaceKit

@Controller public struct MyController {
    @Mapping<Address, UInt64>(key: "storedIntegerForUser") var storedIntegerForUser
    
    public func increaseStoredValue() {
        let caller = Message.caller
        
        guard self.storedIntegerForUser[caller] < 100 else {
            self.storedIntegerForUser[caller] = 0
            return
        }
        
        self.storedIntegerForUser[caller] = self.storedIntegerForUser[caller] + 1
    }
}

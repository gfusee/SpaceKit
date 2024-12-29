import SpaceKit

@Controller public struct MyController {
    @Mapping<Address, UInt64>(key: "storedIntegerForUser") var storedIntegerForUser
    
    public func increaseStoredValue() {
        let caller = Message.caller
    }
}

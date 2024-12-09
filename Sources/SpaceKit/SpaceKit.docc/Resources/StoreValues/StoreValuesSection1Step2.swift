import SpaceKit

@Controller struct MyController {
    @Storage(key: "storedInteger") var storedInteger: UInt64
    
    public func increaseStoredValue() {
        
    }
}

import SpaceKit

@Controller public struct FirstController {
    @Storage(key: "firstControllerStoredValue") var firstControllerStoredValue: Buffer
    
    public func getFirstControllerStoredValue() -> Buffer {
        self.firstControllerStoredValue
    }
}

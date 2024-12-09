import SpaceKit

@Controller struct SecondController {
    @Storage(key: "secondControllerStoredValue") var secondControllerStoredValue: Buffer
    
    public func getSecondControllerStoredValue() -> Buffer {
        self.secondControllerStoredValue
    }
}

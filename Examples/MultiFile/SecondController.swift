import SpaceKit

@Contract struct SecondController {
    @Storage(key: "secondControllerStoredValue") var secondControllerStoredValue: Buffer
    
    public func getSecondControllerStoredValue() -> Buffer {
        self.secondControllerStoredValue
    }
}

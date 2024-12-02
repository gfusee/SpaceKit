import SpaceKit

@Contract struct SecondController {
    @Storage(key: "secondControllerStoredValue") var secondControllerStoredValue: Buffer
    
    public mutating func setSecondControllerStoredValue(value: Buffer) {
        self.secondControllerStoredValue = value
    }
    
    public func getSecondControllerValue() -> Buffer {
        self.secondControllerStoredValue
    }
}

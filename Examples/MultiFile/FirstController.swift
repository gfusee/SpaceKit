import SpaceKit

@Contract struct FirstController {
    @Storage(key: "firstControllerStoredValue") var firstControllerStoredValue: Buffer
    
    public init(
        firstControllerValue: Buffer,
        secondControllerValue: Buffer
    )  {
        self.firstControllerStoredValue = firstControllerValue
        
        var secondController = SecondController()
        secondController.secondControllerStoredValue = secondControllerValue
        
    }
    
    public mutating func setFirstControllerStoredValue(value: Buffer) {
        self.firstControllerStoredValue = value
    }
    
    public func getFirstControllerValue() -> Buffer {
        self.firstControllerStoredValue
    }
}

import SpaceKit

@Init func initialize(
    firstControllerValue: Buffer,
    secondControllerValue: Buffer
)  {
    var firstController = FirstController()
    firstController.firstControllerStoredValue = firstControllerValue
    
    var secondController = SecondController()
    secondController.secondControllerStoredValue = secondControllerValue
    
}

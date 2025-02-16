import SpaceKit

@Init func initialize(initialValue: BigUint) {
    var controller = CounterController()
    
    controller.counter = initialValue
}

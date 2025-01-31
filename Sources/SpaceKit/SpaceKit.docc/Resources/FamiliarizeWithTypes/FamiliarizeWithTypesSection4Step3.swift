import SpaceKit

@Controller public struct MyController {
    public func myEndpoint() {
        var myVector: Vector<BigUint> = Vector()
        myVector = myVector.appended(2)
        myVector = myVector.appended(10)
        myVector = myVector.appended(1)
    }
}

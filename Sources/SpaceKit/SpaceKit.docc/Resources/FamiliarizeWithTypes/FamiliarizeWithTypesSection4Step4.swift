import SpaceKit

@Controller struct MyContract {
    public func myEndpoint() {
        var myVector: Vector<BigUint> = Vector()
        myVector = myVector.appended(2)
        myVector = myVector.appended(10)
        myVector = myVector.appended(1)
        
        var sum: BigUint = 0
        myVector.forEach { item in
            sum = sum + item
        }
    }
}

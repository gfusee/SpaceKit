import SpaceKit

@Controller struct MyContract {
    public func myEndpoint() {
        let myString: String = "Hey!" // Won't compile! ❌
    }
}

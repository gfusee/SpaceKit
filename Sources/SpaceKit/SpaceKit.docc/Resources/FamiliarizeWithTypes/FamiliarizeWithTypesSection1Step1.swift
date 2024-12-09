import SpaceKit

@Controller struct MyController {
    public func myEndpoint() {
        let myString: String = "Hey!" // Won't compile! ❌
    }
}

import SpaceKit

@Controller public struct MyController {
    public func myEndpoint() {
        var myBuffer: Buffer = "Hello"
        myBuffer = myBuffer.appended(" World!")
    }
}

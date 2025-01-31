import SpaceKit

@Controller public struct MyController {
    public func myEndpoint() {
        var myBuffer: Buffer = "Hello"
        myBuffer = myBuffer.appended(" World!")
        
        guard myBuffer != "Hello World!" else {
            smartContractError(message: "myBuffer is not equal to Hello World!")
        }
    }
}

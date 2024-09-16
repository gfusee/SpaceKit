import Space

@Contract struct MyContract {
    public func myEndpoint() {
        var myBuffer: Buffer = "Hello"
        myBuffer = myBuffer.appended(" World!")
    }
}

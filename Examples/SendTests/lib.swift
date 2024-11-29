import SpaceKit

@Proxy enum SendTestsProxy {
    case receiveTokens
}

@Contract struct SendTests {
    @Storage(key: "lastReceivedTokens") var lastReceivedTokens: Vector<TokenPayment>
    
    public mutating func receiveTokens() {
        self.lastReceivedTokens = Message.allEsdtTransfers
    }
    
    public func sendTokens(
        receiver: Address
    ) {
        SendTestsProxy
            .receiveTokens
            .callAndIgnoreResult(
                receiver: receiver,
                esdtTransfers: Message.allEsdtTransfers
            )
    }
    
    public func getLastReceivedTokens() -> Vector<TokenPayment> {
        self.lastReceivedTokens
    }
}

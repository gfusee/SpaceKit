import Space

@Contract struct MyContract {
    @Storage(key: "issuedTokenIdentifier") var issuedTokenIdentifier: Buffer
    
    public func issueTokenIdentifier() {
        
    }
}


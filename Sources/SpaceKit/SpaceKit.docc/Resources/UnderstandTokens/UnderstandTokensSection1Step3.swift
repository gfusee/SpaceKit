import SpaceKit

@Controller struct MyContract {
    @Storage(key: "issuedTokenIdentifier") var issuedTokenIdentifier: TokenIdentifier
    
    public func issueToken() {
        
    }
}


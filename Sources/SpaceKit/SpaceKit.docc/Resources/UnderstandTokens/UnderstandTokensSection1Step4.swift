import SpaceKit

@Controller struct MyContract {
    @Storage(key: "issuedTokenIdentifier") var issuedTokenIdentifier: Buffer
    
    public func issueToken() {
        assertOwner()

        if !self.$issuedTokenIdentifier.isEmpty() {
            smartContractError(message: "Token already issued")
        }
    }
}


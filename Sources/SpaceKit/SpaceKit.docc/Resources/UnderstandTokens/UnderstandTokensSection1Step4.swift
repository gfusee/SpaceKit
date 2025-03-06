import SpaceKit

@Controller public struct MyContract {
    @Storage(key: "issuedTokenIdentifier") var issuedTokenIdentifier: TokenIdentifier
    
    public func issueToken() {
        assertOwner()

        if !self.$issuedTokenIdentifier.isEmpty() {
            smartContractError(message: "Token already issued")
        }
    }
}


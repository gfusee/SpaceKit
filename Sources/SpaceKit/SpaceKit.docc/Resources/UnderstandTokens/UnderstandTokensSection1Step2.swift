import SpaceKit

@Controller public struct MyContract {
    @Storage(key: "issuedTokenIdentifier") var issuedTokenIdentifier: TokenIdentifier
}


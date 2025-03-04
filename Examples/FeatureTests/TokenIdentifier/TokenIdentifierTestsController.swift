import SpaceKit

@Controller public struct TokenIdentifierTestsController {
    public func checkIfIsValid(tokenIdentifier: TokenIdentifier) -> Bool {
        tokenIdentifier.isValid
    }
}

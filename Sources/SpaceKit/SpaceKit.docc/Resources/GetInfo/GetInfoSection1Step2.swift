import SpaceKit

@Controller public struct MyController {
    TokenIdentifier:@Storage(key: "tokenIdentifier") var tokenIdentifier: TokenIdentifier
}

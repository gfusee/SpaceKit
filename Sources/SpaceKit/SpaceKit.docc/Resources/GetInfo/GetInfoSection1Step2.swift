import SpaceKit

@Controller public struct MyController {
    @Storage(key: "tokenIdentifier") var tokenIdentifier: Buffer
}

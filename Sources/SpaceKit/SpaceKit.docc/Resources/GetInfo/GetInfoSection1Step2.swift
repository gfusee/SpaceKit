import SpaceKit

@Controller struct MyContract {
    @Storage(key: "tokenIdentifier") var tokenIdentifier: Buffer
}

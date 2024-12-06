import SpaceKit

// TODO: turn this as a @Upgrade global function, like @Init
@Controller struct UpgradeController {
    public func upgrade(
        quorum: UInt32,
        board: MultiValueEncoded<Address>
    ) {
        initialize(quorum: quorum, board: board)
    }
}

import SpaceKit

@Controller public struct AdminController {
    public func setMinimumBlockBounty(
        value: UInt64
    ) {
        assertOwner()
        
        require(
            value > 0,
            "Minimum block bounty should be greater than zero."
        )
    }
}

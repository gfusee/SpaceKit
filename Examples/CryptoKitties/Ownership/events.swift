import SpaceKit

@Event public struct TransferEvent {
    let from: Address
    let to: Address
    let tokenId: UInt32
}

@Event public struct ApproveEvent {
    let owner: Address
    let approved: Address
    let tokenId: UInt32
}

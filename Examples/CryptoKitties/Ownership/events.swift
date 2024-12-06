import SpaceKit

@Event struct TransferEvent {
    let from: Address
    let to: Address
    let tokenId: UInt32
}

@Event struct ApproveEvent {
    let owner: Address
    let approved: Address
    let tokenId: UInt32
}

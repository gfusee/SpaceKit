import SpaceKit

@Event public struct SellTokenEvent {
    let user: Address
    let amount: BigUint
}

@Event public struct BuyTokenEvent {
    let user: Address
    let amount: BigUint
}

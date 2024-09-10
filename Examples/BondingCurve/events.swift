import Space

@Event struct SellTokenEvent {
    let user: Address
    let amount: BigUint
}

@Event struct BuyTokenEvent {
    let user: Address
    let amount: BigUint
}

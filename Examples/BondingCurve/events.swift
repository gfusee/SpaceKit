import MultiversX

// TODO: Using IgnoreValue where the event doesn't have any data is not intuitive
@Event(dataType: IgnoreValue) struct SellTokenEvent {
    let user: Address
    let amount: BigUint
}

// TODO: Using IgnoreValue where the event doesn't have any data is not intuitive
@Event(dataType: IgnoreValue) struct BuyTokenEvent {
    let user: Address
    let amount: BigUint
}

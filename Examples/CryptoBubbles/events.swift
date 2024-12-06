import SpaceKit

// TODO: add tests to ensure non public func are not exported in the wasm

@Event(dataType: BigUint) struct TopUpEvent {
    let player: Address
}

@Event(dataType: BigUint) struct WithdrawEvent {
    let player: Address
}

@Event(dataType: BigUint) struct PlayerJoinsGameEvent {
    let gameIndex: BigUint
    let player: Address
}

@Event(dataType: BigUint) struct RewardWinnerEvent {
    let gameIndex: BigUint
    let winner: Address
}

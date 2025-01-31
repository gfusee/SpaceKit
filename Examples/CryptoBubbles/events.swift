import SpaceKit

// TODO: add tests to ensure non public func are not exported in the wasm

@Event(dataType: BigUint) public struct TopUpEvent {
    let player: Address
}

@Event(dataType: BigUint) public struct WithdrawEvent {
    let player: Address
}

@Event(dataType: BigUint) public struct PlayerJoinsGameEvent {
    let gameIndex: BigUint
    let player: Address
}

@Event(dataType: BigUint) public struct RewardWinnerEvent {
    let gameIndex: BigUint
    let winner: Address
}

import Space

@Event(dataType: ActionFullInfo) struct StartPerformAction {}

// TODO: Using IgnoreValue where the event doesn't have any data is not intuitive
@Event(dataType: IgnoreValue) struct PerformChangeUser {
    let actionId: UInt32
    let changedUser: Address
    let oldRole: UserRole
    let newRole: UserRole
}

// TODO: Using IgnoreValue where the event doesn't have any data is not intuitive
@Event(dataType: IgnoreValue) struct PerformChangeQuorum {
    let actionId: UInt32
    let newQuorum: UInt32
}

// TODO: Using IgnoreValue where the event doesn't have any data is not intuitive
@Event(dataType: IgnoreValue) struct PerformTransferExecute {
    let actionId: UInt32
    let to: Address
    let egldValue: BigUint
    let gas: UInt64
    let endpoint: Buffer
    let arguments: MultiValueEncoded<Buffer>
}

// TODO: Using IgnoreValue where the event doesn't have any data is not intuitive
@Event(dataType: IgnoreValue) struct PerformAsyncCall {
    let actionId: UInt32
    let to: Address
    let egldValue: BigUint
    let gas: UInt64
    let endpoint: Buffer
    let arguments: MultiValueEncoded<Buffer>
}

// TODO: Using IgnoreValue where the event doesn't have any data is not intuitive
@Event(dataType: IgnoreValue) struct AsyncCallSuccess {
    let results: MultiValueEncoded<Buffer>
}

// TODO: Using IgnoreValue where the event doesn't have any data is not intuitive
@Event(dataType: IgnoreValue) struct AsyncCallError {
    let errorCode: UInt32
    let errorMessage: Buffer
}

// TODO: Using IgnoreValue where the event doesn't have any data is not intuitive
@Event(dataType: IgnoreValue) struct PerformDeployFromSource {
    let actionId: UInt32
    let egldValue: BigUint
    let sourceAddress: Address
    let codeMetadata: CodeMetadata
    let gas: UInt64
    let arguments: MultiValueEncoded<Buffer>
}

// TODO: Using IgnoreValue where the event doesn't have any data is not intuitive
@Event(dataType: IgnoreValue) struct PerformUpgradeFromSource {
    let actionId: UInt32
    let targetAddress: Address
    let egldValue: BigUint
    let sourceAddress: Address
    let codeMetadata: CodeMetadata
    let gas: UInt64
    let arguments: MultiValueEncoded<Buffer>
}

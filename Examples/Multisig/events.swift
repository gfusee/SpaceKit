import SpaceKit

@Event(dataType: ActionFullInfo) struct StartPerformAction {}

@Event struct PerformChangeUser {
    let actionId: UInt32
    let changedUser: Address
    let oldRole: UserRole
    let newRole: UserRole
}

@Event struct PerformChangeQuorum {
    let actionId: UInt32
    let newQuorum: UInt32
}

@Event struct PerformTransferExecute {
    let actionId: UInt32
    let to: Address
    let egldValue: BigUint
    let gas: UInt64
    let endpoint: Buffer
    let arguments: MultiValueEncoded<Buffer>
}

@Event struct PerformAsyncCall {
    let actionId: UInt32
    let to: Address
    let egldValue: BigUint
    let gas: UInt64
    let endpoint: Buffer
    let arguments: MultiValueEncoded<Buffer>
}

@Event struct AsyncCallSuccess {
    let results: MultiValueEncoded<Buffer>
}

@Event struct AsyncCallError {
    let errorCode: UInt32
    let errorMessage: Buffer
}

@Event struct PerformDeployFromSource {
    let actionId: UInt32
    let egldValue: BigUint
    let sourceAddress: Address
    let codeMetadata: CodeMetadata
    let gas: UInt64
    let arguments: MultiValueEncoded<Buffer>
}

@Event struct PerformUpgradeFromSource {
    let actionId: UInt32
    let targetAddress: Address
    let egldValue: BigUint
    let sourceAddress: Address
    let codeMetadata: CodeMetadata
    let gas: UInt64
    let arguments: MultiValueEncoded<Buffer>
}

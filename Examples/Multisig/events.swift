import SpaceKit

@Event(dataType: ActionFullInfo) public struct StartPerformAction {}

@Event public struct PerformChangeUser {
    let actionId: UInt32
    let changedUser: Address
    let oldRole: UserRole
    let newRole: UserRole
}

@Event public struct PerformChangeQuorum {
    let actionId: UInt32
    let newQuorum: UInt32
}

@Event public struct PerformTransferExecute {
    let actionId: UInt32
    let to: Address
    let egldValue: BigUint
    let gas: UInt64
    let endpoint: Buffer
    let arguments: MultiValueEncoded<Buffer>
}

@Event public struct PerformAsyncCall {
    let actionId: UInt32
    let to: Address
    let egldValue: BigUint
    let gas: UInt64
    let endpoint: Buffer
    let arguments: MultiValueEncoded<Buffer>
}

@Event public struct AsyncCallSuccess {
    let results: MultiValueEncoded<Buffer>
}

@Event public struct AsyncCallError {
    let errorCode: UInt32
    let errorMessage: Buffer
}

@Event public struct PerformDeployFromSource {
    let actionId: UInt32
    let egldValue: BigUint
    let sourceAddress: Address
    let codeMetadata: CodeMetadata
    let gas: UInt64
    let arguments: MultiValueEncoded<Buffer>
}

@Event public struct PerformUpgradeFromSource {
    let actionId: UInt32
    let targetAddress: Address
    let egldValue: BigUint
    let sourceAddress: Address
    let codeMetadata: CodeMetadata
    let gas: UInt64
    let arguments: MultiValueEncoded<Buffer>
}

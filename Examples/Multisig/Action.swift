import Space

@Codable public struct CallActionData {
    let to: Address
    let egldAmount: BigUint
    let endpointName: MXBuffer
    let arguments: MXArray<MXBuffer>
}

@Codable public struct DeployFromSourceActionData {
    let amount: BigUint
    let source: Address
    let codeMetadata: CodeMetadata
    let arguments: MXArray<MXBuffer>
}

@Codable public struct UpgradeFromSourceActionData {
    let scAddress: Address
    let amount: BigUint
    let source: Address
    let codeMetadata: CodeMetadata
    let arguments: MXArray<MXBuffer>
}

@Codable public enum Action {
    case nothing
    case addBoardMember(Address)
    case addProposer(Address)
    case removeUser(Address)
    case changeQuorum(UInt32)
    case sendTransferExecute(CallActionData)
    case sendAsyncCall(CallActionData)
    case scDeployFromSource(DeployFromSourceActionData)
    case scUpgradeFromSource(UpgradeFromSourceActionData)
}

extension Action {
    var isPending: Bool {
        if case .nothing = self {
            false
        } else {
            true
        }
    }
}

@Codable public struct ActionFullInfo {
    let actionId: UInt32
    let actionData: Action
    let signers: MXArray<Address>
}

import SpaceKit

@Codable public struct CurveArguments {
    var availableSupply: BigUint
    var balance: BigUint
}

extension CurveArguments {
    func getFirstTokenAvailable() -> BigUint {
        return self.availableSupply - self.balance
    }
}

@Codable public struct BondingCurve {
    var curve: FunctionSelector
    var arguments: CurveArguments
    var sellAvailability: Bool
    var payment: TokenPayment
}

extension BondingCurve {
    func requireIsSet() {
        require(
            self.curve != FunctionSelector(default: ()),
            "The token price was not set yet!"
        )
    }
}

@Codable public struct TokenOwnershipData {
    var tokenNonces: Vector<UInt64>
    let owner: Address
}

extension TokenOwnershipData {
    mutating func addNonce(nonce: UInt64) {
        if !self.tokenNonces.contains(nonce) {
            self.tokenNonces = self.tokenNonces.appended(nonce)
        }
    }
    
    mutating func removeNonce(nonce: UInt64) {
        let indexOfNonce = self.tokenNonces.index(of: nonce)
        
        if let indexOfNonce = indexOfNonce {
            self.tokenNonces = self.tokenNonces.removed(indexOfNonce)
        } else {
            smartContractError(message: "Nonce requested is not available")
        }
    }
}

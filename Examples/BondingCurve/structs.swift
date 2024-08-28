import Space

@Codable struct CurveArguments {
    var availableSupply: BigUint
    var balance: BigUint
}

extension CurveArguments {
    func getFirstTokenAvailable() -> BigUint {
        return self.availableSupply - self.balance
    }
}

@Codable struct BondingCurve<T: CurveFunction & MXCodable & Default & Equatable> {
    var curve: T
    var arguments: CurveArguments
    var sellAvailability: Bool
    var payment: TokenPayment
}

extension BondingCurve {
    func requireIsSet() {
        require(
            self.curve != T(default: ()),
            "The token price was not set yet!"
        )
    }
}

@Codable struct TokenOwnershipData {
    var tokenNonces: MXArray<UInt64>
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

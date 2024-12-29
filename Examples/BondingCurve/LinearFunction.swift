import SpaceKit

@Codable public struct LinearFunction: Equatable {
    let initialPrice: BigUint
    let linearCoefficient: BigUint
}

extension LinearFunction: CurveFunction {
    func calculatePrice(
        tokenStart: BigUint,
        amount: BigUint,
        arguments: CurveArguments
    ) -> BigUint {
        return self.linearCoefficient * sumInterval(n: amount, x: tokenStart) + self.initialPrice * amount
    }
}

fileprivate func sumInterval(n: BigUint, x: BigUint) -> BigUint {
    return x * n + (n - 1) * n / 2
}

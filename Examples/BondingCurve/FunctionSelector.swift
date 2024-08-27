import MultiversX

@Codable enum FunctionSelector: Equatable {
    case linear(LinearFunction)
    case customExample(BigUint)
    case none
}

extension FunctionSelector: Default {
    init(default: ()) {
        self = .none
    }
}

extension FunctionSelector: CurveFunction {
    func calculatePrice(
        tokenStart: BigUint,
        amount: BigUint,
        arguments: CurveArguments
    ) -> BigUint {
        switch self {
        case .linear(let linearFunction):
            return linearFunction.calculatePrice(
                tokenStart: tokenStart,
                amount: amount,
                arguments: arguments
            )
        case .customExample(let initialCost):
            let sum = tokenStart + amount
            return (sum * sum * sum / 3) + arguments.balance + initialCost
        case .none:
            smartContractError(message: "Bonding Curve function is not assiged")
        }
    }
}

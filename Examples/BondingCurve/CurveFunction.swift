import MultiversX

protocol CurveFunction {
    func calculatePrice(
        tokenStart: BigUint,
        amount: BigUint,
        arguments: CurveArguments
    ) -> BigUint
}

import SpaceKit

protocol CurveFunction {
    func calculatePrice(
        tokenStart: BigUint,
        amount: BigUint,
        arguments: CurveArguments
    ) -> BigUint
}

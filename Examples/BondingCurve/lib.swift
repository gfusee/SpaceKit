import Space

@Contract struct BondingCurveContract {
    public func sellToken() {
        UserEndpointsModule.sellToken(dummy: FunctionSelector.none)
    }
    
    public func buyToken(
        requestedAmount: BigUint,
        requestedToken: Buffer,
        requestedNonce: OptionalArgument<UInt64>
    ) {
        UserEndpointsModule.buyToken(
            requestedAmount: requestedAmount,
            requestedToken: requestedToken,
            requestedNonce: requestedNonce.intoOptional(),
            dummy: FunctionSelector.none
        )
    }
    
    public func deposit(paymentToken: OptionalArgument<Buffer>) {
        OwnerEndpointsModule.deposit(
            paymentToken: paymentToken.intoOptional(),
            dummy: FunctionSelector.none
        )
    }
    
    public func claim() {
        OwnerEndpointsModule.claim(
            dummy: FunctionSelector.none
        )
    }
    
    public func setBondingCurve(
        identifier: Buffer,
        function: FunctionSelector,
        sellAvailability: Bool
    ) {
        OwnerEndpointsModule.setBondingCurve(
            identifier: identifier,
            function: function,
            sellAvailability: sellAvailability
        )
    }
    
    public func getTokenAvailability(
        identifier: Buffer
    ) -> MultiValueEncoded<Buffer> {
        return UserEndpointsModule.getTokenAvailability(identifier: identifier)
    }
}

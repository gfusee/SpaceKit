import MultiversX

@Contract struct BondingCurveContract {
    public func sellToken() {
        UserEndpointsModule.sellToken(dummy: FunctionSelector.none)
    }
    
    public func buyToken(
        requestedAmount: BigUint,
        requestedToken: MXBuffer,
        requestedNonce: OptionalArgument<UInt64>
    ) {
        UserEndpointsModule.buyToken(
            requestedAmount: requestedAmount,
            requestedToken: requestedToken,
            requestedNonce: requestedNonce.intoOptional(),
            dummy: FunctionSelector.none
        )
    }
    
    public func deposit(paymentToken: OptionalArgument<MXBuffer>) {
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
        identifier: MXBuffer,
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
        identifier: MXBuffer
    ) -> MultiValueEncoded<MXBuffer> {
        return UserEndpointsModule.getTokenAvailability(identifier: identifier)
    }
}

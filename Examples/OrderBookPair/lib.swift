import MultiversX

@Contract struct Pair {
    // TODO: use TokenIdentifier when available
    init(
        firstTokenIdentifier: MXBuffer,
        secondTokenIdentifier: MXBuffer
    ) {
        StorageModule.firstTokenIdentifier = firstTokenIdentifier
        StorageModule.secondTokenIdentifier = secondTokenIdentifier
    }
    
    public func createBuyOrder(params: OrderInputParams) {
        GlobalOperationModule.requireGlobalOperationNotOngoing()
        ValidationModule.requireValidOrderInputParams(params: params)
        
        let payment = ValidationModule.requireValidBuyPayment()
        
        OrdersModule.createOrder(
            payment: payment,
            params: params,
            orderType: .buy
        )
    }
}

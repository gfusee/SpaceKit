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
    
    public func createSellOrder(params: OrderInputParams) {
        GlobalOperationModule.requireGlobalOperationNotOngoing()
        ValidationModule.requireValidOrderInputParams(params: params)
        
        let payment = ValidationModule.requireValidSellPayment()
        
        OrdersModule.createOrder(
            payment: payment,
            params: params,
            orderType: .sell
        )
    }
    
    public func matchOrders(orderIds: MXArray<UInt64>) {
        GlobalOperationModule.requireGlobalOperationNotOngoing()
        ValidationModule.requireValidMatchInputOrderIds(orderIds: orderIds)
        
        OrdersModule.matchOrders(orderIds: orderIds)
    }
}

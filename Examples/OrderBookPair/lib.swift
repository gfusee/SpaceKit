import Space

@Contract struct Pair {
    // TODO: use TokenIdentifier when available
    init(
        firstTokenIdentifier: Buffer,
        secondTokenIdentifier: Buffer
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
    
    public func cancelOrders(orderIds: MultiValueEncoded<UInt64>) {
        let orderIds = orderIds.toArray()
        
        GlobalOperationModule.requireGlobalOperationNotOngoing()
        ValidationModule.requireOrderIdsNotEmpty(orderIds: orderIds)
        
        OrdersModule.cancelOrders(orderIds: orderIds)
    }
    
    public func cancelAllOrders() {
        GlobalOperationModule.requireGlobalOperationNotOngoing()
        
        OrdersModule.cancelAllOrders()
    }
    
    public func freeOrders(orderIds: MultiValueEncoded<UInt64>) {
        let orderIds = orderIds.toArray()
        
        GlobalOperationModule.requireGlobalOperationNotOngoing()
        ValidationModule.requireOrderIdsNotEmpty(orderIds: orderIds)
        
        OrdersModule.freeOrders(orderIds: orderIds)
    }
    
    public func getAddressOrderIds(address: Address) -> MultiValueEncoded<UInt64> {
        return MultiValueEncoded(items: OrdersModule.getAddressOrderIds(address: address))
    }
    
    public func getOrderById(id: UInt64) -> Order {
        return StorageModule.orderForId[id]
    }
}

import SpaceKit

// TODO: use TokenIdentifier when available
@Init func initialize(
    firstTokenIdentifier: Buffer,
    secondTokenIdentifier: Buffer
) {
    var storageController = StorageModule()
    
    storageController.firstTokenIdentifier = firstTokenIdentifier
    storageController.secondTokenIdentifier = secondTokenIdentifier
}

@Controller struct PairController {
    public func createBuyOrder(params: OrderInputParams) {
        let globalOperationModule = GlobalOperationModule()
        
        globalOperationModule.requireGlobalOperationNotOngoing()
        ValidationModule.requireValidOrderInputParams(params: params)
        
        let payment = ValidationModule.requireValidBuyPayment()
        
        OrdersModule.createOrder(
            payment: payment,
            params: params,
            orderType: .buy
        )
    }
    
    public func createSellOrder(params: OrderInputParams) {
        let globalOperationModule = GlobalOperationModule()
        
        globalOperationModule.requireGlobalOperationNotOngoing()
        ValidationModule.requireValidOrderInputParams(params: params)
        
        let payment = ValidationModule.requireValidSellPayment()
        
        OrdersModule.createOrder(
            payment: payment,
            params: params,
            orderType: .sell
        )
    }
    
    public func matchOrders(orderIds: Vector<UInt64>) {
        let globalOperationModule = GlobalOperationModule()
        
        globalOperationModule.requireGlobalOperationNotOngoing()
        ValidationModule.requireValidMatchInputOrderIds(orderIds: orderIds)
        
        OrdersModule.matchOrders(orderIds: orderIds)
    }
    
    public func cancelOrders(orderIds: MultiValueEncoded<UInt64>) {
        let globalOperationModule = GlobalOperationModule()
        
        let orderIds = orderIds.toArray()
        
        globalOperationModule.requireGlobalOperationNotOngoing()
        ValidationModule.requireOrderIdsNotEmpty(orderIds: orderIds)
        
        OrdersModule.cancelOrders(orderIds: orderIds)
    }
    
    public func cancelAllOrders() {
        let globalOperationModule = GlobalOperationModule()
        
        globalOperationModule.requireGlobalOperationNotOngoing()
        
        OrdersModule.cancelAllOrders()
    }
    
    public func freeOrders(orderIds: MultiValueEncoded<UInt64>) {
        let globalOperationModule = GlobalOperationModule()
        
        let orderIds = orderIds.toArray()
        
        globalOperationModule.requireGlobalOperationNotOngoing()
        ValidationModule.requireOrderIdsNotEmpty(orderIds: orderIds)
        
        OrdersModule.freeOrders(orderIds: orderIds)
    }
    
    public func getAddressOrderIds(address: Address) -> MultiValueEncoded<UInt64> {
        return MultiValueEncoded(items: OrdersModule.getAddressOrderIds(address: address))
    }
    
    public func getOrderById(id: UInt64) -> Order {
        let storageModule = StorageModule()
        
        return storageModule.orderForId[id]
    }
}

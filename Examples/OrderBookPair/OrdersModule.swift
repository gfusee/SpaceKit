import MultiversX

struct OrdersModule {
    static func createOrder(
        payment: Payment,
        params: OrderInputParams,
        orderType: OrderType
    ) {
        let caller = Message.caller
        
        let addressOrdersIds = OrdersModule.getAddressOrderIds(address: caller)
        ValidationModule.requireNotMaxSize(addressOrderIds: addressOrdersIds)
        
        let newOrderId = self.getAndIncreaseOrderIdCounter()
        let order = CommonModule.newOrder(
            id: newOrderId,
            payment: payment,
            params: params,
            orderType: orderType
        )
        StorageModule.orderForId[order.id] = order
        
        let addressOrders = MXArray(singleItem: order.id)
        StorageModule.orderIdsForAddress[caller] = addressOrders
        
        EventsModule.emitOrderEvent(order: order)
    }
    
    static func getAndIncreaseOrderIdCounter() -> UInt64 {
        let orderIdCounterMapper = StorageModule.$orderIdCounter
        let id = orderIdCounterMapper.get()
        orderIdCounterMapper.set(id + 1)
        
        return id
    }
    
    static func getAddressOrderIds(address: Address) -> MXArray<UInt64> {
        var ordersArray: MXArray<UInt64> = MXArray()
        
        StorageModule.orderIdsForAddress[address].forEach { order in
            if !StorageModule.$orderForId[order].isEmpty() {
                ordersArray = ordersArray.appended(order)
            }
        }
        
        return ordersArray
    }
}

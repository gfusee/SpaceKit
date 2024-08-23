import MultiversX

@Event(dataType: Order) struct OrderEvent {
    let caller: Address
    let epoch: UInt64
    let orderType: OrderType
}

// TODO: Using IgnoreValue where the event doesn't have any data is not intuitive
@Event(dataType: IgnoreValue) struct MatchOrderEvent {
    let caller: Address
    let epoch: UInt64
    let orderType: OrderType
    let orderId: UInt64
    let orderCreator: Address
}

struct EventsModule {
    static func emitOrderEvent(order: Order) {
        OrderEvent(
            caller: Message.caller,
            epoch: Blockchain.getBlockEpoch(),
            orderType: order.orderType
        ).emit(data: order)
    }
    
    static func emitMatchOrderEvents(orders: MXArray<Order>) {
        let caller = Message.caller
        let epoch = Blockchain.getBlockEpoch()
        
        orders.forEach { order in
            MatchOrderEvent(
                caller: caller,
                epoch: epoch,
                orderType: order.orderType,
                orderId: order.id,
                orderCreator: order.creator
            ).emit(data: IgnoreValue())
        }
    }
}

import Space

@Event(dataType: Order) struct OrderEvent {
    let caller: Address
    let epoch: UInt64
    let orderType: OrderType
}

@Event struct MatchOrderEvent {
    let caller: Address
    let epoch: UInt64
    let orderType: OrderType
    let orderId: UInt64
    let orderCreator: Address
}

@Event struct FreeOrderEvent {
    let caller: Address
    let epoch: UInt64
    let orderType: OrderType
    let orderId: UInt64
    let orderCreator: Address
}

@Event struct CancelOrderEvent {
    let caller: Address
    let epoch: UInt64
    let orderType: OrderType
    let orderId: UInt64
}

struct EventsModule {
    static func emitOrderEvent(order: Order) {
        OrderEvent(
            caller: Message.caller,
            epoch: Blockchain.getBlockEpoch(),
            orderType: order.orderType
        ).emit(data: order)
    }
    
    static func emitMatchOrderEvents(orders: Vector<Order>) {
        let caller = Message.caller
        let epoch = Blockchain.getBlockEpoch()
        
        orders.forEach { order in
            MatchOrderEvent(
                caller: caller,
                epoch: epoch,
                orderType: order.orderType,
                orderId: order.id,
                orderCreator: order.creator
            ).emit()
        }
    }
    
    static func emitFreeOrderEvents(orders: Vector<Order>) {
        let caller = Message.caller
        let epoch = Blockchain.getBlockEpoch()
        
        orders.forEach { order in
            FreeOrderEvent(
                caller: caller,
                epoch: epoch,
                orderType: order.orderType,
                orderId: order.id,
                orderCreator: order.creator
            ).emit()
        }
    }
    
    static func emitCancelOrderEvents(orders: Vector<Order>) {
        let caller = Message.caller
        let epoch = Blockchain.getBlockEpoch()
        
        orders.forEach { order in
            CancelOrderEvent(
                caller: caller,
                epoch: epoch,
                orderType: order.orderType,
                orderId: order.id
            ).emit()
        }
    }
}

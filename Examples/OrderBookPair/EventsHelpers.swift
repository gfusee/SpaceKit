import SpaceKit

@Event(dataType: Order) public struct OrderEvent {
    let caller: Address
    let epoch: UInt64
    let orderType: OrderType
}

@Event public struct MatchOrderEvent {
    let caller: Address
    let epoch: UInt64
    let orderType: OrderType
    let orderId: UInt64
    let orderCreator: Address
}

@Event public struct FreeOrderEvent {
    let caller: Address
    let epoch: UInt64
    let orderType: OrderType
    let orderId: UInt64
    let orderCreator: Address
}

@Event public struct CancelOrderEvent {
    let caller: Address
    let epoch: UInt64
    let orderType: OrderType
    let orderId: UInt64
}

struct EventsHelpers {
    func emitOrderEvent(order: Order) {
        OrderEvent(
            caller: Message.caller,
            epoch: Blockchain.getBlockEpoch(),
            orderType: order.orderType
        ).emit(data: order)
    }
    
    func emitMatchOrderEvents(orders: Vector<Order>) {
        let caller = Message.caller
        let epoch = Blockchain.getBlockEpoch()
        
        for order in orders {
            MatchOrderEvent(
                caller: caller,
                epoch: epoch,
                orderType: order.orderType,
                orderId: order.id,
                orderCreator: order.creator
            ).emit()
        }
    }
    
    func emitFreeOrderEvents(orders: Vector<Order>) {
        let caller = Message.caller
        let epoch = Blockchain.getBlockEpoch()
        
        for order in orders {
            FreeOrderEvent(
                caller: caller,
                epoch: epoch,
                orderType: order.orderType,
                orderId: order.id,
                orderCreator: order.creator
            ).emit()
        }
    }
    
    func emitCancelOrderEvents(orders: Vector<Order>) {
        let caller = Message.caller
        let epoch = Blockchain.getBlockEpoch()
        
        for order in orders {
            CancelOrderEvent(
                caller: caller,
                epoch: epoch,
                orderType: order.orderType,
                orderId: order.id
            ).emit()
        }
    }
}

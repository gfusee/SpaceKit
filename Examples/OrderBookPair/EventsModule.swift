import MultiversX

@Event(dataType: Order) struct OrderEvent {
    let caller: Address
    let epoch: UInt64
    let orderType: OrderType
}

struct EventsModule {
    static func emitOrderEvent(order: Order) {
        OrderEvent(
            caller: Message.caller,
            epoch: Blockchain.getBlockEpoch(),
            orderType: order.orderType
        ).emit(data: order)
    }
}

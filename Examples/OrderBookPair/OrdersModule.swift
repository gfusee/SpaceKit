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
    
    static func matchOrders(orderIds: MXArray<UInt64>) {
        let orders = OrdersModule.loadOrders(orderIds: orderIds)
        
        require(
            orders.count == orderIds.count,
            "Order vectors len mismatch"
        )
        
        ValidationModule.requireMatchProviderEmptyOrCaller(orders: orders)
        
        let transfers = OrdersModule.createTransfers(orders: orders)
        OrdersModule.clearOrders(orderIds: orderIds)
        OrdersModule.executeTransfers(transfers: transfers)
        
        EventsModule.emitMatchOrderEvents(orders: orders)
    }
    
    static func loadOrders(orderIds: MXArray<UInt64>) -> MXArray<Order> {
        var ordersArray: MXArray<Order> = MXArray()
        
        orderIds.forEach { orderId in
            let orderMapper = StorageModule.$orderForId[orderId]
            
            if !orderMapper.isEmpty() {
                ordersArray = ordersArray.appended(orderMapper.get())
            }
        }
        
        return ordersArray
    }
    
    static func createTransfers(orders: MXArray<Order>) -> MXArray<Transfer> {
        var transfers: MXArray<Transfer> = MXArray()
        let firstTokenIdentifier = StorageModule.firstTokenIdentifier
        let secondTokenIdentifier = StorageModule.secondTokenIdentifier
        
        let buyOrders = self.getOrdersWithType(
            orders: orders,
            orderType: .buy
        )
        let sellOrders = self.getOrdersWithType(
            orders: orders,
            orderType: .sell
        )
        
        let (secondTokenPaid, firstTokenRequested) = OrdersModule.getOrdersSumUp(orders: buyOrders)
        let (firstTokenPaid, secondTokenRequested) = OrdersModule.getOrdersSumUp(orders: sellOrders)
        
        require(
            firstTokenPaid >= firstTokenRequested,
            "Orders mismatch: Not enough first Token"
        )
        
        require(
            secondTokenPaid >= secondTokenRequested,
            "Orders mismatch: Not enough second Token"
        )
        
        let firstTokenLeftover = firstTokenPaid - firstTokenRequested
        let secondTokenLeftover = secondTokenPaid - secondTokenRequested
        
        let buyersTransfers = OrdersModule.calculateTransfers(
            orders: buyOrders,
            totalPaid: secondTokenPaid,
            tokenRequested: firstTokenIdentifier,
            leftover: firstTokenLeftover
        )
        transfers = transfers.appended(contentsOf: buyersTransfers)
        
        let sellersTransfers = OrdersModule.calculateTransfers(
            orders: sellOrders,
            totalPaid: firstTokenPaid,
            tokenRequested: secondTokenIdentifier,
            leftover: secondTokenLeftover
        )
        transfers = transfers.appended(contentsOf: sellersTransfers)
        
        return transfers
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
    
    static func getOrdersWithType(
        orders: MXArray<Order>,
        orderType: OrderType
    ) -> MXArray<Order> {
        var result: MXArray<Order> = MXArray()
        
        orders.forEach { order in
            if order.orderType == orderType {
                result = result.appended(order)
            }
        }
        
        return result
    }
    
    static func getOrdersSumUp(
        orders: MXArray<Order>
    ) -> (amountPaid: BigUint, amountRequested: BigUint) {
        var amountPaid: BigUint = 0
        var amountRequest: BigUint = 0
        
        orders.forEach { order in
            amountPaid = amountPaid + order.inputAmount
            amountRequest = amountRequest + order.outputAmount
        }
        
        return (amountPaid: amountPaid, amountRequested: amountRequest)
    }
    
    
    // TODO: use the TokenIdentifier type once available
    static func calculateTransfers(
        orders: MXArray<Order>,
        totalPaid: BigUint,
        tokenRequested: MXBuffer,
        leftover: BigUint
    ) -> MXArray<Transfer> {
        var transfers: MXArray<Transfer> = MXArray()
        
        var matchProviderTransfer = Transfer(
            to: Message.caller,
            payment: Payment(
                tokenIdentifier: tokenRequested,
                amount: 0
            )
        )
        
        orders.forEach { order in
            let matchProviderAmount = CommonModule.calculateFeeAmount(
                amount: order.outputAmount,
                feeConfig: order.feeConfig
            )
            let creatorAmount = order.outputAmount - matchProviderAmount
            
            let orderDeal = CommonModule.ruleOfThree(
                part: order.inputAmount,
                total: totalPaid,
                value: leftover
            )
            let matchProviderDealAmount = CommonModule.ruleOfThree(
                part: BigUint(value: order.dealConfig.matchProviderPercent),
                total: BigUint(value: PERCENT_BASE_POINTS),
                value: orderDeal
            )
            let creatorDealAmount = orderDeal - matchProviderDealAmount
            
            transfers = transfers.appended(
                Transfer(
                    to: order.creator,
                    payment: Payment(
                        tokenIdentifier: tokenRequested,
                        amount: creatorAmount
                    )
                )
            )
            
            matchProviderTransfer.payment.amount = matchProviderTransfer.payment.amount + matchProviderAmount + matchProviderDealAmount
        }
        
        transfers = transfers.appended(matchProviderTransfer)
        
        return transfers
    }
    
    static func executeTransfers(transfers: MXArray<Transfer>) {
        transfers.forEach { transfer in
            if transfer.payment.amount > 0 {
                transfer.to.send(
                    tokenIdentifier: transfer.payment.tokenIdentifier,
                    nonce: 0,
                    amount: transfer.payment.amount
                )
            }
        }
    }
    
    static func clearOrders(orderIds: MXArray<UInt64>) {
        orderIds.forEach { orderId in
            StorageModule.$orderForId[orderId].clear()
        }
    }
}

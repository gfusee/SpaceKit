import Space

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
        var storageModule = StorageModule()
        storageModule.orderForId[order.id] = order
        
        let addressOrders = Vector(singleItem: order.id)
        storageModule.orderIdsForAddress[caller] = addressOrders
        
        EventsModule.emitOrderEvent(order: order)
    }
    
    static func matchOrders(orderIds: Vector<UInt64>) {
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
    
    static func freeOrders(orderIds: Vector<UInt64>) {
        let caller = Message.caller
        let addressOrderIds = OrdersModule.getAddressOrderIds(address: caller)
        
        ValidationModule.requireContainsNone(baseArray: addressOrderIds, items: orderIds)
        
        let storageModule = StorageModule()
        let firstTokenIdentifier = storageModule.firstTokenIdentifier
        let secondTokenIdentifier = storageModule.secondTokenIdentifier
        let epoch = Blockchain.getBlockEpoch()
        
        var orderIdsNotEmpty: Vector<UInt64> = Vector()
        orderIds.forEach { orderId in
            if !storageModule.$orderForId[orderId].isEmpty() {
                orderIdsNotEmpty = orderIdsNotEmpty.appended(orderId)
            }
        }
        
        var orders: Vector<Order> = Vector()
        orderIdsNotEmpty.forEach { orderId in
            let order = OrdersModule.freeOrder(
                orderId: orderId,
                caller: caller,
                firstTokenIdentifier: firstTokenIdentifier,
                secondTokenIdentifier: secondTokenIdentifier,
                epoch: epoch
            )
            orders = orders.appended(order)
        }
        
        EventsModule.emitFreeOrderEvents(orders: orders)
    }
    
    static func cancelAllOrders() {
        let caller = Message.caller
        let addressOrderIds = OrdersModule.getAddressOrderIds(address: caller)
        
        var orderIdsNotEmpty: Vector<UInt64> = Vector()
        let storageModule = StorageModule()
        addressOrderIds.forEach { orderId in
            if !storageModule.$orderForId[orderId].isEmpty() {
                orderIdsNotEmpty = orderIdsNotEmpty.appended(orderId)
            }
        }
        
        self.cancelOrders(orderIds: orderIdsNotEmpty)
    }
    
    static func freeOrder(
        orderId: UInt64,
        caller: Address,
        firstTokenIdentifier: Buffer,
        secondTokenIdentifier: Buffer,
        epoch: UInt64
    ) -> Order {
        let storageModule = StorageModule()
        let orderMapper = storageModule.$orderForId[orderId]
        let order = orderMapper.get()
        
        let tokenIdentifier = switch order.orderType {
        case .buy:
            secondTokenIdentifier
        case .sell:
            firstTokenIdentifier
        }
        
        let penaltyCount = (BigUint(value: epoch) - BigUint(value: order.createEpoch)) / BigUint(value: FEE_PENALTY_INCREASE_EPOCH)
        
        require(
            penaltyCount >= BigUint(value: FREE_ORDER_FROM_STORAGE_MIN_PENALTIES),
            "Too early to free order"
        )
        
        let penaltyPercent = penaltyCount * BigUint(value: FEE_PENALTY_INCREASE_PERCENT)
        let penaltyAmount = CommonModule.ruleOfThree(
            part: penaltyPercent,
            total: BigUint(value: PERCENT_BASE_POINTS),
            value: order.inputAmount
        )
        let amount = order.inputAmount - penaltyAmount
        
        let creatorTransfer = Transfer(
            to: order.creator,
            payment: Payment(
                tokenIdentifier: tokenIdentifier,
                amount: amount
            )
        )
        let callerTransfer = Transfer(
            to: caller,
            payment: Payment(
                tokenIdentifier: tokenIdentifier,
                amount: penaltyAmount
            )
        )
        
        orderMapper.clear()
        var transfers = Vector(singleItem: creatorTransfer)
        transfers = transfers.appended(callerTransfer)
        OrdersModule.executeTransfers(transfers: transfers)
        
        return order
    }
    
    static func cancelOrders(orderIds: Vector<UInt64>) {
        let caller = Message.caller
        let addressOrderIds = OrdersModule.getAddressOrderIds(address: caller)
        ValidationModule.requireContainsAll(
            baseArray: addressOrderIds,
            items: orderIds
        )
        
        var storageModule = StorageModule()
        let firstTokenIdentifier = storageModule.firstTokenIdentifier
        let secondTokenIdentifier = storageModule.secondTokenIdentifier
        let epoch = Blockchain.getBlockEpoch()
        
        var orderIdsNotEmpty: Vector<UInt64> = Vector()
        orderIds.forEach { orderId in
            if !storageModule.$orderForId[orderId].isEmpty() {
                orderIdsNotEmpty = orderIdsNotEmpty.appended(orderId)
            }
        }
        
        var orders: Vector<Order> = Vector()
        var finalCallerOrders: Vector<UInt64> = Vector()
        
        let addressOrderIdsCount = addressOrderIds.count
        
        orderIdsNotEmpty.forEach { orderId in
            let order = OrdersModule.cancelOrder(
                orderId: orderId,
                caller: caller,
                firstTokenIdentifier: firstTokenIdentifier,
                secondTokenIdentifier: secondTokenIdentifier,
                epoch: epoch
            )
            
            var checkOrderToDelete = false
            for checkOrderIdIndex in 0..<addressOrderIdsCount {
                let checkOrderId = addressOrderIds[checkOrderIdIndex]
                
                if checkOrderId == orderId {
                    checkOrderToDelete = true
                    break
                }
            }
            
            if !checkOrderToDelete {
                finalCallerOrders = finalCallerOrders.appended(orderId)
            }
            
            orders = orders.appended(order)
        }
        
        storageModule.orderIdsForAddress[caller] = finalCallerOrders
        EventsModule.emitCancelOrderEvents(orders: orders)
    }
    
    static func loadOrders(orderIds: Vector<UInt64>) -> Vector<Order> {
        var ordersArray: Vector<Order> = Vector()
        let storageModule = StorageModule()
        
        orderIds.forEach { orderId in
            let orderMapper = storageModule.$orderForId[orderId]
            
            if !orderMapper.isEmpty() {
                ordersArray = ordersArray.appended(orderMapper.get())
            }
        }
        
        return ordersArray
    }
    
    static func cancelOrder(
        orderId: UInt64,
        caller: Address,
        firstTokenIdentifier: Buffer,
        secondTokenIdentifier: Buffer,
        epoch: UInt64
    ) -> Order {
        let storageModule = StorageModule()
        let orderMapper = storageModule.$orderForId[orderId]
        let order = orderMapper.get()
        
        let tokenIdentifier = switch order.orderType {
        case .buy:
            secondTokenIdentifier
        case .sell:
            firstTokenIdentifier
        }
        
        let penaltyCount = (BigUint(value: epoch) - BigUint(value: order.createEpoch)) / BigUint(value: FEE_PENALTY_INCREASE_EPOCH)
        let penaltyPercent = penaltyCount * BigUint(value: FEE_PENALTY_INCREASE_PERCENT)
        let penaltyAmount = CommonModule.ruleOfThree(
            part: penaltyPercent,
            total: BigUint(value: PERCENT_BASE_POINTS),
            value: order.inputAmount
        )
        let amount = order.inputAmount - penaltyAmount
        
        let transfer = Transfer(
            to: caller,
            payment: Payment(
                tokenIdentifier: tokenIdentifier,
                amount: amount
            )
        )
        
        orderMapper.clear()
        let transfers = Vector(singleItem: transfer)
        OrdersModule.executeTransfers(transfers: transfers)
        
        return order
    }
    
    static func createTransfers(orders: Vector<Order>) -> Vector<Transfer> {
        var transfers: Vector<Transfer> = Vector()
        let storageModule = StorageModule()
        let firstTokenIdentifier = storageModule.firstTokenIdentifier
        let secondTokenIdentifier = storageModule.secondTokenIdentifier
        
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
        let storageModule = StorageModule()
        let orderIdCounterMapper = storageModule.$orderIdCounter
        let id = orderIdCounterMapper.get()
        orderIdCounterMapper.set(id + 1)
        
        return id
    }
    
    static func getAddressOrderIds(address: Address) -> Vector<UInt64> {
        var ordersArray: Vector<UInt64> = Vector()
        let storageModule = StorageModule()
        
        storageModule.orderIdsForAddress[address].forEach { order in
            if !storageModule.$orderForId[order].isEmpty() {
                ordersArray = ordersArray.appended(order)
            }
        }
        
        return ordersArray
    }
    
    static func getOrdersWithType(
        orders: Vector<Order>,
        orderType: OrderType
    ) -> Vector<Order> {
        var result: Vector<Order> = Vector()
        
        orders.forEach { order in
            if order.orderType == orderType {
                result = result.appended(order)
            }
        }
        
        return result
    }
    
    static func getOrdersSumUp(
        orders: Vector<Order>
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
        orders: Vector<Order>,
        totalPaid: BigUint,
        tokenRequested: Buffer,
        leftover: BigUint
    ) -> Vector<Transfer> {
        var transfers: Vector<Transfer> = Vector()
        
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
                        amount: creatorAmount + creatorDealAmount
                    )
                )
            )
            
            matchProviderTransfer.payment.amount = matchProviderTransfer.payment.amount + matchProviderAmount + matchProviderDealAmount
        }
        
        transfers = transfers.appended(matchProviderTransfer)
        
        return transfers
    }
    
    static func executeTransfers(transfers: Vector<Transfer>) {
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
    
    static func clearOrders(orderIds: Vector<UInt64>) {
        let storageModule = StorageModule()
        orderIds.forEach { orderId in
            storageModule.$orderForId[orderId].clear()
        }
    }
}

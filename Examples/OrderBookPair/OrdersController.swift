import SpaceKit

@Controller public struct OrdersController {
    public func createBuyOrder(params: OrderInputParams) {
        GlobalOperationHelpers().requireGlobalOperationNotOngoing()
        ValidationHelpers().requireValidOrderInputParams(params: params)
        
        let payment = ValidationHelpers().requireValidBuyPayment()
        
        self.doCreateOrder(
            payment: payment,
            params: params,
            orderType: .buy
        )
    }
    
    public func createSellOrder(params: OrderInputParams) {
        GlobalOperationHelpers().requireGlobalOperationNotOngoing()
        ValidationHelpers().requireValidOrderInputParams(params: params)
        
        let payment = ValidationHelpers().requireValidSellPayment()
        
        self.doCreateOrder(
            payment: payment,
            params: params,
            orderType: .sell
        )
    }
    
    public func matchOrders(orderIds: Vector<UInt64>) {
        GlobalOperationHelpers().requireGlobalOperationNotOngoing()
        ValidationHelpers().requireValidMatchInputOrderIds(orderIds: orderIds)
        
        self.doMatchOrders(orderIds: orderIds)
    }
    
    public func cancelOrders(orderIds: MultiValueEncoded<UInt64>) {
        let orderIds = orderIds.toArray()
        
        GlobalOperationHelpers().requireGlobalOperationNotOngoing()
        ValidationHelpers().requireOrderIdsNotEmpty(orderIds: orderIds)
        
        self.doCancelOrders(orderIds: orderIds)
    }
    
    public func cancelAllOrders() {
        GlobalOperationHelpers().requireGlobalOperationNotOngoing()
        
        self.doCancelAllOrders()
    }
    
    public func freeOrders(orderIds: MultiValueEncoded<UInt64>) {
        let orderIds = orderIds.toArray()
        
        GlobalOperationHelpers().requireGlobalOperationNotOngoing()
        ValidationHelpers().requireOrderIdsNotEmpty(orderIds: orderIds)
        
        self.doFreeOrders(orderIds: orderIds)
    }
    
    public func getAddressOrderIds(address: Address) -> MultiValueEncoded<UInt64> {
        return MultiValueEncoded(items: self.getAddressOrderIdsVector(address: address))
    }
    
    private func doCreateOrder(
        payment: Payment,
        params: OrderInputParams,
        orderType: OrderType
    ) {
        let caller = Message.caller
        
        let addressOrdersIds = self.getAddressOrderIdsVector(address: caller)
        ValidationHelpers().requireNotMaxSize(addressOrderIds: addressOrdersIds)
        
        let newOrderId = self.getAndIncreaseOrderIdCounter()
        let order = CommonHelpers().newOrder(
            id: newOrderId,
            payment: payment,
            params: params,
            orderType: orderType
        )
        var storageController = StorageController()
        storageController.orderForId[order.id] = order
        
        let addressOrders = Vector(singleItem: order.id)
        storageController.orderIdsForAddress[caller] = addressOrders
        
        EventsHelpers().emitOrderEvent(order: order)
    }
    
    private func doMatchOrders(orderIds: Vector<UInt64>) {
        let orders = self.loadOrders(orderIds: orderIds)
        
        require(
            orders.count == orderIds.count,
            "Order vectors len mismatch"
        )
        
        ValidationHelpers().requireMatchProviderEmptyOrCaller(orders: orders)
        
        let transfers = self.createTransfers(orders: orders)
        self.clearOrders(orderIds: orderIds)
        self.executeTransfers(transfers: transfers)
        
        EventsHelpers().emitMatchOrderEvents(orders: orders)
    }
    
    private func doFreeOrders(orderIds: Vector<UInt64>) {
        let caller = Message.caller
        let addressOrderIds = self.getAddressOrderIdsVector(address: caller)
        
        ValidationHelpers().requireContainsNone(baseArray: addressOrderIds, items: orderIds)
        
        let storageController = StorageController()
        let firstTokenIdentifier = storageController.firstTokenIdentifier
        let secondTokenIdentifier = storageController.secondTokenIdentifier
        let epoch = Blockchain.getBlockEpoch()
        
        var orderIdsNotEmpty: Vector<UInt64> = Vector()
        orderIds.forEach { orderId in
            if !storageController.$orderForId[orderId].isEmpty() {
                orderIdsNotEmpty = orderIdsNotEmpty.appended(orderId)
            }
        }
        
        var orders: Vector<Order> = Vector()
        orderIdsNotEmpty.forEach { orderId in
            let order = self.freeOrder(
                orderId: orderId,
                caller: caller,
                firstTokenIdentifier: firstTokenIdentifier,
                secondTokenIdentifier: secondTokenIdentifier,
                epoch: epoch
            )
            orders = orders.appended(order)
        }
        
        EventsHelpers().emitFreeOrderEvents(orders: orders)
    }
    
    private func doCancelAllOrders() {
        let caller = Message.caller
        let addressOrderIds = self.getAddressOrderIdsVector(address: caller)
        
        var orderIdsNotEmpty: Vector<UInt64> = Vector()
        let storageController = StorageController()
        addressOrderIds.forEach { orderId in
            if !storageController.$orderForId[orderId].isEmpty() {
                orderIdsNotEmpty = orderIdsNotEmpty.appended(orderId)
            }
        }
        
        self.doCancelOrders(orderIds: orderIdsNotEmpty)
    }
    
    private func freeOrder(
        orderId: UInt64,
        caller: Address,
        firstTokenIdentifier: Buffer,
        secondTokenIdentifier: Buffer,
        epoch: UInt64
    ) -> Order {
        let storageController = StorageController()
        let orderMapper = storageController.$orderForId[orderId]
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
        let penaltyAmount = CommonHelpers().ruleOfThree(
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
        self.executeTransfers(transfers: transfers)
        
        return order
    }
    
    private func doCancelOrders(orderIds: Vector<UInt64>) {
        let caller = Message.caller
        let addressOrderIds = self.getAddressOrderIdsVector(address: caller)
        ValidationHelpers().requireContainsAll(
            baseArray: addressOrderIds,
            items: orderIds
        )
        
        var storageController = StorageController()
        let firstTokenIdentifier = storageController.firstTokenIdentifier
        let secondTokenIdentifier = storageController.secondTokenIdentifier
        let epoch = Blockchain.getBlockEpoch()
        
        var orderIdsNotEmpty: Vector<UInt64> = Vector()
        orderIds.forEach { orderId in
            if !storageController.$orderForId[orderId].isEmpty() {
                orderIdsNotEmpty = orderIdsNotEmpty.appended(orderId)
            }
        }
        
        var orders: Vector<Order> = Vector()
        var finalCallerOrders: Vector<UInt64> = Vector()
        
        let addressOrderIdsCount = addressOrderIds.count
        
        orderIdsNotEmpty.forEach { orderId in
            let order = self.cancelOrder(
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
        
        storageController.orderIdsForAddress[caller] = finalCallerOrders
        EventsHelpers().emitCancelOrderEvents(orders: orders)
    }
    
    private func loadOrders(orderIds: Vector<UInt64>) -> Vector<Order> {
        var ordersArray: Vector<Order> = Vector()
        let storageController = StorageController()
        
        orderIds.forEach { orderId in
            let orderMapper = storageController.$orderForId[orderId]
            
            if !orderMapper.isEmpty() {
                ordersArray = ordersArray.appended(orderMapper.get())
            }
        }
        
        return ordersArray
    }
    
    private func cancelOrder(
        orderId: UInt64,
        caller: Address,
        firstTokenIdentifier: Buffer,
        secondTokenIdentifier: Buffer,
        epoch: UInt64
    ) -> Order {
        let storageController = StorageController()
        let orderMapper = storageController.$orderForId[orderId]
        let order = orderMapper.get()
        
        let tokenIdentifier = switch order.orderType {
        case .buy:
            secondTokenIdentifier
        case .sell:
            firstTokenIdentifier
        }
        
        let penaltyCount = (BigUint(value: epoch) - BigUint(value: order.createEpoch)) / BigUint(value: FEE_PENALTY_INCREASE_EPOCH)
        let penaltyPercent = penaltyCount * BigUint(value: FEE_PENALTY_INCREASE_PERCENT)
        let penaltyAmount = CommonHelpers().ruleOfThree(
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
        self.executeTransfers(transfers: transfers)
        
        return order
    }
    
    private func createTransfers(orders: Vector<Order>) -> Vector<Transfer> {
        var transfers: Vector<Transfer> = Vector()
        let storageController = StorageController()
        let firstTokenIdentifier = storageController.firstTokenIdentifier
        let secondTokenIdentifier = storageController.secondTokenIdentifier
        
        let buyOrders = self.getOrdersWithType(
            orders: orders,
            orderType: .buy
        )
        let sellOrders = self.getOrdersWithType(
            orders: orders,
            orderType: .sell
        )
        
        let (secondTokenPaid, firstTokenRequested) = self.getOrdersSumUp(orders: buyOrders)
        let (firstTokenPaid, secondTokenRequested) = self.getOrdersSumUp(orders: sellOrders)
        
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
        
        let buyersTransfers = self.calculateTransfers(
            orders: buyOrders,
            totalPaid: secondTokenPaid,
            tokenRequested: firstTokenIdentifier,
            leftover: firstTokenLeftover
        )
        transfers = transfers.appended(contentsOf: buyersTransfers)
        
        let sellersTransfers = self.calculateTransfers(
            orders: sellOrders,
            totalPaid: firstTokenPaid,
            tokenRequested: secondTokenIdentifier,
            leftover: secondTokenLeftover
        )
        transfers = transfers.appended(contentsOf: sellersTransfers)
        
        return transfers
    }
    
    private func getAndIncreaseOrderIdCounter() -> UInt64 {
        let storageController = StorageController()
        let orderIdCounterMapper = storageController.$orderIdCounter
        let id = orderIdCounterMapper.get()
        orderIdCounterMapper.set(id + 1)
        
        return id
    }
    
    private func getAddressOrderIdsVector(address: Address) -> Vector<UInt64> {
        var ordersArray: Vector<UInt64> = Vector()
        let storageController = StorageController()
        
        storageController.orderIdsForAddress[address].forEach { order in
            if !storageController.$orderForId[order].isEmpty() {
                ordersArray = ordersArray.appended(order)
            }
        }
        
        return ordersArray
    }
    
    private func getOrdersWithType(
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
    
    private func getOrdersSumUp(
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
    private func calculateTransfers(
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
        
        let commonController = CommonHelpers()
        
        orders.forEach { order in
            let matchProviderAmount = commonController.calculateFeeAmount(
                amount: order.outputAmount,
                feeConfig: order.feeConfig
            )
            let creatorAmount = order.outputAmount - matchProviderAmount
            
            let orderDeal = commonController.ruleOfThree(
                part: order.inputAmount,
                total: totalPaid,
                value: leftover
            )
            let matchProviderDealAmount = commonController.ruleOfThree(
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
    
    private func executeTransfers(transfers: Vector<Transfer>) {
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
    
    private func clearOrders(orderIds: Vector<UInt64>) {
        let storageController = StorageController()
        orderIds.forEach { orderId in
            storageController.$orderForId[orderId].clear()
        }
    }
}

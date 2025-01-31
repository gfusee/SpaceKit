import SpaceKit

struct ValidationHelpers {
    func requireValidOrderInputParams(params: OrderInputParams) {
        self.requireValidOrderInputAmount(params: params)
        self.requireValidOrderInputMatchProvider(params: params)
        self.requireValidOrderInputFeeConfig(params: params)
        self.requireValidOrderInputDealConfig(params: params)
    }
    
    private func requireValidOrderInputAmount(params: OrderInputParams) {
        require(
            params.amount != 0,
            "Amout cannot be zero" // I know there is a typo, but it is also present in the Rust example
        )
        
        require(
            CommonHelpers().calculateFeeAmount(
                amount: params.amount,
                feeConfig: FeeConfig(
                    feeType: .percent,
                    fixedFee: 0,
                    percentFee: FEE_PENALTY_INCREASE_PERCENT
                )
            ) != 0,
            "Penalty increase amount cannot be zero"
        )
    }
    
    private func requireValidOrderInputMatchProvider(params: OrderInputParams) {
        require(
            !params.matchProvider.isZero(),
            "Match address cannot be zero"
        )
    }
    
    private func requireValidOrderInputFeeConfig(params: OrderInputParams) {
        switch params.feeConfig.feeType {
        case .fixed:
            require(
                params.feeConfig.fixedFee < params.amount,
                "Invalid fee config fixed amount"
            )
        case .percent:
            require(
                params.feeConfig.percentFee < PERCENT_BASE_POINTS,
                "Percent value above maximum value"
            )
        }
        
        let amountAfterFee = CommonHelpers().calculateAmountAfterFee(
            amount: params.amount,
            feeConfig: params.feeConfig
        )
        
        require(
            amountAfterFee != 0,
            "Amount after fee cannot be zero"
        )
    }
    
    private func requireValidOrderInputDealConfig(params: OrderInputParams) {
        require(
            params.dealConfig.matchProviderPercent < PERCENT_BASE_POINTS,
            "Bad deal config"
        )
    }
    
    func requireValidBuyPayment() -> Payment {
        let payment = Message.singleFungibleEsdt
        let storageController = StorageController()
        let secondTokenIdentiier = storageController.secondTokenIdentifier
        
        require(
            payment.tokenIdentifier == secondTokenIdentiier,
            "Token in and second token id should be the same"
        )
        
        return Payment(
            tokenIdentifier: secondTokenIdentiier,
            amount: payment.amount
        )
    }
    
    func requireValidSellPayment() -> Payment {
        let payment = Message.singleFungibleEsdt
        let storageController = StorageController()
        let firstTokenIdentifier = storageController.firstTokenIdentifier
        
        require(
            payment.tokenIdentifier == firstTokenIdentifier,
            "Token in and first token id should be the same"
        )
        
        return Payment(
            tokenIdentifier: firstTokenIdentifier,
            amount: payment.amount
        )
    }
    
    func requireValidMatchInputOrderIds(orderIds: Vector<UInt64>) {
        require(
            orderIds.count >= 2,
            "Should be at least two order ids"
        )
    }
    
    func requireMatchProviderEmptyOrCaller(orders: Vector<Order>) {
        let caller = Message.caller
        
        orders.forEach { order in
            if !order.matchProvider.isZero() {
                require(
                    order.matchProvider == caller,
                    "Caller is not matched order id"
                )
            }
        }
    }
    
   func requireOrderIdsNotEmpty(orderIds: Vector<UInt64>) {
        require(
            !orderIds.isEmpty,
            "Order ids vec is empty"
        )
    }
    
    func requireContainsAll(
        baseArray: Vector<UInt64>,
        items: Vector<UInt64>
    ) {
        let baseArrayCount = baseArray.count
        let itemsCount = items.count
        
        for itemIndex in 0..<itemsCount {
            let item = items[itemIndex]
            var checkItem = false
            
            for baseIndex in 0..<baseArrayCount {
                let base = baseArray[baseIndex]
                
                if item == base {
                    checkItem = true
                    break
                }
            }
            
            require(
                checkItem,
                "Base vec does not contain item"
            )
        }
    }
    
    func requireContainsNone(
        baseArray: Vector<UInt64>,
        items: Vector<UInt64>
    ) {
        let baseArrayCount = baseArray.count
        let itemsCount = items.count
        
        for itemIndex in 0..<itemsCount {
            let item = items[itemIndex]
            var checkItem = false
            
            for baseIndex in 0..<baseArrayCount {
                let base = baseArray[baseIndex]
                
                if item == base {
                    checkItem = true
                    break
                }
            }
            
            require(
                !checkItem,
                "Base vec contains item"
            )
        }
    }
    
    func requireNotMaxSize(addressOrderIds: Vector<UInt64>) {
        require(
            addressOrderIds.count < MAX_ORDERS_PER_USER,
            "Cannot place more orders"
        )
    }
    
}

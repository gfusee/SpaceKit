import Space

struct ValidationModule {
    
    static func requireValidOrderInputParams(params: OrderInputParams) {
        ValidationModule.requireValidOrderInputAmount(params: params)
        ValidationModule.requireValidOrderInputMatchProvider(params: params)
        ValidationModule.requireValidOrderInputFeeConfig(params: params)
        ValidationModule.requireValidOrderInputDealConfig(params: params)
    }
    
    static func requireValidOrderInputAmount(params: OrderInputParams) {
        require(
            params.amount != 0,
            "Amout cannot be zero" // I know there is a typo, but it is also present in the Rust example
        )
        
        require(
            CommonModule.calculateFeeAmount(
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
    
    static func requireValidOrderInputMatchProvider(params: OrderInputParams) {
        require(
            !params.matchProvider.isZero(),
            "Match address cannot be zero"
        )
    }
    
    static func requireValidOrderInputFeeConfig(params: OrderInputParams) {
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
        
        let amountAfterFee = CommonModule.calculateAmountAfterFee(
            amount: params.amount,
            feeConfig: params.feeConfig
        )
        
        require(
            amountAfterFee != 0,
            "Amount after fee cannot be zero"
        )
    }
    
    static func requireValidOrderInputDealConfig(params: OrderInputParams) {
        require(
            params.dealConfig.matchProviderPercent < PERCENT_BASE_POINTS,
            "Bad deal config"
        )
    }
    
    static func requireValidBuyPayment() -> Payment {
        let payment = Message.singleFungibleEsdt
        let storageModule = StorageModule()
        let secondTokenIdentiier = storageModule.secondTokenIdentifier
        
        require(
            payment.tokenIdentifier == secondTokenIdentiier,
            "Token in and second token id should be the same"
        )
        
        return Payment(
            tokenIdentifier: secondTokenIdentiier,
            amount: payment.amount
        )
    }
    
    static func requireValidSellPayment() -> Payment {
        let payment = Message.singleFungibleEsdt
        let storageModule = StorageModule()
        let firstTokenIdentifier = storageModule.firstTokenIdentifier
        
        require(
            payment.tokenIdentifier == firstTokenIdentifier,
            "Token in and first token id should be the same"
        )
        
        return Payment(
            tokenIdentifier: firstTokenIdentifier,
            amount: payment.amount
        )
    }
    
    static func requireValidMatchInputOrderIds(orderIds: Vector<UInt64>) {
        require(
            orderIds.count >= 2,
            "Should be at least two order ids"
        )
    }
    
    static func requireMatchProviderEmptyOrCaller(orders: Vector<Order>) {
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
    
    static func requireOrderIdsNotEmpty(orderIds: Vector<UInt64>) {
        require(
            !orderIds.isEmpty,
            "Order ids vec is empty"
        )
    }
    
    static func requireContainsAll(
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
    
    static func requireContainsNone(
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
    
    static func requireNotMaxSize(addressOrderIds: Vector<UInt64>) {
        require(
            addressOrderIds.count < MAX_ORDERS_PER_USER,
            "Cannot place more orders"
        )
    }
    
}

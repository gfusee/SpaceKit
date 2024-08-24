import MultiversX

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
            // TODO: UInt64 comparison causes invalid contract code, there is another TODO in another contract example detailing why
            require(
                BigUint(value: params.feeConfig.percentFee) < BigUint(value: PERCENT_BASE_POINTS),
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
        // TODO: UInt64 comparison causes invalid contract code, there is another TODO in another contract example detailing why
        require(
            BigUint(value: params.dealConfig.matchProviderPercent) < BigUint(value: PERCENT_BASE_POINTS),
            "Bad deal config"
        )
    }
    
    static func requireValidBuyPayment() -> Payment {
        let payment = Message.singleFungibleEsdt
        let secondTokenIdentiier = StorageModule.secondTokenIdentifier
        
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
        let firstTokenIdentifier = StorageModule.firstTokenIdentifier
        
        require(
            payment.tokenIdentifier == firstTokenIdentifier,
            "Token in and first token id should be the same"
        )
        
        return Payment(
            tokenIdentifier: firstTokenIdentifier,
            amount: payment.amount
        )
    }
    
    static func requireValidMatchInputOrderIds(orderIds: MXArray<UInt64>) {
        require(
            orderIds.count >= 2,
            "Should be at least two order ids"
        )
    }
    
    static func requireMatchProviderEmptyOrCaller(orders: MXArray<Order>) {
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
    
    static func requireOrderIdsNotEmpty(orderIds: MXArray<UInt64>) {
        require(
            !orderIds.isEmpty,
            "Order ids vec is empty"
        )
    }
    
    static func requireContainsAll(
        baseArray: MXArray<UInt64>,
        items: MXArray<UInt64>
    ) {
        let baseArrayCount = baseArray.count
        let itemsCount = items.count
        
        for itemIndex in 0..<itemsCount {
            let item = items[itemIndex]
            var checkItem = false
            
            for baseIndex in 0..<itemsCount {
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
        baseArray: MXArray<UInt64>,
        items: MXArray<UInt64>
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
    
    static func requireNotMaxSize(addressOrderIds: MXArray<UInt64>) {
        require(
            addressOrderIds.count < MAX_ORDERS_PER_USER,
            "Cannot place more orders"
        )
    }
    
}

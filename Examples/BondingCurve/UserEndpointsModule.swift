import Space


struct UserEndpointsModule {
    // The "dummy" parameter is useless, I'm just a lazy developer that wants the Swift compiler to stop complaining
    // Don't try this at home
    static func sellToken<T: CurveFunction & SpaceCodable & Default & Equatable>(dummy: @autoclosure () -> T) {
        let offeredPayment = Message.singleEsdt
        
        self.checkTokenExists(issuedToken: offeredPayment.tokenIdentifier)
        let storageModule = StorageModule()
        
        let (calculatedPrice, paymentToken) = storageModule.$bondingCurveForTokenIdentifier[offeredPayment.tokenIdentifier]
            .update { buffer in
                var bondingCurve = BondingCurve<T>(topDecode: buffer)
                
                let _ = UserEndpointsModule.checkOwnedReturnPaymentToken(
                    bondingCurve: bondingCurve,
                    amount: offeredPayment.amount
                )
                
                require(
                    bondingCurve.sellAvailability,
                    "Selling is not available on this token"
                )
                
                let price = UserEndpointsModule.computeSellPrice(
                    bondingCurve: bondingCurve,
                    amount: offeredPayment.amount
                )
                
                bondingCurve.payment.amount = bondingCurve.payment.amount - price
                bondingCurve.arguments.balance = bondingCurve.arguments.balance + offeredPayment.amount
                
                let paymentToken = bondingCurve.payment.tokenIdentifier
                
                var bondingCurveTopEncoded = Buffer()
                bondingCurve.topEncode(output: &bondingCurveTopEncoded)
                
                buffer = bondingCurveTopEncoded
                
                return (price, paymentToken)
            }
        
        let caller = Message.caller
        
        storageModule.$nonceAmountForTokenIdentifierAndNonce[NonceAmountMappingKey(identifier: offeredPayment.tokenIdentifier, nonce: offeredPayment.nonce)]
            .update { val in
                val = val + offeredPayment.amount
            }
        
        caller.send(
            tokenIdentifier: paymentToken,
            nonce: 0,
            amount: calculatedPrice
        )
        
        storageModule.$tokenDetailsForTokenIdentifier[offeredPayment.tokenIdentifier]
            .update { details in
                details.addNonce(nonce: offeredPayment.nonce)
            }
        
        SellTokenEvent(
            user: caller,
            amount: calculatedPrice
        ).emit()
    }
    
    // The "dummy" parameter is useless, I'm just a lazy developer that wants the Swift compiler to stop complaining
    // Don't try this at home
    static func buyToken<T: CurveFunction & SpaceCodable & Default & Equatable>(
        requestedAmount: BigUint,
        requestedToken: Buffer,
        requestedNonce: UInt64?,
        dummy: @autoclosure () -> T
    ) {
        let offeredPayment = Message.singleEsdt
        
        self.checkTokenExists(issuedToken: requestedToken)
        let storageModule = StorageModule()
        
        let calculatedPrice = storageModule.$bondingCurveForTokenIdentifier[requestedToken]
            .update { buffer in
                var bondingCurve = BondingCurve<T>(topDecode: buffer)
                
                let paymentToken = UserEndpointsModule.checkOwnedReturnPaymentToken(
                    bondingCurve: bondingCurve,
                    amount: offeredPayment.amount
                )
                
                self.checkGivenToken(
                    acceptedToken: paymentToken,
                    givenToken: offeredPayment.tokenIdentifier
                )
                
                let price = self.computeBuyPrice(bondingCurve: bondingCurve, amount: requestedAmount)
                require(
                    price <= offeredPayment.amount,
                    "The payment provided is not enough for the transaction"
                )
                
                bondingCurve.payment.amount = bondingCurve.payment.amount + price
                bondingCurve.arguments.balance = bondingCurve.arguments.balance - requestedAmount
                
                var bondingCurveTopEncoded = Buffer()
                bondingCurve.topEncode(output: &bondingCurveTopEncoded)
                
                buffer = bondingCurveTopEncoded
                
                return price
            }
        
        let caller = Message.caller
        
        if let requestedNonce = requestedNonce {
            caller.send(
                tokenIdentifier: requestedToken,
                nonce: requestedNonce,
                amount: requestedAmount
            )
            
            let nonceAmountMapper = storageModule.$nonceAmountForTokenIdentifierAndNonce[NonceAmountMappingKey(identifier: requestedToken, nonce: requestedNonce)]
            let nonceAmount = nonceAmountMapper.get()
            let diff = nonceAmount - requestedAmount
            
            if diff > 0 {
                nonceAmountMapper.set(diff)
            } else {
                nonceAmountMapper.clear()
                storageModule.$tokenDetailsForTokenIdentifier[requestedToken]
                    .update { details in
                        details.removeNonce(nonce: requestedNonce)
                    }
            }
        } else {
            self.sendNextAvailableTokens(
                caller: caller,
                token: requestedToken,
                amount: requestedAmount
            )
        }
        
        caller.send(
            tokenIdentifier: offeredPayment.tokenIdentifier,
            nonce: 0,
            amount: offeredPayment.amount - calculatedPrice
        )
        
        BuyTokenEvent(
            user: caller,
            amount: calculatedPrice
        ).emit()
    }
    
    // TODO: use TokenIdentifier type once implemented
    static func checkOwnedReturnPaymentToken<T: CurveFunction & SpaceCodable & Default & Equatable>(
        bondingCurve: BondingCurve<T>,
        amount: BigUint
    ) -> Buffer {
        bondingCurve.requireIsSet()
        require(
            amount > 0,
            "Must pay more than 0 tokens!"
        )
        
        return bondingCurve.payment.tokenIdentifier
    }
    
    // TODO: use TokenIdentifier type once implemented
    static func checkTokenExists(issuedToken: Buffer) {
        let storageModule = StorageModule()
        
        require(
            !storageModule.$bondingCurveForTokenIdentifier[issuedToken].isEmpty(),
            "Token is not issued yet!"
        )
    }
    
    // TODO: use TokenIdentifier type once implemented
    static func computeBuyPrice<T: CurveFunction & SpaceCodable & Default & Equatable>(
        bondingCurve: BondingCurve<T>,
        amount: BigUint
    ) -> BigUint {
        let arguments = bondingCurve.arguments
        let functionSelector = bondingCurve.curve
        
        let tokenStart = arguments.getFirstTokenAvailable()
        
        return functionSelector.calculatePrice(
            tokenStart: tokenStart,
            amount: amount,
            arguments: arguments
        )
    }
    
    // TODO: use TokenIdentifier type once implemented
    static func computeSellPrice<T: CurveFunction & SpaceCodable & Default & Equatable>(
        bondingCurve: BondingCurve<T>,
        amount: BigUint
    ) -> BigUint {
        let arguments = bondingCurve.arguments
        let functionSelector = bondingCurve.curve
        
        let tokenStart = arguments.getFirstTokenAvailable() - amount
        
        return functionSelector.calculatePrice(
            tokenStart: tokenStart,
            amount: amount,
            arguments: arguments
        )
    }
    
    static func sendNextAvailableTokens(
        caller: Address,
        token: Buffer,
        amount: BigUint
    ) {
        let storageModule = StorageModule()
        let tokenDetailsMapper = storageModule.$tokenDetailsForTokenIdentifier[token]
        var nonces = tokenDetailsMapper.get().tokenNonces
        var totalAmount = amount
        var tokensToSend: Vector<TokenPayment> = Vector()
        
        while true {
            require(
                !nonces.isEmpty,
                "Insufficient balance"
            )
            
            let nonce = nonces.get(0)
            let nonceAmountMapper = storageModule.$nonceAmountForTokenIdentifierAndNonce[NonceAmountMappingKey(identifier: token, nonce: nonce)]
            let availableAmount = nonceAmountMapper.get()
            
            let amountToSend: BigUint
            if availableAmount <= totalAmount {
                amountToSend = availableAmount
                totalAmount = totalAmount - amountToSend
                nonceAmountMapper.clear()
                nonces = nonces.removed(0)
            } else {
                nonceAmountMapper.update { val in
                    val = val - totalAmount
                }
                amountToSend = totalAmount
                totalAmount = 0
            }
            
            tokensToSend = tokensToSend.appended(
                TokenPayment.new(
                    tokenIdentifier: token,
                    nonce: nonce,
                    amount: amountToSend
                )
            )
            
            if totalAmount == 0 {
                break
            }
        }
        
        caller.send(payments: tokensToSend)
        
        tokenDetailsMapper.update { details in
            details.tokenNonces = nonces
        }
    }
    
    static func getTokenAvailability(
        identifier: Buffer
    ) -> MultiValueEncoded<Buffer> { // TODO: No MultiValue2 at the moment, so let's do it by hand
        let storageModule = StorageModule()
        let tokenNonces = storageModule.tokenDetailsForTokenIdentifier[identifier].tokenNonces
        var availability: MultiValueEncoded<Buffer> = MultiValueEncoded()
        
        tokenNonces.forEach { currentCheckNonce in
            var currentCheckNonceTopEncoded = Buffer()
            currentCheckNonce.topEncode(output: &currentCheckNonceTopEncoded)
            
            var nonceAmountTopEncoded = Buffer()
            storageModule.nonceAmountForTokenIdentifierAndNonce[NonceAmountMappingKey(identifier: identifier, nonce: currentCheckNonce)]
                .topEncode(output: &nonceAmountTopEncoded)
            
            availability = availability.appended(value: currentCheckNonceTopEncoded)
            availability = availability.appended(value: nonceAmountTopEncoded)
        }
        
        return availability
    }
    
    static func checkGivenToken(
        acceptedToken: Buffer,
        givenToken: Buffer
    ) {
        require(
            givenToken == acceptedToken,
            "Only \(acceptedToken) tokens accepted"
        )
    }
}

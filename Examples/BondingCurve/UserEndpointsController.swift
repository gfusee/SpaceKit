import SpaceKit


@Controller public struct UserEndpointsController {
    // The "dummy" parameter is useless, I'm just a lazy developer that wants the Swift compiler to stop complaining
    // Don't try this at home
    public func sellToken() {
        let offeredPayment = Message.singleEsdt
        
        self.checkTokenExists(issuedToken: offeredPayment.tokenIdentifier)
        let storage = Storage()
        
        let (calculatedPrice, paymentToken) = storage.$bondingCurveForTokenIdentifier[offeredPayment.tokenIdentifier]
            .update { buffer in
                var bondingCurve = BondingCurve(topDecode: buffer)
                
                let _ = self.checkOwnedReturnPaymentToken(
                    bondingCurve: bondingCurve,
                    amount: offeredPayment.amount
                )
                
                require(
                    bondingCurve.sellAvailability,
                    "Selling is not available on this token"
                )
                
                let price = self.computeSellPrice(
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
        
        storage.$nonceAmountForTokenIdentifierAndNonce[NonceAmountMappingKey(identifier: offeredPayment.tokenIdentifier, nonce: offeredPayment.nonce)]
            .update { val in
                val = val + offeredPayment.amount
            }
        
        caller.send(
            tokenIdentifier: paymentToken,
            nonce: 0,
            amount: calculatedPrice
        )
        
        storage.$tokenDetailsForTokenIdentifier[offeredPayment.tokenIdentifier]
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
    public func buyToken(
        requestedAmount: BigUint,
        requestedToken: TokenIdentifier,
        requestedNonce: OptionalArgument<UInt64>
    ) {
        let offeredPayment = Message.singleEsdt
        
        self.checkTokenExists(issuedToken: requestedToken)
        let storage = Storage()
        
        let calculatedPrice = storage.$bondingCurveForTokenIdentifier[requestedToken]
            .update { buffer in
                var bondingCurve = BondingCurve(topDecode: buffer)
                
                let paymentToken = self.checkOwnedReturnPaymentToken(
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
        
        if let requestedNonce = requestedNonce.intoOptional() {
            caller.send(
                tokenIdentifier: requestedToken,
                nonce: requestedNonce,
                amount: requestedAmount
            )
            
            let nonceAmountMapper = storage.$nonceAmountForTokenIdentifierAndNonce[NonceAmountMappingKey(identifier: requestedToken, nonce: requestedNonce)]
            let nonceAmount = nonceAmountMapper.get()
            let diff = nonceAmount - requestedAmount
            
            if diff > 0 {
                nonceAmountMapper.set(diff)
            } else {
                nonceAmountMapper.clear()
                storage.$tokenDetailsForTokenIdentifier[requestedToken]
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
    
    private func checkOwnedReturnPaymentToken(
        bondingCurve: BondingCurve,
        amount: BigUint
    ) -> TokenIdentifier {
        bondingCurve.requireIsSet()
        require(
            amount > 0,
            "Must pay more than 0 tokens!"
        )
        
        return bondingCurve.payment.tokenIdentifier
    }
    
    private func checkTokenExists(issuedToken: TokenIdentifier) {
        let storage = Storage()
        
        require(
            !storage.$bondingCurveForTokenIdentifier[issuedToken].isEmpty(),
            "Token is not issued yet!"
        )
    }
    
    private func computeBuyPrice(
        bondingCurve: BondingCurve,
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
    
    private func computeSellPrice(
        bondingCurve: BondingCurve,
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
    
    private func sendNextAvailableTokens(
        caller: Address,
        token: TokenIdentifier,
        amount: BigUint
    ) {
        let storage = Storage()
        let tokenDetailsMapper = storage.$tokenDetailsForTokenIdentifier[token]
        var nonces = tokenDetailsMapper.get().tokenNonces
        var totalAmount = amount
        var tokensToSend: Vector<TokenPayment> = Vector()
        
        while true {
            require(
                !nonces.isEmpty,
                "Insufficient balance"
            )
            
            let nonce = nonces.get(0)
            let nonceAmountMapper = storage.$nonceAmountForTokenIdentifierAndNonce[NonceAmountMappingKey(identifier: token, nonce: nonce)]
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
                TokenPayment(
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
    
    public func getTokenAvailability(
        identifier: TokenIdentifier
    ) -> MultiValueEncoded<Buffer> { // TODO: No MultiValue2 at the moment, so let's do it by hand
        let storage = Storage()
        let tokenNonces = storage.tokenDetailsForTokenIdentifier[identifier].tokenNonces
        var availability: MultiValueEncoded<Buffer> = MultiValueEncoded()
        
        for currentCheckNonce in tokenNonces {
            var currentCheckNonceTopEncoded = Buffer()
            currentCheckNonce.topEncode(output: &currentCheckNonceTopEncoded)
            
            var nonceAmountTopEncoded = Buffer()
            storage.nonceAmountForTokenIdentifierAndNonce[NonceAmountMappingKey(identifier: identifier, nonce: currentCheckNonce)]
                .topEncode(output: &nonceAmountTopEncoded)
            
            availability = availability.appended(value: currentCheckNonceTopEncoded)
            availability = availability.appended(value: nonceAmountTopEncoded)
        }
        
        return availability
    }
    
    private func checkGivenToken(
        acceptedToken: TokenIdentifier,
        givenToken: TokenIdentifier
    ) {
        require(
            givenToken == acceptedToken,
            "Only \(acceptedToken) tokens accepted"
        )
    }
}

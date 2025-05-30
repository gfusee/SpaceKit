import SpaceKit

@Controller public struct OwnerEndpointsController {
    public func deposit(
        paymentToken: OptionalArgument<TokenIdentifier>
    ) {
        let payment = Message.egldOrSingleEsdtTransfer
        let caller = Message.caller
        
        var setPayment: TokenIdentifier = .egld
        
        let storage = Storage()
        if storage.$bondingCurveForTokenIdentifier[payment.tokenIdentifier].isEmpty() {
            if let paymentToken = paymentToken.intoOptional() {
                setPayment = paymentToken
            } else {
                smartContractError(message: "Expected provided accepted_payment for the token")
            }
        }
        
        let tokenDetailsMapper = storage.$tokenDetailsForTokenIdentifier[payment.tokenIdentifier]
        
        if tokenDetailsMapper.isEmpty() {
            let nonces = Vector(singleItem: payment.nonce)
            
            tokenDetailsMapper.set(
                TokenOwnershipData(
                    tokenNonces: nonces,
                    owner: caller
                )
            )
        } else {
            var details = tokenDetailsMapper.get()
            require(
                details.owner == caller,
                "The token was already deposited by another address"
            )
            
            if !details.tokenNonces.contains(payment.nonce) {
                details.tokenNonces = details.tokenNonces.appended(payment.nonce)
                tokenDetailsMapper.set(details)
            }
        }
        
        self.setCurveStorage(
            identifier: payment.tokenIdentifier,
            amount: payment.amount,
            paymentTokenIdentifier: setPayment
        )
        let _ = storage.getOwnedTokensMapperForOwner(owner: caller).insert(value: payment.tokenIdentifier)
        storage.$nonceAmountForTokenIdentifierAndNonce[NonceAmountMappingKey(identifier: payment.tokenIdentifier, nonce: payment.nonce)]
            .update { currentAmount in
                currentAmount = currentAmount + payment.amount
            }
    }
    
    public func claim() {
        let caller = Message.caller
        
        let storage = Storage()
        let ownedTokensMapper = storage.getOwnedTokensMapperForOwner(owner: caller)
        require(
            !ownedTokensMapper.isEmpty(),
            "You have nothing to claim"
        )
        
        var tokensToClaim: Vector<TokenPayment> = Vector()
        var egldToClaim: BigUint = 0
        
        for token in ownedTokensMapper {
            let tokenDetailsMapper = storage.$tokenDetailsForTokenIdentifier[token]
            let nonces = tokenDetailsMapper.get().tokenNonces
            for nonce in nonces {
                let nonceAmountMapper = storage.$nonceAmountForTokenIdentifierAndNonce[NonceAmountMappingKey(identifier: token, nonce: nonce)]
                
                tokensToClaim = tokensToClaim.appended(
                    TokenPayment(
                        tokenIdentifier: token,
                        nonce: nonce,
                        amount: nonceAmountMapper.get()
                    )
                )
                
                nonceAmountMapper.clear()
            }
            
            let bondingCurveMapper = storage.$bondingCurveForTokenIdentifier[token]
            let bondingCurve = BondingCurve(topDecode: bondingCurveMapper.get())
            
            if bondingCurve.payment.tokenIdentifier != .egld {
                tokensToClaim = tokensToClaim.appended(
                    bondingCurve.payment
                )
            } else {
                egldToClaim = egldToClaim + bondingCurve.payment.amount
            }
            
            tokenDetailsMapper.clear()
            bondingCurveMapper.clear()
        }
        
        ownedTokensMapper.clear()
        caller.send(payments: tokensToClaim)
        if egldToClaim > 0 {
            caller.send(egldValue: egldToClaim)
        }
    }
    
    public func setBondingCurve(
        identifier: TokenIdentifier,
        function: FunctionSelector,
        sellAvailability: Bool
    ) {
        let storage = Storage()
        let tokenDetailsMapper = storage.$tokenDetailsForTokenIdentifier[identifier]
        
        require(
            !tokenDetailsMapper.isEmpty(),
            "Token is not issued yet!"
        )
        
        let caller = Message.caller
        
        let details = storage.tokenDetailsForTokenIdentifier[identifier]
        
        require(
            details.owner == caller,
            "The price function can only be set by the seller."
        )
        
        storage.$bondingCurveForTokenIdentifier[identifier]
            .update { buffer in
                var bondingCurve = BondingCurve(topDecode: buffer)
                
                bondingCurve.curve = function
                bondingCurve.sellAvailability = sellAvailability
                
                var bondingCurveEncoded = Buffer()
                bondingCurve.topEncode(output: &bondingCurveEncoded)
                
                buffer = bondingCurveEncoded
            }
    }
    
    private func setCurveStorage(
        identifier: TokenIdentifier,
        amount: BigUint,
        paymentTokenIdentifier: TokenIdentifier
    ) {
        var curve = FunctionSelector.none
        var arguments: CurveArguments
        let payment: TokenPayment
        let sellAvailability: Bool
        
        let storage = Storage()
        let bondingCurveMapper = storage.$bondingCurveForTokenIdentifier[identifier]
        
        if bondingCurveMapper.isEmpty() {
            arguments = CurveArguments(
                availableSupply: amount,
                balance: amount
            )
            payment = TokenPayment(
                tokenIdentifier: paymentTokenIdentifier,
                nonce: 0,
                amount: 0
            )
            sellAvailability = false
        } else {
            let bondingCurve = BondingCurve(topDecode: bondingCurveMapper.get())
            
            payment = bondingCurve.payment
            curve = bondingCurve.curve
            arguments = bondingCurve.arguments
            arguments.balance = arguments.balance + amount
            arguments.availableSupply = arguments.availableSupply + amount
            sellAvailability = bondingCurve.sellAvailability
        }
        
        var encodedCurve = Buffer()
        BondingCurve(
            curve: curve,
            arguments: arguments,
            sellAvailability: sellAvailability,
            payment: payment
        ).topEncode(output: &encodedCurve)
        
        bondingCurveMapper.set(encodedCurve)
    }
}

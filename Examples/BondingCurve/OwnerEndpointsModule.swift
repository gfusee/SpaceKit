import SpaceKit

struct OwnerEndpointsModule {
    // TODO: use TokenIdentifier type once implemented
    static func deposit<T: CurveFunction & SpaceCodable & Default & Equatable>(
        paymentToken: Buffer?,
        dummy: @autoclosure () -> T
    ) {
        let payment = Message.egldOrSingleEsdtTransfer
        let caller = Message.caller
        
        var setPayment: Buffer = "EGLD" // TODO: no hardcoded EGLD
        
        let storageModule = StorageModule()
        if storageModule.$bondingCurveForTokenIdentifier[payment.tokenIdentifier].isEmpty() {
            if let paymentToken = paymentToken {
                setPayment = paymentToken
            } else {
                smartContractError(message: "Expected provided accepted_payment for the token")
            }
        }
        
        let tokenDetailsMapper = storageModule.$tokenDetailsForTokenIdentifier[payment.tokenIdentifier]
        
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
            paymentTokenIdentifier: setPayment,
            dummy: T(default: ())
        )
        let _ = storageModule.getOwnedTokensMapperForOwner(owner: caller).insert(value: payment.tokenIdentifier)
        storageModule.$nonceAmountForTokenIdentifierAndNonce[NonceAmountMappingKey(identifier: payment.tokenIdentifier, nonce: payment.nonce)]
            .update { currentAmount in
                currentAmount = currentAmount + payment.amount
            }
    }
    
    static func claim<T: CurveFunction & SpaceCodable & Default & Equatable>(
        dummy: @autoclosure () -> T
    ) {
        let caller = Message.caller
        
        let storageModule = StorageModule()
        let ownedTokensMapper = storageModule.getOwnedTokensMapperForOwner(owner: caller)
        require(
            !ownedTokensMapper.isEmpty(),
            "You have nothing to claim"
        )
        
        var tokensToClaim: Vector<TokenPayment> = Vector()
        var egldToClaim: BigUint = 0
        
        ownedTokensMapper.forEach { token in
            let tokenDetailsMapper = storageModule.$tokenDetailsForTokenIdentifier[token]
            let nonces = tokenDetailsMapper.get().tokenNonces
            nonces.forEach { nonce in
                let nonceAmountMapper = storageModule.$nonceAmountForTokenIdentifierAndNonce[NonceAmountMappingKey(identifier: token, nonce: nonce)]
                
                tokensToClaim = tokensToClaim.appended(
                    TokenPayment.new(
                        tokenIdentifier: token,
                        nonce: nonce,
                        amount: nonceAmountMapper.get()
                    )
                )
                
                nonceAmountMapper.clear()
            }
            
            let bondingCurveMapper = storageModule.$bondingCurveForTokenIdentifier[token]
            let bondingCurve = BondingCurve<T>(topDecode: bondingCurveMapper.get())
            
            if bondingCurve.payment.tokenIdentifier != "EGLD" { // TODO: no hardcoded EGLD
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
    
    // TODO: use TokenIdentifier type once implemented
    static func setBondingCurve<T: CurveFunction & SpaceCodable & Default & Equatable>(
        identifier: Buffer,
        function: T,
        sellAvailability: Bool
    ) {
        let storageModule = StorageModule()
        let tokenDetailsMapper = storageModule.$tokenDetailsForTokenIdentifier[identifier]
        
        require(
            !tokenDetailsMapper.isEmpty(),
            "Token is not issued yet!"
        )
        
        let caller = Message.caller
        
        let details = storageModule.tokenDetailsForTokenIdentifier[identifier]
        
        require(
            details.owner == caller,
            "The price function can only be set by the seller."
        )
        
        storageModule.$bondingCurveForTokenIdentifier[identifier]
            .update { buffer in
                var bondingCurve = BondingCurve<T>(topDecode: buffer)
                
                bondingCurve.curve = function
                bondingCurve.sellAvailability = sellAvailability
                
                var bondingCurveEncoded = Buffer()
                bondingCurve.topEncode(output: &bondingCurveEncoded)
                
                buffer = bondingCurveEncoded
            }
    }
    
    // TODO: use TokenIdentifier type once implemented
    static func setCurveStorage<T: CurveFunction & SpaceCodable & Default & Equatable>(
        identifier: Buffer,
        amount: BigUint,
        paymentTokenIdentifier: Buffer,
        dummy: @autoclosure () -> T
    ) {
        var curve = T(default: ())
        var arguments: CurveArguments
        let payment: TokenPayment
        let sellAvailability: Bool
        
        let storageModule = StorageModule()
        let bondingCurveMapper = storageModule.$bondingCurveForTokenIdentifier[identifier]
        
        if bondingCurveMapper.isEmpty() {
            arguments = CurveArguments(
                availableSupply: amount,
                balance: amount
            )
            payment = TokenPayment.new(
                tokenIdentifier: paymentTokenIdentifier,
                nonce: 0,
                amount: 0
            )
            sellAvailability = false
        } else {
            let bondingCurve = BondingCurve<T>(topDecode: bondingCurveMapper.get())
            
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

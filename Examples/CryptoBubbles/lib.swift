import MultiversX

// TODO: add tests to ensure non public func are not exported in the wasm

@Event(dataType: BigUint) struct TopUpEvent {
    let player: Address
}

@Event(dataType: BigUint) struct WithdrawEvent {
    let player: Address
}

@Event(dataType: BigUint) struct PlayerJoinsGameEvent {
    let gameIndex: BigUint
    let player: Address
}

@Event(dataType: BigUint) struct RewardWinnerEvent {
    let gameIndex: BigUint
    let winner: Address
}

@Contract struct CryptoBubbles {
    
    @Mapping(key: "playerBalance") var playerBalance: StorageMap<Address, BigUint>
    
    public mutating func topUp() {
        let payment = Message.egldValue
        
        require(
            payment > 0,
            "Wrong payment"
        )
        
        let caller = Message.caller
        self.playerBalance[caller] = self.playerBalance[caller] + payment
        
        TopUpEvent(player: caller).emit(data: payment)
    }
    
    public mutating func withdraw(amount: BigUint) {
        self.transferBackToPlayerWallet(player: Message.caller, amount: amount)
    }
    
    mutating func transferBackToPlayerWallet(player: Address, amount: BigUint) {
        let playerBalance = self.playerBalance[player]
        
        require(
            amount <= playerBalance,
            "amount to withdraw must be less or equal to balance"
        )
        
        self.playerBalance[player] = playerBalance - amount
        
        player.send(egldValue: amount)
        
        WithdrawEvent(player: player).emit(data: amount)
    }
    
    mutating func addPlayerToGameStateChange(
        gameIndex: BigUint,
        player: Address,
        bet: BigUint
    ) {
        let playerBalance = self.playerBalance[player]
        
        require(
            bet <= playerBalance,
            "insufficient funds to join game"
        )
        
        self.playerBalance[player] = self.playerBalance[player] - bet
        
        PlayerJoinsGameEvent(gameIndex: gameIndex, player: player).emit(data: bet)
    }
    
    public mutating func joinGame(
        gameIndex: BigUint
    ) {
        let bet = Message.egldValue
        
        require(
            bet > 0,
            "wrong payment"
        )
        
        let player = Message.caller
        
        self.topUp()
        self.addPlayerToGameStateChange(gameIndex: gameIndex, player: player, bet: bet)
    }
    
    public mutating func rewardWinner(
        gameIndex: BigUint,
        winner: Address,
        prize: BigUint
    ) {
        assertOwner()
        
        self.playerBalance[winner] = self.playerBalance[winner] + prize
        
        RewardWinnerEvent(gameIndex: gameIndex, winner: winner).emit(data: prize)
    }
    
    public mutating func rewardAndSendToWallet(
        gameIndex: BigUint,
        winner: Address,
        prize: BigUint
    ) {
        self.rewardWinner(gameIndex: gameIndex, winner: winner, prize: prize)
        self.transferBackToPlayerWallet(player: winner, amount: prize)
    }
    
    public func balanceOf(player: Address) -> BigUint {
        return self.playerBalance[player]
    }
}

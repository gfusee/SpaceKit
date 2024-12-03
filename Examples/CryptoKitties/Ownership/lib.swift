import SpaceKit
import CryptoKittiesCommon
import CryptoKittiesRandom

@Proxy enum CryptoKittiesGeneticAlgProxy {
    case generateKittyGenes(matron: Kitty, sire: Kitty)
}

@Event struct TransferEvent {
    let from: Address
    let to: Address
    let tokenId: UInt32
}

@Event struct ApproveEvent {
    let owner: Address
    let approved: Address
    let tokenId: UInt32
}

@Init func initialize(
    birthFee: BigUint,
    optGeneScienceContractAddress: OptionalArgument<Address>,
    optKittyAuctionContractAddress: OptionalArgument<Address>
) {
    var controller = CryptoKittiesOwnership()
    
    controller.birthFee = birthFee
    
    if let geneScienceContractAddress = optGeneScienceContractAddress.intoOptional() {
        controller.geneScienceContractAddress = geneScienceContractAddress
    }
    
    if let kittyAuctionContractAddress = optKittyAuctionContractAddress.intoOptional() {
        controller.kittyAuctionContractAddress = kittyAuctionContractAddress
    }
    
    controller.createGenesisKitty()
}

@Contract struct CryptoKittiesOwnership {
    @Storage(key: "geneScienceContractAddress") var geneScienceContractAddress: Address
    @Storage(key: "kittyAuctionContractAddress") var kittyAuctionContractAddress: Address
    @Storage(key: "birthFee") var birthFee: BigUint
    
    @Storage(key: "totalKitties") var totalKitties: UInt32
    @Mapping<UInt32, Kitty>(key: "kitty") var kittyForId
    @Mapping<UInt32, Address>(key: "owner") var kittyOwnerForId
    @Mapping<Address, UInt32>(key: "nrOwnedKitties") var numberOfOwnedKittiesForAddress
    @Mapping<UInt32, Address>(key: "approvedAddress") var approvedAddressForId
    @Mapping<UInt32, Address>(key: "sireAllowedAddress") var sireAllowedAddressForId
    
    public mutating func setGeneScienceContractAddress(address: Address) {
        assertOwner()
        
        self.geneScienceContractAddress = address
    }
    
    public mutating func setKittyAuctionContractAddress(address: Address) {
        assertOwner()
        
        self.kittyAuctionContractAddress = address
    }
    
    public func claim() {
        assertOwner()
        
        let caller = Message.caller
        let egldBalance = Blockchain.getBalance(address: Blockchain.getSCAddress())
        
        caller.send(egldValue: egldBalance)
    }
    
    public func totalSupply() -> UInt32 {
        // not counting genesis Kitty
        return self.totalKitties - 1
    }
    
    public func balanceOf(address: Address) -> UInt32 {
        return self.numberOfOwnedKittiesForAddress[address]
    }
    
    public func ownerOf(kittyId: UInt32) -> Address {
        return if self.isValidId(kittyId: kittyId) {
            self.kittyOwnerForId[kittyId]
        } else {
            Address()
        }
    }
    
    public mutating func approve(
        to: Address,
        kittyId: UInt32
    ) {
        let caller = Message.caller
        
        require(
            self.isValidId(kittyId: kittyId),
            "Invalid kitty id!"
        )
        require(
            self.kittyOwnerForId[kittyId] == caller,
            "You are not the owner of that kitty!"
        )
        
        self.approvedAddressForId[kittyId] = to
        
        ApproveEvent(
            owner: caller,
            approved: to,
            tokenId: kittyId
        ).emit()
    }
    
    public mutating func transfer(
        to: Address,
        kittyId: UInt32
    ) {
        let caller = Message.caller
        
        require(
            self.isValidId(kittyId: kittyId),
            "Invalid kitty id!"
        )
        require(
            !to.isZero(),
            "Can't transfer to default address 0x0!"
        )
        require(
            to != Blockchain.getSCAddress(),
            "Can't transfer to this contract!"
        )
        require(
            self.kittyOwnerForId[kittyId] == caller,
            "You are not the owner of that kitty!"
        )
        
        self.performTransfer(
            from: caller,
            to: to,
            kittyId: kittyId
        )
    }
    
    public mutating func transferFrom(
        from: Address,
        to: Address,
        kittyId: UInt32
    ) {
        let caller = Message.caller
        let kittyOwner = self.kittyOwnerForId[kittyId]
        
        require(
            self.isValidId(kittyId: kittyId),
            "Invalid kitty id!"
        )
        require(
            !to.isZero(),
            "Can't transfer to default address 0x0!"
        )
        require(
            to != Blockchain.getSCAddress(),
            "Can't transfer to this contract!"
        )
        require(
            kittyOwner == from,
            "ManagedAddress _from_ is not the owner!"
        )
        require(
            kittyOwner == caller || self.getApprovedAddressOrDefault(kittyId: kittyId) == caller,
            "You are not the owner of that kitty nor the approved address!"
        )
        
        self.performTransfer(
            from: from,
            to: to,
            kittyId: kittyId
        )
    }
    
    public func tokensOfOwner(address: Address) -> MultiValueEncoded<UInt32> {
        let numberOwnedKitties = self.numberOfOwnedKittiesForAddress[address]
        let totalKitties = self.totalKitties
        
        var kittyArray: Vector<UInt32> = Vector()
        var arrayCount: UInt32 = 0 // Note from the Rust code: more efficient than calling the API over and over
        
        for kittyId in 1..<(totalKitties + 1) {
            guard numberOwnedKitties != arrayCount else {
                break
            }
            
            if self.kittyOwnerForId[kittyId] == address {
                kittyArray = kittyArray.appended(kittyId)
                arrayCount += 1
            }
        }
        
        return MultiValueEncoded(items: kittyArray)
    }
    
    public mutating func allowAuctioning(by: Address, kittyId: UInt32) {
        let kittyAuctionAddress = self.getKittyAuctionContractAddressOrDefault()
        
        require(
            Message.caller == kittyAuctionAddress,
            "Only auction contract may call this function!"
        )
        require(
            self.isValidId(kittyId: kittyId),
            "Invalid kitty id!"
        )
        require(
            by == self.kittyOwnerForId[kittyId] || by == self.getApprovedAddressOrDefault(kittyId: kittyId),
            "\(by) is not the owner of that kitty nor the approved address!"
        )
        require(
            !self.kittyForId[kittyId].isPregnant(),
            "Can't auction a pregnant kitty!"
        )
        
        self.performTransfer(
            from: by,
            to: kittyAuctionAddress,
            kittyId: kittyId
        )
    }
    
    public mutating func approveSiringAndReturnKitty(
        approvedAddress: Address,
        kittyOwner: Address,
        kittyId: UInt32
    ) {
        let kittyAuctionAddress = self.getKittyAuctionContractAddressOrDefault()
        
        require(
            Message.caller == kittyAuctionAddress,
            "Only auction contract may call this function!"
        )
        require(
            self.isValidId(kittyId: kittyId),
            "Invalid kitty id!"
        )
        require(
            kittyAuctionAddress == self.kittyOwnerForId[kittyId] || kittyAuctionAddress == self.getApprovedAddressOrDefault(kittyId: kittyId),
            "\(kittyAuctionAddress) is not the owner of that kitty nor the approved address!"
        )
        
        self.performTransfer(
            from: kittyAuctionAddress,
            to: kittyOwner,
            kittyId: kittyId
        )
        
        self.sireAllowedAddressForId[kittyId] = approvedAddress
    }
    
    public mutating func createGenZeroKitty() -> UInt32 {
        let kittyAuctionAddress = self.getKittyAuctionContractAddressOrDefault()
        
        require(
            Message.caller == kittyAuctionAddress,
            "Only auction contract may call this function!"
        )
        
        var random = Random(
            seed: Blockchain.getBlockRandomSeed(),
            salt: Message.transactionHash
        )
        let genes = KittyGenes.getRandom(random: &random)
        
        return self.createNewGenZeroKitty(genes: genes)
    }
    
    public func getKittyById(kittyId: UInt32) -> Kitty {
        return if self.isValidId(kittyId: kittyId) {
            self.kittyForId[kittyId]
        } else {
            smartContractError(message: "kitty does not exist!")
        }
    }
    
    public func isReadyToBreed(kittyId: UInt32) -> Bool {
        require(
            self.isValidId(kittyId: kittyId),
            "Invalid kitty id!"
        )
        
        let kitty = self.kittyForId[kittyId]
        
        return self.isKittyReadyToBreed(kitty: kitty)
    }
    
    public func isPregnant(kittyId: UInt32) -> Bool {
        require(
            self.isValidId(kittyId: kittyId),
            "Invalid kitty id!"
        )
        
        let kitty = self.kittyForId[kittyId]
        
        return kitty.isPregnant()
    }
    
    public func canBreedWith(matronId: UInt32, sireId: UInt32) -> Bool {
        require(
            self.isValidId(kittyId: matronId),
            "Invalid matron id!"
        )
        require(
            self.isValidId(kittyId: sireId),
            "Invalid sire id!"
        )
        
        return self.isValidMatingPair(matronId: matronId, sireId: sireId) && self.isSiringPermitted(matronId: matronId, sireId: sireId)
    }
    
    public mutating func approveSiring(
        address: Address,
        kittyId: UInt32
    ) {
        require(
            self.isValidId(kittyId: kittyId),
            "Invalid kitty id!"
        )
        require(
            self.kittyOwnerForId[kittyId] == Message.caller,
            "You are not the owner of the kitty!"
        )
        require(
            self.getSireAllowedAddressOrDefault(kittyId: kittyId).isZero(),
            "Can't overwrite approved sire address!"
        )
        
        self.sireAllowedAddressForId[kittyId] = address
    }
    
    public mutating func breedWith(
        matronId: UInt32,
        sireId: UInt32
    ) {
        require(
            self.isValidId(kittyId: matronId),
            "Invalid matron id!"
        )
        require(
            self.isValidId(kittyId: sireId),
            "Invalid sire id!"
        )
        
        let payment = Message.egldValue
        let autoBirthFee = self.birthFee
        let caller = Message.caller
        
        require(
            payment == autoBirthFee,
            "Wrong fee!"
        )
        require(
            caller == self.kittyOwnerForId[matronId],
            "Only the owner of the matron can call this function!"
        )
        require(
            self.isSiringPermitted(matronId: matronId, sireId: sireId),
            "Siring not permitted!"
        )
        
        let matron = self.kittyForId[matronId]
        let sire = self.kittyForId[sireId]
        
        require(
            self.isKittyReadyToBreed(kitty: matron),
            "Matron not ready to breed!"
        )
        require(
            self.self.isKittyReadyToBreed(kitty: sire),
            "Sire not ready to breed!"
        )
        require(
            self.isValidMatingPair(matronId: matronId, sireId: sireId),
            "Not a valid mating pair!"
        )
        
        self.breed(
            matronId: matronId,
            sireId: sireId
        )
    }
    
    public func giveBirth(matronId: UInt32) {
        require(
            self.isValidId(kittyId: matronId),
            "Invalid kitty id!"
        )
        
        let matron = self.kittyForId[matronId]
        
        require(
            self.isReadyToGiveBirth(matron: matron),
            "Matron not ready to give birth!"
        )
        
        let sireId = matron.siringWithId
        let sire = self.kittyForId[sireId]
        
        let geneScienceContractAddress = self.getGeneScienceContractAddressOrDefault()
        if !geneScienceContractAddress.isZero() {
            // TODO: removing 10_000_000 is huge
            let gasLeft = Blockchain.getGasLeft() - 10_000_000
            let gasForCallback: UInt64 = 20_000_000
            
            let gasForExecution = gasLeft - gasForCallback
            
            CryptoKittiesGeneticAlgProxy.generateKittyGenes(
                matron: matron,
                sire: sire
            )
            .registerPromise(
                receiver: geneScienceContractAddress,
                gas: gasForExecution,
                callback: self.$generateKittyGenesCallback(
                    matronId: matronId,
                    originalCaller: Message.caller,
                    gasForCallback: gasForCallback
                )
            )
        } else {
            smartContractError(message: "Gene science contract address not set!")
        }
    }
    
    mutating func createGenesisKitty() {
        let genesisKitty = Kitty.getDefault()
        
        let _ = self.createNewKitty(
            matronId: genesisKitty.matronId,
            sireId: genesisKitty.sireId,
            generation: genesisKitty.generation,
            genes: genesisKitty.genes,
            owner: Address()
        )
    }
    
    mutating func createNewGenZeroKitty(genes: KittyGenes) -> UInt32 {
        let kittyAuctionAddress = self.kittyAuctionContractAddress
        
        return self.createNewKitty(
            matronId: 0,
            sireId: 0,
            generation: 0,
            genes: genes,
            owner: kittyAuctionAddress
        )
    }
    
    mutating func createNewKitty(
        matronId: UInt32,
        sireId: UInt32,
        generation: UInt16,
        genes: KittyGenes,
        owner: Address
    ) -> UInt32 {
        let totalKittiesMapper = self.$totalKitties
        var totalKitties = totalKittiesMapper.get()
        
        let newKittyId = totalKitties
        
        let kitty = Kitty.new(
            genes: genes,
            birthTime: Blockchain.getBlockTimestamp(),
            matronId: matronId,
            sireId: sireId,
            generation: generation
        )
        
        totalKitties += 1
        totalKittiesMapper.set(totalKitties)
        self.kittyForId[newKittyId] = kitty
        
        self.performTransfer(
            from: Address(),
            to: owner,
            kittyId: newKittyId
        )
        
        return newKittyId
    }
    
    mutating func performTransfer(
        from: Address,
        to: Address,
        kittyId: UInt32
    ) {
        guard from != to else {
            return
        }
        
        let numberOwnedToMapper = self.$numberOfOwnedKittiesForAddress[to]
        let newNumberOwnedTo = numberOwnedToMapper.get() + 1
        
        if !from.isZero() {
            let numberOwnedFromMapper = self.$numberOfOwnedKittiesForAddress[from]
            let newNumberOwnedFrom = numberOwnedFromMapper.get() - 1
            
            numberOwnedFromMapper.set(newNumberOwnedFrom)
            self.$sireAllowedAddressForId[kittyId].clear()
            self.$approvedAddressForId[kittyId].clear()
        }
        
        numberOwnedToMapper.set(newNumberOwnedTo)
        self.kittyOwnerForId[kittyId] = to
        
        TransferEvent(
            from: from,
            to: to,
            tokenId: kittyId
        ).emit()
    }
    
    func triggerCooldown(kitty: Kitty) -> Kitty {
        var kitty = kitty
        
        let cooldown = kitty.getNextCooldownTime()
        
        kitty.cooldownEnd = Blockchain.getBlockTimestamp() + cooldown
        
        return kitty
    }
    
    mutating func breed(
        matronId: UInt32,
        sireId: UInt32
    ) {
        var matron = self.kittyForId[matronId]
        var sire = self.kittyForId[sireId]
        
        matron.siringWithId = sireId
        
        matron = self.triggerCooldown(kitty: matron)
        sire = self.triggerCooldown(kitty: sire)
        
        self.$sireAllowedAddressForId[matronId].clear()
        self.$sireAllowedAddressForId[sireId].clear()
        
        self.kittyForId[matronId] = matron
        self.kittyForId[sireId] = sire
    }
    
    func isValidId(kittyId: UInt32) -> Bool {
        return kittyId != 0 && kittyId < self.totalKitties
    }
    
    func isKittyReadyToBreed(kitty: Kitty) -> Bool {
        return kitty.siringWithId == 0 && kitty.cooldownEnd < Blockchain.getBlockTimestamp()
    }
    
    func isReadyToGiveBirth(matron: Kitty) -> Bool {
        matron.siringWithId != 0 && matron.cooldownEnd < Blockchain.getBlockTimestamp()
    }
    
    func isValidMatingPair(
        matronId: UInt32,
        sireId: UInt32
    ) -> Bool {
        let matron = self.kittyForId[matronId]
        let sire = self.kittyForId[sireId]
        
        // can't breed with itself
        guard matronId != sireId else {
            return false
        }
        
        // can't breed with their parents
        guard matron.matronId != sireId && matron.sireId != sireId else {
            return false
        }
        guard sire.matronId != matronId && sire.sireId != matronId else {
            return false
        }
        
        // for gen zero kitties
        guard sire.matronId != 0 && matron.matronId != 0 else {
            return true
        }
        
        // can't breed with full or half siblings
        guard sire.matronId == matron.matronId || sire.matronId == matron.sireId else {
            return false
        }
        guard sire.sireId == matron.matronId || sire.sireId == matron.sireId else {
            return false
        }
        
        return true
    }
    
    func isSiringPermitted(
        matronId: UInt32,
        sireId: UInt32
    ) -> Bool {
        let matronOwner = self.kittyOwnerForId[matronId]
        let sireOwner = self.kittyOwnerForId[sireId]
        let sireApprovedAddress = self.getSireAllowedAddressOrDefault(kittyId: sireId)
        
        return sireOwner == matronOwner || matronOwner == sireApprovedAddress
    }
    
    func getApprovedAddressOrDefault(kittyId: UInt32) -> Address {
        let approvedAddressMapper = self.$approvedAddressForId[kittyId]
        
        return if approvedAddressMapper.isEmpty() {
            Address()
        } else {
            approvedAddressMapper.get()
        }
    }
    
    func getKittyAuctionContractAddressOrDefault() -> Address {
        let kittyAuctionContractAddressMapper = self.$kittyAuctionContractAddress
        
        return if kittyAuctionContractAddressMapper.isEmpty() {
            Address()
        } else {
            kittyAuctionContractAddressMapper.get()
        }
    }
    
    func getGeneScienceContractAddressOrDefault() -> Address {
        let geneScienceContractAddressMapper = self.$geneScienceContractAddress
        
        return if geneScienceContractAddressMapper.isEmpty() {
            Address()
        } else {
            geneScienceContractAddressMapper.get()
        }
    }
    
    func getSireAllowedAddressOrDefault(kittyId: UInt32) -> Address {
        let allowedAddressMapper = self.$sireAllowedAddressForId[kittyId]
        
        return if allowedAddressMapper.isEmpty() {
            Address()
        } else {
            allowedAddressMapper.get()
        }
    }
    
    @Callback public mutating func generateKittyGenesCallback(
        matronId: UInt32,
        originalCaller: Address
    ) {
        let result: AsyncCallResult<KittyGenes> = Message.asyncCallResult()
        
        switch result {
        case .success(let genes):
            let matronMapper = self.$kittyForId[matronId]
            var matron = matronMapper.get()
            
            let sireId = matron.siringWithId
            let sireMapper = self.$kittyForId[sireId]
            var sire = sireMapper.get()
            
            let newKittyGeneration = max(matron.generation, sire.generation) + 1
            
            // new kitty goes to the owner of the matron
            let newKittyOwner = self.kittyOwnerForId[matronId]
            _ = self.createNewKitty(
                matronId: matronId,
                sireId: sireId,
                generation: newKittyGeneration,
                genes: genes,
                owner: newKittyOwner
            )
            
            // update matron kitty
            matron.siringWithId = 0
            matron.numberOfChildren += 1
            matronMapper.set(matron)
            
            // update sire kitty
            sire.numberOfChildren += 1
            sireMapper.set(sire)
            
            // send birth fee to caller
            let fee = self.birthFee
            originalCaller.send(egldValue: fee)
        case .error(_):
            // this can only fail if the kitty_genes contract address is invalid
            // in which case, the only thing we can do is call this again later
            break
        }
    }
}

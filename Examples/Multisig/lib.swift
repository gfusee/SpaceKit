import SpaceKit

@Contract struct Multisig {
    init(
        quorum: UInt32,
        board: MultiValueEncoded<Address>
    ) {
        self.initialise(quorum: quorum, board: board)
    }
    
    // TODO: ensure the upgrade endpoint is marked with something with @Upgrade, so it cannot be a mistake
    public func upgrade(
        quorum: UInt32,
        board: MultiValueEncoded<Address>
    ) {
        self.initialise(quorum: quorum, board: board)
    }
    
    func initialise(
        quorum: UInt32,
        board: MultiValueEncoded<Address>
    ) {
        var storageModule = StorageModule()
        
        let newNumBoardMembers = StateModule.addMultipleBoardMembers(newBoardMembers: board.toArray())
        let numProposers = storageModule.numProposers
        
        require(
            newNumBoardMembers + numProposers > 0,
            "board cannot be empty on init, no-one would be able to propose"
        )
        
        require(
            quorum <= newNumBoardMembers,
            "quorum cannot exceed board size"
        )
        
        storageModule.quorum = quorum
    }
    
    public func deposit() {}
    
    public func sign(actionId: UInt32) {
        let storageModule = StorageModule()
        
        let actionMapper = storageModule.getActionMapper()
        
        require(
            !actionMapper.isItemEmptyUnchecked(index: actionId),
            "action does not exist"
        )
        
        let (callerId, callerRole) = StateModule.getCallerIdAndRole()
        require(
            callerRole.canSign(),
            "only board members can sign"
        )
        
        let actionSignerIdsMapper = storageModule.getActionSignerIdsMapper(actionId: actionId)
        
        if !actionSignerIdsMapper.contains(value: callerId) {
            let _ = actionSignerIdsMapper.insert(value: callerId)
        }
    }
    
    public func unsign(actionId: UInt32) {
        let storageModule = StorageModule()
        
        let actionMapper = storageModule.getActionMapper()
        
        require(
            !actionMapper.isItemEmptyUnchecked(index: actionId),
            "action does not exist"
        )
        
        let (callerId, callerRole) = StateModule.getCallerIdAndRole()
        require(
            callerRole.canSign(),
            "only board members can un-sign"
        )
        
        let actionSignerIdsMapper = storageModule.getActionSignerIdsMapper(actionId: actionId)
        let _ = actionSignerIdsMapper.swapRemove(value: callerId)
    }
    
    public func discardAction(actionId: UInt32) {
        let (_, callerRole) = StateModule.getCallerIdAndRole()
        
        require(
            callerRole.canDiscardAction(),
            "only board members and proposers can discard actions"
        )
        
        require(
            StateModule.getActionValidSignerCount(actionId: actionId) == 0,
            "cannot discard action with valid signatures"
        )
        
        PerformModule.clearAction(actionId: actionId)
    }
    
    public func performAction(actionId: UInt32) -> OptionalArgument<Address> {
        let (_, callerRole) = StateModule.getCallerIdAndRole()
        
        require(
            callerRole.canPerformAction(),
            "only board members and proposers can perform actions"
        )
        require(
            self.quorumReached(actionId: actionId),
            "quorum has not been reached"
        )
        
        return PerformModule.performAction(actionId: actionId)
    }
    
    public func proposeAddBoardMember(
        boardMemberAddress: Address
    ) -> UInt32 {
        return ProposeModule.proposeAddBoardMember(boardMemberAddress: boardMemberAddress)
    }
    
    public func proposeAddProposer(
        proposerAddress: Address
    ) -> UInt32 {
        return ProposeModule.proposeAddProposer(proposerAddress: proposerAddress)
    }
    
    public func proposeRemoveUser(
        userAddress: Address
    ) -> UInt32 {
        return ProposeModule.proposeRemoveUser(userAddress: userAddress)
    }
    
    public func proposeChangeQuorum(
        newQuorum: UInt32
    ) -> UInt32 {
        return ProposeModule.proposeChangeQuorum(newQuorum: newQuorum)
    }
    
    public func proposeTransferExecute(
        to: Address,
        egldAmount: BigUint,
        functionName: OptionalArgument<Buffer>,
        functionArguments: MultiValueEncoded<Buffer>
    ) -> UInt32 {
        return ProposeModule.proposeTransferExecute(
            to: to,
            egldAmount: egldAmount,
            functionName: functionName.intoOptional() ?? Buffer(),
            functionArguments: functionArguments
        )
    }
    
    public func proposeAsyncCall(
        to: Address,
        egldAmount: BigUint,
        functionName: Buffer,
        functionArguments: MultiValueEncoded<Buffer>
    ) -> UInt32 {
        return ProposeModule.proposeAsyncCall(
            to: to,
            egldAmount: egldAmount,
            functionName: functionName,
            functionArguments: functionArguments
        )
    }
    
    public func proposeSCDeployFromSource(
        amount: BigUint,
        source: Address,
        codeMetadata: CodeMetadata,
        arguments: MultiValueEncoded<Buffer>
    ) -> UInt32 {
        return ProposeModule.proposeSCDeployFromSource(
            amount: amount,
            source: source,
            codeMetadata: codeMetadata,
            arguments: arguments
        )
    }
    
    public func proposeSCUpgradeFromSource(
        scAddress: Address,
        amount: BigUint,
        source: Address,
        codeMetadata: CodeMetadata,
        arguments: MultiValueEncoded<Buffer>
    ) -> UInt32 {
        return ProposeModule.proposeSCUpgradeFromSource(
            scAddress: scAddress, 
            amount: amount,
            source: source,
            codeMetadata: codeMetadata,
            arguments: arguments
        )
    }
    
    public func getQuorum() -> UInt32 {
        let storageModule = StorageModule()
        
        return storageModule.quorum
    }
    
    public func getNumBoardMembers() -> UInt32 {
        let storageModule = StorageModule()
        
        return storageModule.numBoardMembers
    }
    
    public func getActionSigners(actionId: UInt32) -> Vector<Address> {
        return StateModule.getActionSigners(actionId: actionId)
    }
    
    public func getPendingActionFullInfo() -> MultiValueEncoded<ActionFullInfo> {
        var resultArray: Vector<ActionFullInfo> = Vector()
        
        let storageModule = StorageModule()
        
        let actionLastIndex = StateModule.getActionLastIndex()
        let actionMapper = storageModule.getActionMapper()
        
        for actionId in 1...actionLastIndex {
            let actionData = actionMapper.get(index: actionId)
            if actionData.isPending {
                resultArray = resultArray.appended(
                    ActionFullInfo(
                        actionId: actionId,
                        actionData: actionData,
                        signers: StateModule.getActionSigners(actionId: actionId)
                    )
                )
            }
        }
        
        return MultiValueEncoded(items: resultArray)
    }
    
    public func getActionData(actionId: UInt32) -> Action {
        return StateModule.getActionData(actionId: actionId)
    }
    
    public func getActionLastIndex() -> UInt32 {
        return StateModule.getActionLastIndex()
    }
    
    public func getActionSignerCount(actionId: UInt32) -> UInt32 {
        let storageModule = StorageModule()
        
        return storageModule.getActionSignerIdsMapper(actionId: actionId).count
    }
    
    public func getActionValidSignerCount(actionId: UInt32) -> UInt32 {
        return StateModule.getActionValidSignerCount(actionId: actionId)
    }
    
    public func quorumReached(actionId: UInt32) -> Bool {
        return PerformModule.quorumReached(actionId: actionId)
    }
    
    public func getAllBoardMembers() -> MultiValueEncoded<Address> {
        return self.getAllUsersWithRole(role: .boardMember)
    }
    
    public func getAllProposers() -> MultiValueEncoded<Address> {
        return self.getAllUsersWithRole(role: .proposer)
    }
    
    func getAllUsersWithRole(role: UserRole) -> MultiValueEncoded<Address> {
        let storageModule = StorageModule()
        
        var result: MultiValueEncoded<Address> = MultiValueEncoded()
        let numUsers = storageModule.userMapper.getUserCount()
        
        guard numUsers > 0 else {
            return result
        }
        
        let userMapper = storageModule.userMapper
        
        for userId in 1...numUsers {
            if storageModule.userIdToRole[userId] == role {
                if let address = userMapper.getUserAddress(id: userId) {
                    result = result.appended(value: address)
                }
            }
        }
        
        return result
    }
    
    @Callback public func performAsyncCallCallback() {
        PerformModule.performAsyncCallCallback()
    }
}

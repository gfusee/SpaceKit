import MultiversX

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
        let newNumBoardMembers = StateModule.addMultipleBoardMembers(newBoardMembers: board.toArray())
        let numProposers = StorageModule.numProposers
        
        require(
            newNumBoardMembers + numProposers > 0,
            "board cannot be empty on init, no-one would be able to propose"
        )
        
        require(
            quorum <= newNumBoardMembers,
            "quorum cannot exceed board size"
        )
        
        StorageModule.quorum = quorum
    }
    
    public func deposit() {}
    
    public func sign(actionId: UInt32) {
        let actionMapper = StorageModule.getActionMapper()
        
        require(
            !actionMapper.isItemEmptyUnchecked(index: actionId),
            "action does not exist"
        )
        
        let (callerId, callerRole) = StateModule.getCallerIdAndRole()
        require(
            callerRole.canSign(),
            "only board members can sign"
        )
        
        let actionSignerIdsMapper = StorageModule.getActionSignerIdsMapper(actionId: actionId)
        
        if !actionSignerIdsMapper.contains(value: callerId) {
            let _ = actionSignerIdsMapper.insert(value: callerId)
        }
    }
    
    public func unsign(actionId: UInt32) {
        let actionMapper = StorageModule.getActionMapper()
        
        require(
            !actionMapper.isItemEmptyUnchecked(index: actionId),
            "action does not exist"
        )
        
        let (callerId, callerRole) = StateModule.getCallerIdAndRole()
        require(
            callerRole.canSign(),
            "only board members can un-sign"
        )
        
        let actionSignerIdsMapper = StorageModule.getActionSignerIdsMapper(actionId: actionId)
        let _ = actionSignerIdsMapper.swapRemove(value: callerId)
    }
    
    public func discardAction(actionId: UInt32) {
        let (_, callerRole) = StateModule.getCallerIdAndRole()
        
        require(
            callerRole.canDiscardAction(),
            "only board members and proposers can discard actions"
        )
        
        require(
            self.getActionValidSignerCount(actionId: actionId) == 0,
            "cannot discard action with valid signatures"
        )
        
        self.clearAction(actionId: actionId)
    }
}

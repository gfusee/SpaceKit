import MultiversX

struct ProposeModule {
    package static func proposeAction(
        action: Action
    ) -> UInt32 {
        let (callerId, callerRole) = StateModule.getCallerIdAndRole()
        
        require(
            callerRole.canPropose(),
            "only board members and proposers can propose"
        )
        
        let actionId = StorageModule.getActionMapper().append(item: action)
        if callerRole.canSign() {
            // also sign
            // since the action is newly created, the caller can be the only signer
            let _ = StorageModule.getActionSignerIdsMapper(actionId: actionId).insert(value: callerId)
        }
        
        return actionId
    }
    
    package static func proposeAddBoardMember(
        boardMemberAddress: Address
    ) -> UInt32 {
        ProposeModule.proposeAction(action: .addBoardMember(boardMemberAddress))
    }
    
    package static func proposeAddProposer(
        proposerAddress: Address
    ) -> UInt32 {
        ProposeModule.proposeAction(action: .addProposer(proposerAddress))
    }
    
    package static func proposeRemoveUser(
        userAddress: Address
    ) -> UInt32 {
        ProposeModule.proposeAction(action: .removeUser(userAddress))
    }
    
    package static func proposeChangeQuorum(
        newQuorum: UInt32
    ) -> UInt32 {
        ProposeModule.proposeAction(action: .changeQuorum(newQuorum))
    }
    
    package static func prepareCallData(
        to: Address,
        egldAmount: BigUint,
        functionName: MXBuffer,
        functionArguments: MultiValueEncoded<MXBuffer>
    ) -> CallActionData {
        require(
            egldAmount > 0 || !functionName.isEmpty,
            "proposed action has no effect"
        )
        
        return CallActionData(
            to: to,
            egldAmount: egldAmount,
            endpointName: functionName,
            arguments: functionArguments.toArray()
        )
    }
    
    package static func proposeTransferExecute(
        to: Address,
        egldAmount: BigUint,
        functionName: MXBuffer,
        functionArguments: MultiValueEncoded<MXBuffer>
    ) -> UInt32 {
        let callData = ProposeModule.prepareCallData(
            to: to,
            egldAmount: egldAmount,
            functionName: functionName,
            functionArguments: functionArguments
        )
        
        return ProposeModule.proposeAction(action: .sendTransferExecute(callData))
    }
    
    package static func proposeAsyncCall(
        to: Address,
        egldAmount: BigUint,
        functionName: MXBuffer,
        functionArguments: MultiValueEncoded<MXBuffer>
    ) -> UInt32 {
        let callData = ProposeModule.prepareCallData(
            to: to,
            egldAmount: egldAmount,
            functionName: functionName,
            functionArguments: functionArguments
        )
        
        return ProposeModule.proposeAction(action: .sendAsyncCall(callData))
    }
}

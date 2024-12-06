import SpaceKit

@Controller struct ProposeController {
    public func proposeAddBoardMember(
        boardMemberAddress: Address
    ) -> UInt32 {
        self.proposeAction(action: .addBoardMember(boardMemberAddress))
    }
    
    public func proposeAddProposer(
        proposerAddress: Address
    ) -> UInt32 {
        self.proposeAction(action: .addProposer(proposerAddress))
    }
    
    public func proposeRemoveUser(
        userAddress: Address
    ) -> UInt32 {
        self.proposeAction(action: .removeUser(userAddress))
    }
    
    public func proposeChangeQuorum(
        newQuorum: UInt32
    ) -> UInt32 {
        self.proposeAction(action: .changeQuorum(newQuorum))
    }
    
    public func proposeTransferExecute(
        to: Address,
        egldAmount: BigUint,
        functionName: OptionalArgument<Buffer>,
        functionArguments: MultiValueEncoded<Buffer>
    ) -> UInt32 {
        let callData = self.prepareCallData(
            to: to,
            egldAmount: egldAmount,
            functionName: functionName.intoOptional() ?? Buffer(),
            functionArguments: functionArguments
        )
        
        return self.proposeAction(action: .sendTransferExecute(callData))
    }
    
    public func proposeAsyncCall(
        to: Address,
        egldAmount: BigUint,
        functionName: Buffer,
        functionArguments: MultiValueEncoded<Buffer>
    ) -> UInt32 {
        let callData = self.prepareCallData(
            to: to,
            egldAmount: egldAmount,
            functionName: functionName,
            functionArguments: functionArguments
        )
        
        return self.proposeAction(action: .sendAsyncCall(callData))
    }
    
    public func proposeSCDeployFromSource(
        amount: BigUint,
        source: Address,
        codeMetadata: CodeMetadata,
        arguments: MultiValueEncoded<Buffer>
    ) -> UInt32 {
        self.proposeAction(action:
            .scDeployFromSource(
                DeployFromSourceActionData(
                    amount: amount,
                    source: source,
                    codeMetadata: codeMetadata,
                    arguments: arguments.toArray()
                )
            )
        )
    }
    
    public func proposeSCUpgradeFromSource(
        scAddress: Address,
        amount: BigUint,
        source: Address,
        codeMetadata: CodeMetadata,
        arguments: MultiValueEncoded<Buffer>
    ) -> UInt32 {
        self.proposeAction(action:
            .scUpgradeFromSource(
                UpgradeFromSourceActionData(
                    scAddress: scAddress,
                    amount: amount,
                    source: source,
                    codeMetadata: codeMetadata,
                    arguments: arguments.toArray()
                )
            )
        )
    }
    
    private func proposeAction(
        action: Action
    ) -> UInt32 {
        let (callerId, callerRole) = StateController().getCallerIdAndRole()
        
        require(
            callerRole.canPropose(),
            "only board members and proposers can propose"
        )
        
        let storageController = StorageController()
        
        let actionId = storageController.getActionMapper().append(item: action)
        if callerRole.canSign() {
            // also sign
            // since the action is newly created, the caller can be the only signer
            let _ = storageController.getActionSignerIdsMapper(actionId: actionId).insert(value: callerId)
        }
        
        return actionId
    }
    
    private func prepareCallData(
        to: Address,
        egldAmount: BigUint,
        functionName: Buffer,
        functionArguments: MultiValueEncoded<Buffer>
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
}

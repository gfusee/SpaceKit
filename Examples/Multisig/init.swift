import SpaceKit

@Init func initialize(
    quorum: UInt32,
    board: MultiValueEncoded<Address>
) {
    var storageController = StorageController()
    
    let newNumBoardMembers = StateController().addMultipleBoardMembers(newBoardMembers: board.toArray())
    let numProposers = storageController.numProposers
    
    require(
        newNumBoardMembers + numProposers > 0,
        "board cannot be empty on init, no-one would be able to propose"
    )
    
    require(
        quorum <= newNumBoardMembers,
        "quorum cannot exceed board size"
    )
    
    storageController.quorum = quorum
}

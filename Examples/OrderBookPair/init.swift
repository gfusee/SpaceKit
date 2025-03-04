import SpaceKit

@Init func initialize(
    firstTokenIdentifier: TokenIdentifier,
    secondTokenIdentifier: TokenIdentifier
) {
    var storageController = StorageController()
    
    storageController.firstTokenIdentifier = firstTokenIdentifier
    storageController.secondTokenIdentifier = secondTokenIdentifier
}

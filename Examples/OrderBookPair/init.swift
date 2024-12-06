import SpaceKit

// TODO: use TokenIdentifier when available
@Init func initialize(
    firstTokenIdentifier: Buffer,
    secondTokenIdentifier: Buffer
) {
    var storageController = StorageController()
    
    storageController.firstTokenIdentifier = firstTokenIdentifier
    storageController.secondTokenIdentifier = secondTokenIdentifier
}

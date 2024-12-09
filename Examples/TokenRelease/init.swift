import SpaceKit

// TODO: use TokenIdentifier type once implemented
@Init func initialize(tokenIdentifier: Buffer) {
    // TODO: add a require to check that the token identifier is valid (same as the Rust contract)
    
    var controller = TokenReleaseController()
    
    controller.tokenIdentifier = tokenIdentifier
    controller.setupPeriodStatus = true
}

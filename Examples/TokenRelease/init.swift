import SpaceKit

@Init func initialize(tokenIdentifier: TokenIdentifier) {
    var controller = TokenReleaseController()
    
    require(
        tokenIdentifier.isValidESDT,
        "invalid token identifier"
    )
    controller.tokenIdentifier = tokenIdentifier
    controller.setupPeriodStatus = true
}

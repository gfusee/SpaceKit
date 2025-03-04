import SpaceKit

@Init func initialize(fee: BigUint, token: TokenIdentifier) {
    let controller = DigitalCashController()
    
    controller.whitelistFeeTokenLogic(fee: fee, token: token)
}

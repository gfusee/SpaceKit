import SpaceKit

@Init func initialize(fee: BigUint, token: Buffer) {
    let controller = DigitalCashController()
    
    controller.whitelistFeeTokenLogic(fee: fee, token: token)
}

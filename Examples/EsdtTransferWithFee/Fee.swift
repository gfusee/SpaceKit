import SpaceKit

let PERCENTAGE_DIVISOR: UInt32 = 10_000

@Codable public enum Fee {
    case unset
    case exactValue(TokenPayment)
    case percentage(UInt32)
}

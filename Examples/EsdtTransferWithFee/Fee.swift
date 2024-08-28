import Space

let PERCENTAGE_DIVISOR: UInt32 = 10_000

@Codable enum Fee {
    case unset
    case exactValue(TokenPayment)
    case percentage(UInt32)
}

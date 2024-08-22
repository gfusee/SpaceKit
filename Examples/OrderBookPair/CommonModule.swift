import MultiversX

let MAX_ORDERS_PER_USER: UInt32 = 100
let PERCENT_BASE_POINTS: UInt64 = 100_000
let FEE_PENALTY_INCREASE_PERCENT: UInt64 = 1_000

@Codable struct Payment {
    let tokenIdentifier: MXBuffer
    let amount: BigUint
}

@Codable struct Order {
    let id: UInt64
    let creator: Address
    let matchProvider: Address
    let inputAmount: BigUint
    let outputAmount: BigUint
    let feeConfig: FeeConfig
    let dealConfig: DealConfig
    let createEpoch: UInt64
    let orderType: OrderType
}

@Codable struct OrderInputParams {
    let amount: BigUint
    let matchProvider: Address
    let feeConfig: FeeConfig
    let dealConfig: DealConfig
}

@Codable enum OrderType {
    case buy
    case sell
}

@Codable enum FeeConfigEnum {
    case fixed
    case percent
}

@Codable struct FeeConfig {
    let feeType: FeeConfigEnum
    let fixedFee: BigUint
    let percentFee: UInt64
}

@Codable struct DealConfig {
    let matchProviderPercent: UInt64
}

struct CommonModule {
    static func newOrder(
        id: UInt64,
        payment: Payment,
        params: OrderInputParams,
        orderType: OrderType
    ) -> Order {
        return Order(
            id: id,
            creator: Message.caller,
            matchProvider: params.matchProvider,
            inputAmount: payment.amount,
            outputAmount: params.amount,
            feeConfig: params.feeConfig,
            dealConfig: params.dealConfig,
            createEpoch: Blockchain.getBlockEpoch(),
            orderType: orderType
        )
    }
    
    static func calculateFeeAmount(
        amount: BigUint,
        feeConfig: FeeConfig
    ) -> BigUint {
        return switch feeConfig.feeType {
        case .fixed:
            feeConfig.fixedFee
        case .percent:
            amount * BigUint(value: feeConfig.percentFee) / BigUint(value: PERCENT_BASE_POINTS)
        }
    }
    
    static func calculateAmountAfterFee(
        amount: BigUint,
        feeConfig: FeeConfig
    ) -> BigUint {
        return amount - CommonModule.calculateFeeAmount(amount: amount, feeConfig: feeConfig)
    }
}

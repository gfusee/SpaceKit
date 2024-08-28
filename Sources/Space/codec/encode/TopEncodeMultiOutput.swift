public protocol TopEncodeMultiOutput {
    mutating func pushSingleValue<TE: TopEncode>(arg: TE)
}

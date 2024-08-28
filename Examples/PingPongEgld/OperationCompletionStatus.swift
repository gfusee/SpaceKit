import Space

@Codable public enum OperationCompletionStatus {
    case completed
    case interruptedBeforeOutOfGas
}

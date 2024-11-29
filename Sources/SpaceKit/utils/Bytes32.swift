package typealias Bytes32 = (
    UInt8, UInt8, UInt8, UInt8,
    UInt8, UInt8, UInt8, UInt8,
    UInt8, UInt8, UInt8, UInt8,
    UInt8, UInt8, UInt8, UInt8,
    UInt8, UInt8, UInt8, UInt8,
    UInt8, UInt8, UInt8, UInt8,
    UInt8, UInt8, UInt8, UInt8,
    UInt8, UInt8, UInt8, UInt8
)

package func getZeroedBytes32() -> Bytes32 {
    return (
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        0, 0
    )
}

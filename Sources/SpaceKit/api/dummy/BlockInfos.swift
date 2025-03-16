#if !WASM
package let RANDOM_SEED_LENGTH = 48

package struct BlockInfos {
    var nonce: UInt64
    var timestamp: UInt64
    var round: UInt64
    var epoch: UInt64
    var randomSeed: Data = Data(count: RANDOM_SEED_LENGTH)
}
#endif

#if !WASM
import Foundation

package class WorldState {
    package var storageForContractAddress: [String : [Data : Data]] = [:]
}

#endif

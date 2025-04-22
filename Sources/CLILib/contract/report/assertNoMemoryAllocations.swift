import Foundation
import WasmKit

let KNOWN_ALLOC_IMPORTS = ["free"]

func assertNoMemoryAllocations(wasmPath: String) throws(CLIError) {
    let module = try parseWasmOrThrow(wasmPath: wasmPath)
    
    for moduleImport in module.imports {
        if KNOWN_ALLOC_IMPORTS.contains(moduleImport.name) {
            throw .report(.hasMemoryAllocations(path: wasmPath))
        }
    }
}

fileprivate func parseWasmOrThrow(wasmPath: String) throws(CLIError) -> Module {
    do {
        return try parseWasm(filePath: .init(wasmPath))
    } catch {
        throw .report(.cannotParseWasm(path: wasmPath))
    }
}

#if !WASM
#if os(macOS)
import Darwin // For macOS
#elseif os(Linux)
import Glibc // For Linux

#if !canImport(dlfcn)
let RTLD_LAZY = Int32(0x0001) // Fallback definition for RTLD_LAZY
#endif

#elseif os(Windows)
import WinSDK // For Windows
#endif

public func dynamicInitSymbolCalling() {
#if os(macOS) || os(Linux)
    // Use dlsym and dlopen for macOS and Linux
    if let handle = dlopen(nil, RTLD_LAZY), let symbol = dlsym(handle, "__swiftVMInitialize") {
        typealias InitializeType = @convention(c) () -> Void
        unsafeBitCast(symbol, to: InitializeType.self)()
        dlclose(handle) // Close the handle after use
    }
#elseif os(Windows)
    // Use LoadLibrary and GetProcAddress for Windows
    if let handle = LoadLibraryA(nil), let symbol = GetProcAddress(handle, "__swiftVMInitialize") {
        typealias InitializeType = @convention(c) () -> Void
        unsafeBitCast(symbol, to: InitializeType.self)()
        FreeLibrary(handle) // Release the handle after use
    }
#endif
}
#endif

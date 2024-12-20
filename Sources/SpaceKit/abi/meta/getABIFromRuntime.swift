#if !WASM
public func getABIFromRuntime(
    name: String,
    version: String
) -> ABI {
    let constructor = getABIExportableConstructor() ?? ABIConstructor(
        inputs: [],
        outputs: []
    )
    return ABI(
        buildInfo: ABIBuildInfo(
            framework: ABIBuildInfoFramework(
                name: "SpaceKit",
                version: version
            )
        ),
        name: name,
        constructor: constructor,
        endpoints: getAllABIExportableEndpoints(),
        types: getAllABIExportableTypes()
    )
}
#endif

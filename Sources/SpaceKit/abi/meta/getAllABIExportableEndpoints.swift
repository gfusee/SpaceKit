#if !WASM
public func getAllABIExportableEndpoints() -> [ABIEndpoint] {
    var endpoints: [ABIEndpoint] = []

    let allABITypeExtractorsClasses = Runtime.classes(conformTo: ABIEndpointsExtractor.Type.self)
    for classIndice in allABITypeExtractorsClasses.indices {
        let classType: AnyClass = allABITypeExtractorsClasses[classIndice]
        let controllerType = classType as! (any ABIEndpointsExtractor.Type)
        
        let fullClassName = NSStringFromClass(classType)
        guard !fullClassName.starts(with: "SpaceKit") else {
            continue
        }
        
        endpoints.append(contentsOf: controllerType._extractABIEndpoints)
    }
    
    return endpoints
}
#endif

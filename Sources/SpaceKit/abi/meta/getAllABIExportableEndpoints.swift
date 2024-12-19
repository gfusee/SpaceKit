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

private class Runtime {
    public static func allClasses() -> [AnyClass] {
        let numberOfClasses = Int(objc_getClassList(nil, 0))
        if numberOfClasses > 0 {
            let classesPtr = UnsafeMutablePointer<AnyClass>.allocate(capacity: numberOfClasses)
            let autoreleasingClasses = AutoreleasingUnsafeMutablePointer<AnyClass>(classesPtr)
            let count = objc_getClassList(autoreleasingClasses, Int32(numberOfClasses))
            assert(numberOfClasses == count)
            defer { classesPtr.deallocate() }
            let classes = (0 ..< numberOfClasses).map { classesPtr[$0] }
            return classes
        }
        return []
    }
    
    public static func classes<T>(conformTo: T.Type) -> [AnyClass] {
        return self.allClasses().filter { $0 is T }
    }
}
#endif

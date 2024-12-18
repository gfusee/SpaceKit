#if !WASM
public func getAllABIExportableTypes() -> [String : ABIType] {
    var types: [String : ABIType] = [:]

    let allABITypeExtractorsClasses = Runtime.classes(conformTo: ABITypeExtractor.Type.self)
    for classIndice in allABITypeExtractorsClasses.indices {
        let classType: AnyClass = allABITypeExtractorsClasses[classIndice]
        let codableType = classType as! (any ABITypeExtractor.Type)
        
        if let abiType = codableType._extractABIType {
            let fullClassName = NSStringFromClass(classType)
            if fullClassName.starts(with: "SpaceKit") {
                let spaceKitExportableCodable = [
                    String(describing: TokenPayment.self)
                ]
                
                guard spaceKitExportableCodable.contains(codableType._abiTypeName) else {
                    continue
                }
            }
            
            types[codableType._abiTypeName] = abiType
        }
    }
    
    return types
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

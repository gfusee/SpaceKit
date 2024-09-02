import Workspace
import Basics
import PackageModel
import PackageGraph

fileprivate struct DummyError: Error {}

// TODO: automate this with a CI or by cloning the repo and retrieving the tags
let versionToHash: [String : String] = [
    "0.0.1" : "846262f7d32cc90548a2317edb45fcb8c1b989b1"
]

fileprivate func retrieveManifest(sourcePackagePath: String) throws(CLIError) -> Manifest {
    let sourcePackageAbsolutePath: AbsolutePath
    let workspace: Workspace
    do {
        sourcePackageAbsolutePath = try AbsolutePath(validating: sourcePackagePath)
        workspace = try Workspace(forRootPackage: sourcePackageAbsolutePath)
        
        let observability = ObservabilitySystem({ print("\($0): \($1)") })
        var result: Result<Manifest, any Error>? = nil
        workspace.loadRootManifest(at: sourcePackageAbsolutePath, observabilityScope: observability.topScope) { result = $0 }
        
        while result == nil {}
        
        switch result! {
        case .success(let manifest):
            return manifest
        case .failure(let error):
            throw DummyError()
        }
    } catch {
        let manifestPath = "\(sourcePackagePath)/Package.swift"
        throw .manifest(.cannotReadManifest(path: manifestPath))
    }
}

/// Generates the code of a Package.swift containing the contract target, ready for WASM compilation
func generateWASMPackage(sourcePackagePath: String) throws(CLIError) -> String {
    let manifestPath = "\(sourcePackagePath)/Package.swift"
    let packageDependencies = (try retrieveManifest(sourcePackagePath: sourcePackagePath)).dependencies
    print(packageDependencies)
    let spaceDependency = packageDependencies.first { $0.nameForModuleDependencyResolutionOnly == "Space" }
    guard let spaceDependency = spaceDependency else {
        throw .manifest(.spaceDependencyNotFound(manifestPath: manifestPath))
    }
    
    let spaceRequirements: PackageRequirement
    do {
        spaceRequirements = try spaceDependency.toConstraintRequirement()
    } catch {
        throw .manifest(.cannotReadDependencyRequirement(manifestPath: manifestPath, dependency: "Space"))
    }
    
    guard case .versionSet(.exact(let version)) = spaceRequirements else {
        throw .manifest(.spaceDependencyShouldHaveExactVersion(manifestPath: manifestPath))
    }
    
    let versionString = "\(version.major).\(version.minor).\(version.patch)"
    guard let hash = versionToHash[versionString] else {
        throw .manifest(.invalidSpaceVersion(
            manifestPath: manifestPath,
            versionFound: versionString,
            validVersions: Array(versionToHash.keys)
        ))
    }
    
    print("hash: \(hash)")
    fatalError()
}

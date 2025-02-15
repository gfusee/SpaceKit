import Workspace
import Basics
import PackageModel
import PackageGraph

fileprivate struct DummyError: Error {}

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
        case .failure(_):
            throw DummyError()
        }
    } catch {
        let manifestPath = "\(sourcePackagePath)/Package.swift"
        print(error.localizedDescription) // TODO: temp, delete when --verbose is here
        throw .manifest(.cannotReadManifest(path: manifestPath))
    }
}

/// Generates the code of a Package.swift containing the contract target, ready for WASM compilation
func generateWASMPackage(
    sourcePackagePath: String,
    target: String,
    overrideSpaceKitHash: String?
) async throws(CLIError) -> (generatedPackage: String, spaceKitHash: String, versionFound: String) {
    let manifestPath = "\(sourcePackagePath)/Package.swift"
    let manifest = try retrieveManifest(sourcePackagePath: sourcePackagePath)
    let packageDependencies = manifest.dependencies
    let spaceKitDependency = packageDependencies.first { print($0.nameForModuleDependencyResolutionOnly); return $0.nameForModuleDependencyResolutionOnly.lowercased(with: .current) == "spacekit" }
    guard let spaceKitDependency = spaceKitDependency else {
        throw .manifest(.spaceKitDependencyNotFound(manifestPath: manifestPath))
    }
    
    guard case .sourceControl(let spaceKitSourceControlInfo) = spaceKitDependency else {
        throw .manifest(.spaceKitDependencyShouldBeAGitRepository(manifestPath: manifestPath))
    }
    
    let spaceKitUrl: String
    switch spaceKitSourceControlInfo.location {
    case .local(let setting):
        spaceKitUrl = setting.pathString
    case .remote(let settings):
        spaceKitUrl = settings.absoluteString
    }
    
    let spaceKitRequirements: PackageRequirement
    do {
        spaceKitRequirements = try spaceKitDependency.toConstraintRequirement()
    } catch {
        throw .manifest(.cannotReadDependencyRequirement(manifestPath: manifestPath, dependency: "SpaceKit"))
    }
    
    let hash: String
    let versionFound: String
    
    if let overrideSpaceKitHash = overrideSpaceKitHash {
        hash = overrideSpaceKitHash
        versionFound = "0.0.0"
    } else {
        guard case .versionSet(.exact(let version)) = spaceKitRequirements else {
            throw .manifest(.spaceKitDependencyShouldHaveExactVersion(manifestPath: manifestPath))
        }
        
        let versionString = "\(version.major).\(version.minor).\(version.patch)"
        
        let knownHash = (try await runInDocker(
            volumeURLs: nil,
            commands: [
                "./get_tag_hash.sh \(versionString)",
            ],
            showDockerLogs: false
        )).trimmingCharacters(in: .whitespacesAndNewlines)
        
        hash = knownHash
        versionFound = versionString
    }
    
    guard hash != "Tag not found" else {
        throw .manifest(.invalidSpaceKitVersion(
            manifestPath: manifestPath,
            versionFound: versionFound
        ))
    }
    
    guard let targetInfo = manifest.targetMap[target] else {
        throw .manifest(.targetNotFound(manifestPath: sourcePackagePath, target: target))
    }
    
    let targetPath = if let targetPath = targetInfo.path {
        "path: \"\(targetPath)\","
    } else {
        ""
    }
    
    let packageCode = """
    // swift-tools-version: 5.10
    // The swift-tools-version declares the minimum version of Swift required to build this package.

    import PackageDescription

    let package = Package(
        name: "\(target)Wasm",
        platforms: [
            .macOS(.v14)
        ],
        products: [],
        dependencies: [
            .package(url: "\(spaceKitUrl)", revision: "\(hash)")
        ],
        targets: [
            // Targets are the basic building blocks of a package, defining a module or a test suite.
            // Targets can depend on other targets in this package and products from dependencies.
            .target(
                name: "\(target)",
                dependencies: [
                    .product(name: "SpaceKit", package: "SpaceKit")
                ],
                \(targetPath)
                swiftSettings: [
                    .unsafeFlags([
                        "-gnone",
                        "-Osize",
                        "-enable-experimental-feature",
                        "Extern",
                        "-enable-experimental-feature",
                        "Embedded",
                        "-Xcc",
                        "-fdeclspec",
                        "-whole-module-optimization",
                        "-D",
                        "WASM",
                        "-disable-stack-protector"
                    ])
                ]
            )
        ]
    )
    """
    
    return (
        generatedPackage: packageCode,
        spaceKitHash: hash,
        versionFound: versionFound
    )
}

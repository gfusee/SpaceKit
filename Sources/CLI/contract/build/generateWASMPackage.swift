import Foundation

fileprivate struct DummyError: Error {}

fileprivate func retrieveManifest(
    volumeURLs: [(host: URL, dest: URL)]
) async throws(CLIError) -> Manifest {
    let command = "cd \(PROJECT_DOCKER_DEST_PATH) && swift package dump-package"
    
    let resultJSONString = try await runInDocker(
        volumeURLs: volumeURLs,
        commands: [
            "echo \"Test??\" && cd /app && ls && echo \"Test2??\"",
            command
        ],
        showDockerLogs: false
    )
    
    guard let resultJSONData = resultJSONString.data(using: .utf8) else {
        throw .manifest(.cannotReadJSONManifestAsUTF8(json: resultJSONString))
    }
    
    guard let manifest = try? JSONDecoder().decode(Manifest.self, from: resultJSONData) else {
        throw .manifest(.cannotDecodeManifest(json: resultJSONString))
    }
    
    return manifest
}

/// Generates the code of a Package.swift containing the contract target, ready for WASM compilation
func generateWASMPackage(
    volumeURLs: [(host: URL, dest: URL)],
    target: String,
    overrideSpaceKitHash: String?,
    shouldUseLocalSpaceKit: Bool
) async throws(CLIError) -> (generatedPackage: String, spaceKitDependencyDeclaration: String, versionFound: String?) {
    let manifest = try await retrieveManifest(volumeURLs: volumeURLs)
    let packageDependencies = manifest.dependencies
    let spaceKitDependency = packageDependencies.first { dependency in
        let dependencyName = switch dependency.kind {
        case .sourceControl(let settings):
            settings.first?.identity ?? ""
        case .fileSystem(let settings):
            settings.first?.identity ?? ""
        case  .unknown:
            ""
        }
        
        return dependencyName.lowercased() == "spacekit"
    }
    
    guard let spaceKitDependency = spaceKitDependency else {
        throw .manifest(.spaceKitDependencyNotFound)
    }
    
    guard case .sourceControl(let spaceKitSourceControlInfoArray) = spaceKitDependency.kind else {
        throw .manifest(.spaceKitDependencyShouldBeAGitRepository)
    }
    
    guard let spaceKitSourceControlInfo = spaceKitSourceControlInfoArray.first else {
        throw .manifest(.spaceKitDependencyShouldHaveAtLeastOneSourceControlInfo)
    }
    
    let spaceKitUrl: String
    switch spaceKitSourceControlInfo.location {
    case .local(let paths):
        guard let path = paths.first else {
            throw .manifest(.spaceKitDependencyLocalGitShouldHaveAtLeastOnePath)
        }
        
        spaceKitUrl = path
    case .remote(let settings):
        guard let settings = settings.first else {
            throw .manifest(.spaceKitDependencyRemoteGitShouldHaveAtLeastOneSettings)
        }
        
        spaceKitUrl = settings.urlString
    default:
        throw .manifest(.spaceKitDependencyUnknownLocationType)
    }
    
    let versionFound: String?
    let spaceKitDependencyDeclaration: String
    
    if let overrideSpaceKitHash = overrideSpaceKitHash {
        versionFound = nil
        spaceKitDependencyDeclaration = """
            .package(url: "\(spaceKitUrl)", revision: "\(overrideSpaceKitHash)")
            """
    } else if shouldUseLocalSpaceKit {
        versionFound = nil
        spaceKitDependencyDeclaration = """
            .package(path: "/SpaceKit")
            """
    } else {
        guard case .exact(let versions) = spaceKitSourceControlInfo.requirement else {
            throw .manifest(.spaceKitDependencyShouldHaveExactVersion)
        }
        
        guard let version = versions.first else {
            throw .manifest(.spaceKitDependencyExactVersionShouldHaveAtLeastOneElement)
        }
        
        let knownHash = (try await runInDocker(
            volumeURLs: [],
            commands: [
                "./get_tag_hash.sh \(version)",
            ],
            showDockerLogs: false
        )).trimmingCharacters(in: .whitespacesAndNewlines)
        
        versionFound = version
        
        guard knownHash != "Tag not found" else {
            throw .manifest(.invalidSpaceKitVersion(
                versionFound: versionFound ?? "nil"
            ))
        }
        
        spaceKitDependencyDeclaration = """
            .package(url: "\(spaceKitUrl)", revision: "\(knownHash)")
            """
    }
    
    guard let targetInfo = manifest.targets.first(where: { $0.name == target }) else {
        throw .manifest(.targetNotFound(target: target))
    }
    
    let targetPath = "path: \"\(targetInfo.path)\","
    
    let packageCode = """
    // swift-tools-version: 6.0
    // The swift-tools-version declares the minimum version of Swift required to build this package.

    import PackageDescription

    let package = Package(
        name: "\(target)Wasm",
        platforms: [
            .macOS(.v14)
        ],
        products: [],
        dependencies: [
            \(spaceKitDependencyDeclaration)
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
        spaceKitDependencyDeclaration: spaceKitDependencyDeclaration,
        versionFound: versionFound
    )
}

enum ManifestError: Error, CustomStringConvertible {
    case cannotReadManifest(path: String)
    case spaceDependencyNotFound(manifestPath: String)
    case cannotReadDependencyRequirement(manifestPath: String, dependency: String)
    case spaceDependencyShouldHaveExactVersion(manifestPath: String)
    case spaceDependencyShouldBeAGitRepository(manifestPath: String)
    case invalidSpaceVersion(manifestPath: String, versionFound: String, validVersions: [String])
    case targetNotFound(manifestPath: String, target: String)
    
    var description: String {
        switch self {
        case .cannotReadManifest(let path):
            """
            Cannot read the Package.swift at \(path).
            Check that the file exists and is well-formed.
            """
        case .spaceDependencyNotFound(let manifestPath):
            """
            The manifest \(manifestPath) doesn't contain the Space dependency.
            """
        case .cannotReadDependencyRequirement(let manifestPath, let dependency):
            """
            Cannot read the requirements for the following dependency: \(dependency) in \(manifestPath).
            Please make sure it has requirements, such as the version number.
            """
        case .spaceDependencyShouldBeAGitRepository(let manifestPath):
            """
            The dependency "Space" in \(manifestPath) should has be a Git repository, local or remote.
            """
        case .spaceDependencyShouldHaveExactVersion(let manifestPath):
            """
            The dependency "Space" in \(manifestPath) should has be specified by it's exact version.
            """
        case .invalidSpaceVersion(let manifestPath, let versionFound, let validVersions):
            """
            Invalid version found for the Space dependency in \(manifestPath).
            
            Version found: \(versionFound)
            Available versions:
            
            - \(validVersions.joined(separator: "\n- "))
            """
        case .targetNotFound(let manifestPath, let target):
            """
            Target \(target) not found in \(manifestPath).
            """
        }
    }
}

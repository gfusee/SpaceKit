import XCTest
@testable import SpaceKitCLI

final class CLIManifestDecodingTests: XCTestCase {
    func testDecodeManifestRemoteGitSpaceKitDependency() throws {
        let jsonString = """
        {
          "cLanguageStandard" : null,
          "cxxLanguageStandard" : null,
          "dependencies" : [
            {
              "sourceControl" : [
                {
                  "identity" : "spacekit",
                  "location" : {
                    "remote" : [
                      {
                        "urlString" : "https://github.com/gfusee/SpaceKit.git"
                      }
                    ]
                  },
                  "productFilter" : null,
                  "requirement" : {
                    "exact" : [
                      "0.2.2"
                    ]
                  }
                }
              ]
            }
          ],
          "name" : "Test",
          "packageKind" : {
            "root" : [
              "/Users/quentin/IdeaProjects/Test"
            ]
          },
          "pkgConfig" : null,
          "platforms" : [
            {
              "options" : [

              ],
              "platformName" : "macos",
              "version" : "14.0"
            }
          ],
          "products" : [
            {
              "name" : "Test",
              "settings" : [

              ],
              "targets" : [
                "Test"
              ],
              "type" : {
                "library" : [
                  "automatic"
                ]
              }
            }
          ],
          "providers" : null,
          "swiftLanguageVersions" : null,
          "targets" : [
            {
              "dependencies" : [
                {
                  "product" : [
                    "SpaceKit",
                    "SpaceKit",
                    null,
                    null
                  ]
                }
              ],
              "exclude" : [

              ],
              "name" : "Test",
              "packageAccess" : true,
              "path" : "Contracts/Test/Sources",
              "resources" : [

              ],
              "settings" : [

              ],
              "type" : "regular"
            },
            {
              "dependencies" : [
                {
                  "byName" : [
                    "Test",
                    null
                  ]
                },
                {
                  "product" : [
                    "SpaceKitTesting",
                    "SpaceKit",
                    null,
                    null
                  ]
                }
              ],
              "exclude" : [

              ],
              "name" : "TestTests",
              "packageAccess" : true,
              "path" : "Contracts/Test/Tests/TestTests",
              "resources" : [

              ],
              "settings" : [

              ],
              "type" : "test"
            }
          ],
          "toolsVersion" : {
            "_version" : "5.10.0"
          }
        }
        """
        
        let jsonData = jsonString.data(using: .utf8)!
        
        let decodedManifest = try! JSONDecoder().decode(Manifest.self, from: jsonData)
        
        guard let spaceKitDependency = decodedManifest.dependencies.first(where: { dependency in
            switch dependency.kind {
            case .sourceControl(let settings):
                return settings.first!.identity.lowercased() == "spacekit"
            default:
                return false
            }
        }) else {
            XCTFail()
            return
        }
        
        switch spaceKitDependency.kind {
        case .sourceControl(let settings):
            switch settings.first!.location {
            case .remote(let remoteSettings):
                XCTAssertEqual(remoteSettings.first!.urlString, "https://github.com/gfusee/SpaceKit.git")
            default:
                XCTFail()
            }
        default:
            XCTFail()
        }
    }
    
    func testDecodeManifestLocalGitSpaceKitDependency() throws {
        let jsonString = """
        {
          "cLanguageStandard" : null,
          "cxxLanguageStandard" : null,
          "dependencies" : [
            {
              "sourceControl" : [
                {
                  "identity" : "spacekit",
                  "location" : {
                    "local" : [
                      "/Users/quentin/IdeaProjects/SpaceKit"
                    ]
                  },
                  "productFilter" : null,
                  "requirement" : {
                    "exact" : [
                      "0.2.2"
                    ]
                  }
                }
              ]
            }
          ],
          "name" : "Test",
          "packageKind" : {
            "root" : [
              "/Users/quentin/IdeaProjects/Test"
            ]
          },
          "pkgConfig" : null,
          "platforms" : [
            {
              "options" : [

              ],
              "platformName" : "macos",
              "version" : "14.0"
            }
          ],
          "products" : [
            {
              "name" : "Test",
              "settings" : [

              ],
              "targets" : [
                "Test"
              ],
              "type" : {
                "library" : [
                  "automatic"
                ]
              }
            }
          ],
          "providers" : null,
          "swiftLanguageVersions" : null,
          "targets" : [
            {
              "dependencies" : [
                {
                  "product" : [
                    "SpaceKit",
                    "SpaceKit",
                    null,
                    null
                  ]
                }
              ],
              "exclude" : [

              ],
              "name" : "Test",
              "packageAccess" : true,
              "path" : "Contracts/Test/Sources",
              "resources" : [

              ],
              "settings" : [

              ],
              "type" : "regular"
            },
            {
              "dependencies" : [
                {
                  "byName" : [
                    "Test",
                    null
                  ]
                },
                {
                  "product" : [
                    "SpaceKitTesting",
                    "SpaceKit",
                    null,
                    null
                  ]
                }
              ],
              "exclude" : [

              ],
              "name" : "TestTests",
              "packageAccess" : true,
              "path" : "Contracts/Test/Tests/TestTests",
              "resources" : [

              ],
              "settings" : [

              ],
              "type" : "test"
            }
          ],
          "toolsVersion" : {
            "_version" : "5.10.0"
          }
        }
        """
        
        let jsonData = jsonString.data(using: .utf8)!
        
        let decodedManifest = try! JSONDecoder().decode(Manifest.self, from: jsonData)
        
        guard let spaceKitDependency = decodedManifest.dependencies.first(where: { dependency in
            switch dependency.kind {
            case .sourceControl(let settings):
                return settings.first!.identity.lowercased() == "spacekit"
            default:
                return false
            }
        }) else {
            XCTFail()
            return
        }
        
        switch spaceKitDependency.kind {
        case .sourceControl(let settings):
            switch settings.first!.location {
            case .local(let localPaths):
                XCTAssertEqual(localPaths.first!, "/Users/quentin/IdeaProjects/SpaceKit")
            default:
                XCTFail()
            }
        default:
            XCTFail()
        }
    }
    
    func testDecodeManifestLocalFolderSpaceKitDependency() throws {
        let jsonString = """
        {
          "cLanguageStandard" : null,
          "cxxLanguageStandard" : null,
          "dependencies" : [
            {
              "fileSystem" : [
                {
                  "identity" : "spacekit",
                  "path" : "/Users/quentin/IdeaProjects/SpaceKit",
                  "productFilter" : null
                }
              ]
            }
          ],
          "name" : "Test",
          "packageKind" : {
            "root" : [
              "/Users/quentin/IdeaProjects/Test"
            ]
          },
          "pkgConfig" : null,
          "platforms" : [
            {
              "options" : [

              ],
              "platformName" : "macos",
              "version" : "14.0"
            }
          ],
          "products" : [
            {
              "name" : "Test",
              "settings" : [

              ],
              "targets" : [
                "Test"
              ],
              "type" : {
                "library" : [
                  "automatic"
                ]
              }
            }
          ],
          "providers" : null,
          "swiftLanguageVersions" : null,
          "targets" : [
            {
              "dependencies" : [
                {
                  "product" : [
                    "SpaceKit",
                    "SpaceKit",
                    null,
                    null
                  ]
                }
              ],
              "exclude" : [

              ],
              "name" : "Test",
              "packageAccess" : true,
              "path" : "Contracts/Test/Sources",
              "resources" : [

              ],
              "settings" : [

              ],
              "type" : "regular"
            },
            {
              "dependencies" : [
                {
                  "byName" : [
                    "Test",
                    null
                  ]
                },
                {
                  "product" : [
                    "SpaceKitTesting",
                    "SpaceKit",
                    null,
                    null
                  ]
                }
              ],
              "exclude" : [

              ],
              "name" : "TestTests",
              "packageAccess" : true,
              "path" : "Contracts/Test/Tests/TestTests",
              "resources" : [

              ],
              "settings" : [

              ],
              "type" : "test"
            }
          ],
          "toolsVersion" : {
            "_version" : "5.10.0"
          }
        }
        """
        
        let jsonData = jsonString.data(using: .utf8)!
        
        let decodedManifest = try! JSONDecoder().decode(Manifest.self, from: jsonData)
        
        guard let spaceKitDependency = decodedManifest.dependencies.first(where: { dependency in
            switch dependency.kind {
            case .fileSystem(let settings):
                return settings.first!.identity.lowercased() == "spacekit"
            default:
                return false
            }
        }) else {
            XCTFail()
            return
        }
        
        switch spaceKitDependency.kind {
        case .fileSystem(let settings):
            XCTAssertEqual(settings.first!.path, "/Users/quentin/IdeaProjects/SpaceKit")
        default:
            XCTFail()
        }
    }
    
    func testDecodeManifestGetTestTarget() throws {
        let jsonString = """
        {
          "cLanguageStandard" : null,
          "cxxLanguageStandard" : null,
          "dependencies" : [
            {
              "sourceControl" : [
                {
                  "identity" : "spacekit",
                  "location" : {
                    "remote" : [
                      {
                        "urlString" : "https://github.com/gfusee/SpaceKit.git"
                      }
                    ]
                  },
                  "productFilter" : null,
                  "requirement" : {
                    "exact" : [
                      "0.2.2"
                    ]
                  }
                }
              ]
            }
          ],
          "name" : "Test",
          "packageKind" : {
            "root" : [
              "/Users/quentin/IdeaProjects/Test"
            ]
          },
          "pkgConfig" : null,
          "platforms" : [
            {
              "options" : [

              ],
              "platformName" : "macos",
              "version" : "14.0"
            }
          ],
          "products" : [
            {
              "name" : "Test",
              "settings" : [

              ],
              "targets" : [
                "Test"
              ],
              "type" : {
                "library" : [
                  "automatic"
                ]
              }
            }
          ],
          "providers" : null,
          "swiftLanguageVersions" : null,
          "targets" : [
            {
              "dependencies" : [
                {
                  "product" : [
                    "SpaceKit",
                    "SpaceKit",
                    null,
                    null
                  ]
                }
              ],
              "exclude" : [

              ],
              "name" : "Test",
              "packageAccess" : true,
              "path" : "Contracts/Test/Sources",
              "resources" : [

              ],
              "settings" : [

              ],
              "type" : "regular"
            },
            {
              "dependencies" : [
                {
                  "byName" : [
                    "Test",
                    null
                  ]
                },
                {
                  "product" : [
                    "SpaceKitTesting",
                    "SpaceKit",
                    null,
                    null
                  ]
                }
              ],
              "exclude" : [

              ],
              "name" : "TestTests",
              "packageAccess" : true,
              "path" : "Contracts/Test/Tests/TestTests",
              "resources" : [

              ],
              "settings" : [

              ],
              "type" : "test"
            }
          ],
          "toolsVersion" : {
            "_version" : "5.10.0"
          }
        }
        """
        
        let jsonData = jsonString.data(using: .utf8)!
        
        let decodedManifest = try! JSONDecoder().decode(Manifest.self, from: jsonData)
        
        guard let testTarget = decodedManifest.targets.first(where: { $0.name == "Test" }) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(testTarget.path, "Contracts/Test/Sources")
    }
}

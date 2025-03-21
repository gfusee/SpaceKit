import SpaceKitTesting

@Controller public struct RandomController {
    public func getRandomUInt8(min: UInt8, max: UInt8) -> UInt8 {
        Randomness.nextUInt8InRange(min: min, max: max)
    }
    
    public func getTwoRandomUInt8(min: UInt8, max: UInt8) -> Vector<UInt8> {
        var result: Vector<UInt8> = Vector()
        
        result = result.appended(Randomness.nextUInt8InRange(min: min, max: max))
        result = result.appended(Randomness.nextUInt8InRange(min: min, max: max))
        
        return result
    }
    
    public func getRandomUInt32(min: UInt32, max: UInt32) -> UInt32 {
        Randomness.nextUInt32InRange(min: min, max: max)
    }
    
    public func getRandomUInt64(min: UInt64, max: UInt64) -> UInt64 {
        Randomness.nextUInt64InRange(min: min, max: max)
    }
}

final class RandomTests: ContractTestCase {
    
    override var initialAccounts: [WorldAccount] {
        [
            WorldAccount(
                address: "contract",
                controllers: [
                    RandomController.self
                ]
            )
        ]
    }
    
    func testGetRandomUInt8ForZeroToOne() throws {
        let controller = self.instantiateController(RandomController.self, for: "contract")!
        
        let result = try controller.getRandomUInt8(min: 0, max: 1)
        
        XCTAssertEqual(result, 0)
    }
    
    func testGetRandomUInt8ForRange() throws {
        let controller = self.instantiateController(RandomController.self, for: "contract")!
        
        let randomSeed: [UInt8] = Array(1...48).map { UInt8($0) }
        self.setBlockInfos(randomSeed: Data(randomSeed))
        
        let result = try controller.getRandomUInt8(min: 100, max: 200)
        
        XCTAssertTrue(result >= 100 && result <= 200)
    }
    
    func testGetRandomUInt8ForZeroToMax() throws {
        let controller = self.instantiateController(RandomController.self, for: "contract")!
        
        let randomSeed: [UInt8] = Array(1...48).map { UInt8($0) }
        self.setBlockInfos(randomSeed: Data(randomSeed))
        
        let result = try controller.getRandomUInt8(min: 0, max: UInt8.max)
        
        XCTAssertEqual(result, 250)
    }
    
    func testGetMultipleRandomUInt8ForZeroToMax() throws {
        let controller = self.instantiateController(RandomController.self, for: "contract")!
        
        let randomSeed: [UInt8] = Array(1...48).map { UInt8($0) }
        self.setBlockInfos(randomSeed: Data(randomSeed))
        
        let result = try controller.getTwoRandomUInt8(min: 0, max: UInt8.max)
        
        XCTAssertEqual(result, [250, 37])
    }

    func testGetRandomUInt8ForZeroToMaxAnotherSeed() throws {
        let controller = self.instantiateController(RandomController.self, for: "contract")!
        
        let randomSeed: [UInt8] = Array(1...48).map { UInt8($0) * 2 }
        self.setBlockInfos(randomSeed: Data(randomSeed))
        
        let result = try controller.getRandomUInt8(min: 0, max: UInt8.max)
        
        XCTAssertEqual(result, 27)
    }
    
    func testGetRandomUInt32ForZeroToOne() throws {
        let controller = self.instantiateController(RandomController.self, for: "contract")!
        
        let result = try controller.getRandomUInt32(min: 0, max: 1)
        
        XCTAssertEqual(result, 0)
    }
    
    func testGetRandomUInt32ForZeroToMax() throws {
        let controller = self.instantiateController(RandomController.self, for: "contract")!
        
        let randomSeed: [UInt8] = Array(1...48).map { UInt8($0) }
        self.setBlockInfos(randomSeed: Data(randomSeed))
        
        let result = try controller.getRandomUInt32(min: 0, max: UInt32.max)
        
        XCTAssertEqual(result, 3667078648)
    }
    
    func testGetRandomUInt32ForRange() throws {
        let controller = self.instantiateController(RandomController.self, for: "contract")!
        
        let randomSeed: [UInt8] = Array(1...48).map { UInt8($0) }
        self.setBlockInfos(randomSeed: Data(randomSeed))
        
        let result = try controller.getRandomUInt32(min: 100, max: 200)
        
        XCTAssertTrue(result >= 100 && result <= 200)
    }
    
    // UInt64 Tests
    func testGetRandomUInt64ForZeroToOne() throws {
        let controller = self.instantiateController(RandomController.self, for: "contract")!
        
        let result = try controller.getRandomUInt64(min: 0, max: 1)
        
        XCTAssertEqual(result, 0)
    }
    
    func testGetRandomUInt64ForZeroToMax() throws {
        let controller = self.instantiateController(RandomController.self, for: "contract")!
        
        let randomSeed: [UInt8] = Array(1...48).map { UInt8($0) }
        self.setBlockInfos(randomSeed: Data(randomSeed))
        
        let result = try controller.getRandomUInt64(min: 0, max: UInt64.max)
        
        XCTAssertEqual(result, 4447582661738355511)
    }
    
    func testGetRandomUInt64ForRange() throws {
        let controller = self.instantiateController(RandomController.self, for: "contract")!
        
        let randomSeed: [UInt8] = Array(1...48).map { UInt8($0) }
        self.setBlockInfos(randomSeed: Data(randomSeed))
        
        let result = try controller.getRandomUInt64(min: 1000, max: 5000)
        
        XCTAssertTrue(result >= 1000 && result <= 5000)
    }
}

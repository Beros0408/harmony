import XCTest
@testable import HarmonyCallDirectoryExtension

// Run in Xcode — no macOS/simulator CLI runner available on Windows.
final class SharedRulesStoreTests: XCTestCase {

    private let suiteName = "group.com.harmony.test.isolated"

    override func setUp() {
        super.setUp()
        UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName)
    }

    func testSaveAndLoadBlacklist() {
        let numbers = ["+33612345678", "+33698765432"]
        UserDefaults(suiteName: suiteName)?.set(numbers, forKey: SharedRulesStore.blacklistKey)
        let loaded = UserDefaults(suiteName: suiteName)?.stringArray(forKey: SharedRulesStore.blacklistKey) ?? []
        XCTAssertEqual(loaded, numbers)
    }

    func testEmptyBlacklistReturnsEmptyArray() {
        let loaded = UserDefaults(suiteName: suiteName)?.stringArray(forKey: SharedRulesStore.blacklistKey) ?? []
        XCTAssertTrue(loaded.isEmpty)
    }

    func testSaveAndLoadWhitelist() {
        let numbers = ["+33611111111"]
        UserDefaults(suiteName: suiteName)?.set(numbers, forKey: SharedRulesStore.whitelistKey)
        let loaded = UserDefaults(suiteName: suiteName)?.stringArray(forKey: SharedRulesStore.whitelistKey) ?? []
        XCTAssertEqual(loaded, numbers)
    }

    func testDifferentKeysAreIndependent() {
        let blacklist = ["+33600000001"]
        let whitelist = ["+33600000002"]
        UserDefaults(suiteName: suiteName)?.set(blacklist, forKey: SharedRulesStore.blacklistKey)
        UserDefaults(suiteName: suiteName)?.set(whitelist, forKey: SharedRulesStore.whitelistKey)
        let loadedBlack = UserDefaults(suiteName: suiteName)?.stringArray(forKey: SharedRulesStore.blacklistKey) ?? []
        let loadedWhite = UserDefaults(suiteName: suiteName)?.stringArray(forKey: SharedRulesStore.whitelistKey) ?? []
        XCTAssertEqual(loadedBlack, blacklist)
        XCTAssertEqual(loadedWhite, whitelist)
    }
}

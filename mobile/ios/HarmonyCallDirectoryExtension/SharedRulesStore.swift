import Foundation

/// Reads call filter rules from the App Group shared UserDefaults.
/// The main app writes rules; the extension reads them.
/// App Group: group.com.harmony.app.shared — must be configured in Xcode Signing & Capabilities.
struct SharedRulesStore {
    static let suiteName = "group.com.harmony.app.shared"
    static let blacklistKey = "harmony_blacklist"
    static let whitelistKey = "harmony_whitelist"

    static func loadBlacklist() -> [String] {
        guard let defaults = UserDefaults(suiteName: suiteName) else { return [] }
        return defaults.stringArray(forKey: blacklistKey) ?? []
    }

    static func loadWhitelist() -> [String] {
        guard let defaults = UserDefaults(suiteName: suiteName) else { return [] }
        return defaults.stringArray(forKey: whitelistKey) ?? []
    }

    static func saveBlacklist(_ numbers: [String]) {
        UserDefaults(suiteName: suiteName)?.set(numbers, forKey: blacklistKey)
    }

    static func saveWhitelist(_ numbers: [String]) {
        UserDefaults(suiteName: suiteName)?.set(numbers, forKey: whitelistKey)
    }
}

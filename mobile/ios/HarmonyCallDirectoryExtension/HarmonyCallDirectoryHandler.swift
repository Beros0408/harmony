import Foundation
import CallKit

/// CXCallDirectoryProvider extension entry point.
/// Provides blocked/identified numbers to iOS system call screening.
/// iOS calls beginRequest on a background thread when the directory needs reloading.
class HarmonyCallDirectoryHandler: CXCallDirectoryProvider {

    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        context.delegate = self
        addBlockingEntries(to: context)
        addIdentificationEntries(to: context)
        context.completeRequest()
    }

    private func addBlockingEntries(to context: CXCallDirectoryExtensionContext) {
        let blacklist = SharedRulesStore.loadBlacklist()
        let normalized = blacklist.compactMap { phoneNumberToE164($0) }.sorted()
        for number in normalized {
            context.addBlockingEntry(withNextSequentialPhoneNumber: number)
        }
    }

    private func addIdentificationEntries(to context: CXCallDirectoryExtensionContext) {
        let whitelist = SharedRulesStore.loadWhitelist()
        let normalized = whitelist.compactMap { phoneNumberToE164($0) }
        for number in normalized.sorted() {
            context.addIdentificationEntry(
                withNextSequentialPhoneNumber: number,
                label: "KimiaCare — autorisé"
            )
        }
    }

    /// Converts a phone number string to CXCallDirectoryPhoneNumber (Int64, E.164 digits only).
    /// Returns nil if conversion fails.
    private func phoneNumberToE164(_ raw: String) -> CXCallDirectoryPhoneNumber? {
        let digits = raw.filter { $0.isNumber }
        guard !digits.isEmpty, let value = CXCallDirectoryPhoneNumber(digits) else { return nil }
        return value
    }
}

extension HarmonyCallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {
    func requestFailed(for extensionContext: CXCallDirectoryExtensionContext, withError error: Error) {
        // Errors are surfaced via iOS Settings → Phone → Call Blocking & Identification.
    }
}

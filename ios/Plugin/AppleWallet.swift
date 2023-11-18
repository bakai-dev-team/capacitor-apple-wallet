import Foundation

@objc public class AppleWallet: NSObject {
    @objc public func echo(_ value: String) -> String {
        print(value)
        return value
    }
}

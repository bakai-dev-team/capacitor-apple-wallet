import Foundation
import PassKit
import Capacitor
import WatchConnectivity

private let walletExtensionAppGroup = "group.kg.bta.mobilebank2.apple-wallet"
private let walletExtensionStateKey = "apple_wallet_extension_state"

private struct AddCardContext {
    let primaryAccountIdentifier: String
    let cardId:String
}

private struct PluginError: LocalizedError {
    let message: String

    var errorDescription: String? {
        message
    }
}

private struct WalletExtensionSessionState: Codable {
    let extensionAuthToken: String?
    let lang: String?

    init(
        extensionAuthToken: String? = nil,
        lang: String? = nil
    ) {
        self.extensionAuthToken = extensionAuthToken
        self.lang = lang
    }

    private enum CodingKeys: String, CodingKey {
        case extensionAuthToken
        case authToken
        case lang
        case locale
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let legacyAuthToken = try container.decodeIfPresent(String.self, forKey: .authToken)

        extensionAuthToken = try container.decodeIfPresent(String.self, forKey: .extensionAuthToken) ?? legacyAuthToken
        lang = try container.decodeIfPresent(String.self, forKey: .lang)
            ?? container.decodeIfPresent(String.self, forKey: .locale)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(extensionAuthToken, forKey: .extensionAuthToken)
        try container.encodeIfPresent(extensionAuthToken, forKey: .authToken)
        try container.encodeIfPresent(lang, forKey: .lang)
    }
}

private struct WalletExtensionState: Codable {
    let session: WalletExtensionSessionState
    let updatedAt: TimeInterval
}

@objc(CapAppleWalletPlugin)
public class CapAppleWalletPlugin: CAPPlugin, PKAddPaymentPassViewControllerDelegate, PKAddPassesViewControllerDelegate {
    private var activeCall: CAPPluginCall?
    private var addCardContext: AddCardContext?
    private var pendingRequestHandler: ((PKAddPaymentPassRequest) -> Void)?
    private var pendingProvisioningError: String?
    private var pendingPassToAdd: PKPass?

    private func debugLog(_ message: String, details: Any? = nil) {
        if let details {
            print("[AppleWalletPlugin] \(message): \(details)")
            return
        }

        print("[AppleWalletPlugin] \(message)")
    }

    @objc func isTokenized(_ call: CAPPluginCall) {
        do {
            let primaryAccountIdentifier = try requireString(call: call, key: "primaryAccountIdentifier")
            let includeRemote = call.getBool("includeRemote") ?? true
            let passLibrary = PKPassLibrary()
            let localPasses = passLibrary.passes(of: .secureElement).compactMap { $0 as? PKSecureElementPass }
            let remotePasses = passLibrary.remoteSecureElementPasses

            let foundOnLocalDevice = localPasses.contains {
                $0.primaryAccountIdentifier == primaryAccountIdentifier
            }
            let foundOnRemoteDevice = remotePasses.contains {
                $0.primaryAccountIdentifier == primaryAccountIdentifier
            }
            let isTokenized = foundOnLocalDevice || (includeRemote && foundOnRemoteDevice)

            debugLog("isTokenized lookup", details: [
                "primaryAccountIdentifier": primaryAccountIdentifier,
                "includeRemote": includeRemote,
                "foundOnLocalDevice": foundOnLocalDevice,
                "foundOnRemoteDevice": foundOnRemoteDevice,
                "isTokenized": isTokenized,
                "localCards": localPasses.map { mapWalletCard($0, isRemote: false) },
                "remoteCards": remotePasses.map { mapWalletCard($0, isRemote: true) }
            ])

            call.resolve([
                "isTokenized": isTokenized
            ])
        } catch {
            call.reject(error.localizedDescription, "INVALID_ARGUMENTS")
        }
    }

    @objc func startProvisioning(_ call: CAPPluginCall) {
        if activeCall != nil {
            call.reject("Another Apple Wallet provisioning flow is already running.", "ALREADY_IN_PROGRESS")
            return
        }

        guard PKAddPaymentPassViewController.canAddPaymentPass() else {
            call.reject("Apple Wallet provisioning is not available on this device.", "NOT_AVAILABLE")
            return
        }

        do {
            let configuration = try makeRequestConfiguration(call: call)
            let primaryAccountIdentifier = try requireString(call: call, key: "primaryAccountIdentifier")
            let cardId = try requireString(call: call, key: "cardId")
            debugLog("startProvisioning request", details: [
                "primaryAccountIdentifier": primaryAccountIdentifier,
                "primaryAccountSuffix": configuration.primaryAccountSuffix,
                "localizedDescription": configuration.localizedDescription as Any
            ])

            guard let enrollViewController = PKAddPaymentPassViewController(
                requestConfiguration: configuration,
                delegate: self
            ) else {
                call.reject("In-app provisioning controller configuration failed.", "NOT_CONFIGURED")
                return
            }

            activeCall = call
            addCardContext = AddCardContext(primaryAccountIdentifier: primaryAccountIdentifier, cardId: cardId)
            pendingRequestHandler = nil
            pendingProvisioningError = nil

            DispatchQueue.main.async {
                guard let viewController = self.bridge?.viewController else {
                    self.resetProvisioningState()
                    call.reject("Unable to access the current view controller.", "FAILED")
                    return
                }

                viewController.present(enrollViewController, animated: true)
            }
        } catch {
            resetProvisioningState()
            call.reject(error.localizedDescription, "INVALID_ARGUMENTS")
        }
    }

    @objc func completeProvisioning(_ call: CAPPluginCall) {
        guard let handler = pendingRequestHandler else {
            call.reject("No pending Apple Wallet provisioning request was found.", "NO_PENDING_REQUEST")
            return
        }

        do {
            let request = try makePaymentPassRequest(call: call)
            pendingRequestHandler = nil
            pendingProvisioningError = nil
            handler(request)
            call.resolve()
        } catch {
            call.reject(error.localizedDescription, "INVALID_ARGUMENTS")
        }
    }

    @objc func cancelProvisioning(_ call: CAPPluginCall) {
        guard let handler = pendingRequestHandler else {
            call.reject("No pending Apple Wallet provisioning request was found.", "NO_PENDING_REQUEST")
            return
        }

        pendingProvisioningError = call.getString("reason") ?? "Provisioning canceled by the application."
        pendingRequestHandler = nil
        handler(PKAddPaymentPassRequest())
        call.resolve()
    }

    @objc func syncExtensionState(_ call: CAPPluginCall) {
        do {
            let state = try call.decode(WalletExtensionState.self, for: "state")
            let existingState = try loadExtensionState()
            let mergedState = mergeExtensionState(incomingState: state, existingState: existingState)
            try saveExtensionState(mergedState)
            let cards = getWalletCards()
            debugLog("syncExtensionState result", details: [
                "hasIncomingExtensionAuthToken": normalizedExtensionAuthToken(from: state.session) != nil,
                "hasStoredExtensionAuthToken": normalizedExtensionAuthToken(from: mergedState.session) != nil,
                "updatedAt": mergedState.updatedAt,
                "cardCount": cards.count,
                "cards": cards
            ])
            call.resolve([
                "cards": cards
            ])
        } catch {
            call.reject(error.localizedDescription, "INVALID_ARGUMENTS")
        }
    }

    @objc func clearExtensionState(_ call: CAPPluginCall) {
        clearExtensionState()
        debugLog("clearExtensionState", details: [
            "hasStoredExtensionAuthToken": false
        ])
        call.resolve()
    }

    @objc func getExtensionAuthToken(_ call: CAPPluginCall) {
        do {
            guard let state = try loadExtensionState(),
                  let extensionAuthToken = normalizedExtensionAuthToken(from: state.session) else {
                debugLog("getExtensionAuthToken", details: [
                    "hasStoredExtensionAuthToken": false
                ])
                call.resolve()
                return
            }

            debugLog("getExtensionAuthToken", details: [
                "hasStoredExtensionAuthToken": true
            ])
            call.resolve([
                "extensionAuthToken": extensionAuthToken
            ])
        } catch {
            call.reject(error.localizedDescription, "FAILED")
        }
    }

    public func addPaymentPassViewController(
        _ controller: PKAddPaymentPassViewController,
        generateRequestWithCertificateChain certificates: [Data],
        nonce: Data,
        nonceSignature: Data,
        completionHandler handler: @escaping (PKAddPaymentPassRequest) -> Void
    ) {
        guard let context = addCardContext else {
            pendingProvisioningError = "Provisioning context is missing."
            handler(PKAddPaymentPassRequest())
            return
        }

        pendingRequestHandler = handler
        pendingProvisioningError = nil

        notifyListeners("walletProvisioningData", data: [
            "cardId":context.cardId,
            "primaryAccountIdentifier": context.primaryAccountIdentifier,
            "certificates": certificates.map { $0.base64EncodedString() },
            "nonce": nonce.base64EncodedString(),
            "nonceSignature": nonceSignature.base64EncodedString()
        ])
    }

    public func addPaymentPassViewController(
        _ controller: PKAddPaymentPassViewController,
        didFinishAdding pass: PKPaymentPass?,
        error: Error?
    ) {
        let call = activeCall
        let pendingError = pendingProvisioningError

        debugLog("didFinishAdding callback", details: [
            "hasPass": pass != nil,
            "primaryAccountIdentifier": pass?.primaryAccountIdentifier as Any,
            "primaryAccountNumberSuffix": pass?.primaryAccountNumberSuffix as Any,
            "deviceAccountIdentifier": pass?.deviceAccountIdentifier as Any,
            "deviceAccountNumberSuffix": pass?.deviceAccountNumberSuffix as Any,
            "error": error?.localizedDescription as Any,
            "pendingError": pendingError as Any
        ])

        DispatchQueue.main.async {
            controller.dismiss(animated: true) {
                defer {
                    self.resetProvisioningState()
                }

                guard let call else {
                    return
                }

                if let error {
                    call.reject(error.localizedDescription, "APPLE_WALLET_ERROR")
                    return
                }

                if let pendingError {
                    call.reject(pendingError, "PROVISIONING_CANCELED")
                    return
                }

                guard let pass else {
                    call.resolve([
                        "status": "canceled"
                    ])
                    return
                }

                call.resolve([
                    "status": "added",
                    "primaryAccountIdentifier": pass.primaryAccountIdentifier ?? NSNull(),
                    "primaryAccountNumberSuffix": pass.primaryAccountNumberSuffix,
                    "deviceAccountIdentifier": pass.deviceAccountIdentifier ?? NSNull(),
                    "deviceAccountNumberSuffix": pass.deviceAccountNumberSuffix ?? NSNull()
                ])
            }
        }
    }

    public func addPassesViewControllerDidFinish(_ controller: PKAddPassesViewController) {
        let call = activeCall
        let pendingPass = pendingPassToAdd
        let passWasAdded = pendingPass.map { PKPassLibrary().containsPass($0) } ?? false

        debugLog("addPassesViewControllerDidFinish callback", details: [
            "hasPendingPass": pendingPass != nil,
            "passWasAdded": passWasAdded,
            "serialNumber": pendingPass?.serialNumber as Any,
            "passTypeIdentifier": pendingPass?.passTypeIdentifier as Any
        ])

        DispatchQueue.main.async {
            controller.dismiss(animated: true) {
                defer {
                    self.resetProvisioningState()
                }

                guard let call else {
                    return
                }

                var result: [String: Any] = [
                    "status": passWasAdded ? "added" : "canceled"
                ]

                if passWasAdded, let pendingPass {
                    result["serialNumber"] = pendingPass.serialNumber
                    result["passTypeIdentifier"] = pendingPass.passTypeIdentifier
                }

                call.resolve(result)
            }
        }
    }

    private func resetProvisioningState() {
        activeCall = nil
        addCardContext = nil
        pendingRequestHandler = nil
        pendingProvisioningError = nil
        pendingPassToAdd = nil
    }

    private func makeRequestConfiguration(call: CAPPluginCall) throws -> PKAddPaymentPassRequestConfiguration {
        guard let configuration = PKAddPaymentPassRequestConfiguration(encryptionScheme: .ECC_V2) else {
            throw PluginError(message: "Unable to create PKAddPaymentPassRequestConfiguration.")
        }

        configuration.primaryAccountSuffix = try requireString(call: call, key: "primaryAccountSuffix")
        configuration.paymentNetwork = getNetwork(paymentNetwork: call.getInt("paymentNetwork", 9))

        if let localizedDescription = call.getString("localizedDescription"), !localizedDescription.isEmpty {
            configuration.localizedDescription = localizedDescription
        }

        configuration.primaryAccountIdentifier = try requireString(call: call, key: "primaryAccountIdentifier")

        return configuration
    }

    private func makePaymentPassRequest(call: CAPPluginCall) throws -> PKAddPaymentPassRequest {
        let request = PKAddPaymentPassRequest()
        request.activationData = try decodeBase64Field(call: call, key: "activationData")
        request.encryptedPassData = try decodeBase64Field(call: call, key: "encryptedPassData")
        request.ephemeralPublicKey = try decodeBase64Field(call: call, key: "ephemeralPublicKey")
        return request
    }

    private func makePass(call: CAPPluginCall) throws -> PKPass {
        let data = try decodeBase64Field(call: call, key: "passData")

        do {
            return try PKPass(data: data)
        } catch {
            throw PluginError(message: "passData must be a valid signed .pkpass file.")
        }
    }

    private func requireString(call: CAPPluginCall, key: String) throws -> String {
        guard let value = call.getString(key), !value.isEmpty else {
            throw PluginError(message: "\(key) is required.")
        }

        return value
    }

    private func decodeBase64Field(call: CAPPluginCall, key: String) throws -> Data {
        let base64 = try requireString(call: call, key: key)

        guard let data = Data(base64Encoded: base64) else {
            throw PluginError(message: "\(key) must be a valid base64 string.")
        }

        return data
    }

    private func saveExtensionState(_ state: WalletExtensionState) throws {
        guard let userDefaults = UserDefaults(suiteName: walletExtensionAppGroup) else {
            throw PluginError(message: "Unable to access Apple Wallet extension App Group.")
        }

        let data = try JSONEncoder().encode(state)
        userDefaults.set(data, forKey: walletExtensionStateKey)
        userDefaults.synchronize()
    }

    private func mergeExtensionState(
        incomingState: WalletExtensionState,
        existingState: WalletExtensionState?
    ) -> WalletExtensionState {
        guard let existingState else {
            return incomingState
        }

        let mergedSession = WalletExtensionSessionState(
            extensionAuthToken: incomingState.session.extensionAuthToken ?? existingState.session.extensionAuthToken,
            lang: incomingState.session.lang ?? existingState.session.lang
        )

        return WalletExtensionState(
            session: mergedSession,
            updatedAt: incomingState.updatedAt
        )
    }

    private func loadExtensionState() throws -> WalletExtensionState? {
        guard let userDefaults = UserDefaults(suiteName: walletExtensionAppGroup) else {
            throw PluginError(message: "Unable to access Apple Wallet extension App Group.")
        }

        guard let data = userDefaults.data(forKey: walletExtensionStateKey) else {
            return nil
        }

        return try JSONDecoder().decode(WalletExtensionState.self, from: data)
    }

    private func clearExtensionState() {
        guard let userDefaults = UserDefaults(suiteName: walletExtensionAppGroup) else {
            return
        }

        userDefaults.removeObject(forKey: walletExtensionStateKey)
        userDefaults.synchronize()
    }

    private func normalizedExtensionAuthToken(from session: WalletExtensionSessionState) -> String? {
        let value = session.extensionAuthToken?.trimmingCharacters(in: .whitespacesAndNewlines)
        return (value?.isEmpty == false) ? value : nil
    }

    private func getWalletCards() -> [[String: Any]] {
        let passLibrary = PKPassLibrary()
        let localPasses = passLibrary.passes(of: .secureElement).compactMap { $0 as? PKSecureElementPass }
        let remotePasses = passLibrary.remoteSecureElementPasses

        return localPasses.map { mapWalletCard($0, isRemote: false) }
            + remotePasses.map { mapWalletCard($0, isRemote: true) }
    }

    private func mapWalletCard(_ pass: PKSecureElementPass, isRemote: Bool) -> [String: Any] {
        [
            "primaryAccountIdentifier": pass.primaryAccountIdentifier as Any,
            "primaryAccountNumberSuffix": pass.primaryAccountNumberSuffix as Any,
            "deviceAccountIdentifier": pass.deviceAccountIdentifier as Any,
            "deviceAccountNumberSuffix": pass.deviceAccountNumberSuffix as Any,
            "isRemote": isRemote
        ]
    }

    // SwiftLint flags this compatibility mapper as too complex because of
    // availability-gated payment networks, but the explicit switch is clearer here.
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    private func getNetwork(paymentNetwork: Int) -> PKPaymentNetwork {
        switch paymentNetwork {
        case 0:
            return .interac
        case 1:
            return .JCB
        case 2:
            return .mada
        case 3:
            return .maestro
        case 4:
            return .masterCard
        case 5:
            if #available(iOS 14.5, *) {
                return .mir
            }
        case 6:
            return .privateLabel
        case 7:
            return .quicPay
        case 8:
            return .suica
        case 9:
            return .visa
        case 10:
            return .vPay
        case 11:
            if #available(iOS 14.0, *) {
                return .barcode
            }
        case 12:
            if #available(iOS 14.0, *) {
                return .girocard
            }
        case 13:
            if #available(iOS 15.0, *) {
                return .waon
            }
        case 14:
            if #available(iOS 15.0, *) {
                return .nanaco
            }
        case 15:
            if #available(iOS 16.4, *) {
                return .postFinance
            }
        case 16:
            if #available(iOS 17.0, *) {
                return .tmoney
            }
        default:
            return .visa
        }

        return .visa
    }

@objc func getButtonText(_ call: CAPPluginCall) {
      DispatchQueue.main.async {
                 let button = PKAddPassButton(addPassButtonStyle: .black)
                 let text = button.accessibilityLabel ?? "Add to Apple Wallet"
                 call.resolve([
                     "value": text
                 ])
        }
    }

@objc func checkWalletStatus(_ call: CAPPluginCall) {
      let passLibrary = PKPassLibrary()
      let localPasses = passLibrary.passes(of: .secureElement)
          .compactMap { $0 as? PKSecureElementPass }
      let localCards = localPasses.map { pass in
          [
              "serialNumber": pass.serialNumber,
              "primaryAccountIdentifier": pass.primaryAccountIdentifier ?? "",
              "deviceAccountIdentifier": pass.deviceAccountIdentifier ?? "",
              "primaryAccountNumberSuffix": pass.primaryAccountNumberSuffix,
              "deviceAccountNumberSuffix": pass.deviceAccountNumberSuffix ?? ""
          ] as [String: Any]
      }

      guard WCSession.isSupported() else {
            call.resolve([
                "iphone": localCards,
                "watch": [],
                "watchPaired": false
            ])
            return
        }
      let session = WCSession.default
        WatchSessionActivator.shared.activate(session: session) {
            guard session.isPaired else {
                call.resolve([
                    "iphone": localCards,
                    "watch": [],
                    "watchPaired": false
                ])
                return
            }
           let remotePasses = passLibrary.remoteSecureElementPasses
           let remoteCards = remotePasses.map { pass in
              [
                "serialNumber": pass.serialNumber,
                "primaryAccountIdentifier": pass.primaryAccountIdentifier ?? "",
                "deviceAccountIdentifier": pass.deviceAccountIdentifier ?? "",
                "primaryAccountNumberSuffix": pass.primaryAccountNumberSuffix,
                "deviceAccountNumberSuffix": pass.deviceAccountNumberSuffix ?? ""
              ] as [String: Any]
            }
            call.resolve([
                "iphone": localCards,
                "watch": remoteCards,
                "watchPaired": true
            ])
        }
    }

    @objc func addPass(_ call: CAPPluginCall) {
        if activeCall != nil {
            call.reject("Another Apple Wallet flow is already running.", "ALREADY_IN_PROGRESS")
            return
        }

        guard PKAddPassesViewController.canAddPasses() else {
            call.reject("Apple Wallet pass addition is not available on this device.", "NOT_AVAILABLE")
            return
        }

        do {
            let pass = try makePass(call: call)
            guard let addPassesViewController = PKAddPassesViewController(pass: pass) else {
                call.reject("Unable to prepare Apple Wallet pass view controller.", "NOT_CONFIGURED")
                return
            }

            activeCall = call
            pendingPassToAdd = pass
            addPassesViewController.delegate = self

            DispatchQueue.main.async {
                guard let viewController = self.bridge?.viewController else {
                    self.resetProvisioningState()
                    call.reject("Unable to access the current view controller.", "FAILED")
                    return
                }

                viewController.present(addPassesViewController, animated: true)
            }
        } catch {
            resetProvisioningState()
            call.reject(error.localizedDescription, "INVALID_ARGUMENTS")
        }
    }
}

private class WatchSessionActivator: NSObject, WCSessionDelegate {
    static let shared = WatchSessionActivator()
    private var completionHandler: (() -> Void)?

    func activate(session: WCSession, completion: @escaping () -> Void) {
        if session.activationState == .activated {
            completion()
            return
        }
        completionHandler = completion
        session.delegate = self
        session.activate()
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.completionHandler?()
            self.completionHandler = nil
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
}

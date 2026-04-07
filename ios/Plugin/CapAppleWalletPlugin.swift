import Foundation
import PassKit
import Capacitor

private let walletExtensionAppGroup = "group.kg.bta.mobilebank2.apple-wallet"
private let walletExtensionStateKey = "apple_wallet_extension_state"

private struct AddCardContext {
    let primaryAccountIdentifier: String
}

private struct PluginError: LocalizedError {
    let message: String

    var errorDescription: String? {
        message
    }
}

private struct WalletExtensionSessionState: Codable {
    let apiBaseUrl: String
    let appAuthToken: String
    let extensionAuthToken: String?
    let cardholderName: String?
    let clientDeviceId: String
    let clientWalletAccountId: String?
    let deviceName: String?
    let deviceModel: String?
    let osVersion: String?
    let locale: String?
    let mode: String?
    let appVersion: String?
    let appBuild: String?

    init(
        apiBaseUrl: String,
        appAuthToken: String,
        extensionAuthToken: String? = nil,
        cardholderName: String? = nil,
        clientDeviceId: String,
        clientWalletAccountId: String? = nil,
        deviceName: String? = nil,
        deviceModel: String? = nil,
        osVersion: String? = nil,
        locale: String? = nil,
        mode: String? = nil,
        appVersion: String? = nil,
        appBuild: String? = nil
    ) {
        self.apiBaseUrl = apiBaseUrl
        self.appAuthToken = appAuthToken
        self.extensionAuthToken = extensionAuthToken
        self.cardholderName = cardholderName
        self.clientDeviceId = clientDeviceId
        self.clientWalletAccountId = clientWalletAccountId
        self.deviceName = deviceName
        self.deviceModel = deviceModel
        self.osVersion = osVersion
        self.locale = locale
        self.mode = mode
        self.appVersion = appVersion
        self.appBuild = appBuild
    }

    private enum CodingKeys: String, CodingKey {
        case apiBaseUrl
        case appAuthToken
        case extensionAuthToken
        case authToken
        case cardholderName
        case clientDeviceId
        case clientWalletAccountId
        case deviceName
        case deviceModel
        case osVersion
        case locale
        case mode
        case appVersion
        case appBuild
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let legacyAuthToken = try container.decodeIfPresent(String.self, forKey: .authToken)

        apiBaseUrl = try container.decode(String.self, forKey: .apiBaseUrl)
        appAuthToken = try container.decodeIfPresent(String.self, forKey: .appAuthToken) ?? legacyAuthToken ?? ""
        extensionAuthToken = try container.decodeIfPresent(String.self, forKey: .extensionAuthToken) ?? legacyAuthToken
        cardholderName = try container.decodeIfPresent(String.self, forKey: .cardholderName)
        clientDeviceId = try container.decode(String.self, forKey: .clientDeviceId)
        clientWalletAccountId = try container.decodeIfPresent(String.self, forKey: .clientWalletAccountId)
        deviceName = try container.decodeIfPresent(String.self, forKey: .deviceName)
        deviceModel = try container.decodeIfPresent(String.self, forKey: .deviceModel)
        osVersion = try container.decodeIfPresent(String.self, forKey: .osVersion)
        locale = try container.decodeIfPresent(String.self, forKey: .locale)
        mode = try container.decodeIfPresent(String.self, forKey: .mode)
        appVersion = try container.decodeIfPresent(String.self, forKey: .appVersion)
        appBuild = try container.decodeIfPresent(String.self, forKey: .appBuild)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(apiBaseUrl, forKey: .apiBaseUrl)
        try container.encode(appAuthToken, forKey: .appAuthToken)
        try container.encodeIfPresent(extensionAuthToken, forKey: .extensionAuthToken)
        try container.encodeIfPresent(cardholderName, forKey: .cardholderName)
        try container.encode(clientDeviceId, forKey: .clientDeviceId)
        try container.encodeIfPresent(clientWalletAccountId, forKey: .clientWalletAccountId)
        try container.encodeIfPresent(deviceName, forKey: .deviceName)
        try container.encodeIfPresent(deviceModel, forKey: .deviceModel)
        try container.encodeIfPresent(osVersion, forKey: .osVersion)
        try container.encodeIfPresent(locale, forKey: .locale)
        try container.encodeIfPresent(mode, forKey: .mode)
        try container.encodeIfPresent(appVersion, forKey: .appVersion)
        try container.encodeIfPresent(appBuild, forKey: .appBuild)
    }
}

private struct WalletExtensionState: Codable {
    let session: WalletExtensionSessionState
    let updatedAt: TimeInterval
}

@objc(CapAppleWalletPlugin)
public class CapAppleWalletPlugin: CAPPlugin, PKAddPaymentPassViewControllerDelegate {
    private var activeCall: CAPPluginCall?
    private var addCardContext: AddCardContext?
    private var pendingRequestHandler: ((PKAddPaymentPassRequest) -> Void)?
    private var pendingProvisioningError: String?

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

            guard let enrollViewController = PKAddPaymentPassViewController(
                requestConfiguration: configuration,
                delegate: self
            ) else {
                call.reject("In-app provisioning controller configuration failed.", "NOT_CONFIGURED")
                return
            }

            activeCall = call
            addCardContext = AddCardContext(primaryAccountIdentifier: primaryAccountIdentifier)
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
            call.resolve()
        } catch {
            call.reject(error.localizedDescription, "INVALID_ARGUMENTS")
        }
    }

    @objc func clearExtensionState(_ call: CAPPluginCall) {
        clearExtensionState()
        call.resolve()
    }

    @objc func deactivateExtensionState(_ call: CAPPluginCall) {
        do {
            try deactivateStoredExtensionState()
            call.resolve()
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

    private func resetProvisioningState() {
        activeCall = nil
        addCardContext = nil
        pendingRequestHandler = nil
        pendingProvisioningError = nil
    }

    private func makeRequestConfiguration(call: CAPPluginCall) throws -> PKAddPaymentPassRequestConfiguration {
        guard let configuration = PKAddPaymentPassRequestConfiguration(encryptionScheme: .ECC_V2) else {
            throw PluginError(message: "Unable to create PKAddPaymentPassRequestConfiguration.")
        }

        configuration.cardholderName = try requireString(call: call, key: "cardholderName")
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

        let shouldResetExtensionSession: Bool = {
            guard let incomingWalletAccountId = incomingState.session.clientWalletAccountId,
                  !incomingWalletAccountId.isEmpty,
                  let existingWalletAccountId = existingState.session.clientWalletAccountId,
                  !existingWalletAccountId.isEmpty else {
                return false
            }

            return incomingWalletAccountId != existingWalletAccountId
        }()

        let mergedSession = WalletExtensionSessionState(
            apiBaseUrl: incomingState.session.apiBaseUrl,
            appAuthToken: incomingState.session.appAuthToken,
            extensionAuthToken: shouldResetExtensionSession ? nil : existingState.session.extensionAuthToken,
            cardholderName: incomingState.session.cardholderName ?? existingState.session.cardholderName,
            clientDeviceId: incomingState.session.clientDeviceId,
            clientWalletAccountId: incomingState.session.clientWalletAccountId ?? existingState.session.clientWalletAccountId,
            deviceName: incomingState.session.deviceName ?? existingState.session.deviceName,
            deviceModel: incomingState.session.deviceModel ?? existingState.session.deviceModel,
            osVersion: incomingState.session.osVersion ?? existingState.session.osVersion,
            locale: incomingState.session.locale ?? existingState.session.locale,
            mode: incomingState.session.mode ?? existingState.session.mode,
            appVersion: incomingState.session.appVersion ?? existingState.session.appVersion,
            appBuild: incomingState.session.appBuild ?? existingState.session.appBuild
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

    private func deactivateStoredExtensionState() throws {
        guard let state = try loadExtensionState() else {
            return
        }

        let session = WalletExtensionSessionState(
            apiBaseUrl: state.session.apiBaseUrl,
            appAuthToken: "",
            extensionAuthToken: state.session.extensionAuthToken,
            cardholderName: state.session.cardholderName,
            clientDeviceId: state.session.clientDeviceId,
            clientWalletAccountId: state.session.clientWalletAccountId,
            deviceName: state.session.deviceName,
            deviceModel: state.session.deviceModel,
            osVersion: state.session.osVersion,
            locale: state.session.locale,
            mode: state.session.mode,
            appVersion: state.session.appVersion,
            appBuild: state.session.appBuild
        )
        let updatedState = WalletExtensionState(
            session: session,
            updatedAt: Date().timeIntervalSince1970 * 1000
        )

        try saveExtensionState(updatedState)
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
}

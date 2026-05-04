# capacitor-apple-wallet

In-App Provisioning payment cards within an app, without having to go through the process of manually entering payment card details.

## Install

```bash
npm install capacitor-apple-wallet
npx cap sync
```

## Quick Example

```typescript
import { AppleWallet } from 'capacitor-apple-wallet';

const status = await AppleWallet.isTokenized({
  primaryAccountIdentifier: '6854707',
});

if (status.isTokenized) {
  console.log('Card is already available in Apple Wallet');
}
```

## API

<docgen-index>

* [`startProvisioning(...)`](#startprovisioning)
* [`completeProvisioning(...)`](#completeprovisioning)
* [`cancelProvisioning(...)`](#cancelprovisioning)
* [`isTokenized(...)`](#istokenized)
* [`syncExtensionState(...)`](#syncextensionstate)
* [`clearExtensionState()`](#clearextensionstate)
* [`getExtensionAuthToken()`](#getextensionauthtoken)
* [`addListener('walletProvisioningData', ...)`](#addlistenerwalletprovisioningdata)
* [`removeAllListeners()`](#removealllisteners)
* [`getButtonText()`](#getbuttontext)
* [`checkWalletStatus()`](#checkwalletstatus)
* [`addPass(...)`](#addpass)
* [Interfaces](#interfaces)
* [Enums](#enums)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### startProvisioning(...)

```typescript
startProvisioning(options: StartProvisioningOptions) => Promise<AddCardResult>
```

| Param         | Type                                                                          |
| ------------- | ----------------------------------------------------------------------------- |
| **`options`** | <code><a href="#startprovisioningoptions">StartProvisioningOptions</a></code> |

**Returns:** <code>Promise&lt;<a href="#addcardresult">AddCardResult</a>&gt;</code>

--------------------


### completeProvisioning(...)

```typescript
completeProvisioning(options: CompleteProvisioningOptions) => Promise<void>
```

| Param         | Type                                                                                |
| ------------- | ----------------------------------------------------------------------------------- |
| **`options`** | <code><a href="#completeprovisioningoptions">CompleteProvisioningOptions</a></code> |

--------------------


### cancelProvisioning(...)

```typescript
cancelProvisioning(options?: CancelProvisioningOptions | undefined) => Promise<void>
```

| Param         | Type                                                                            |
| ------------- | ------------------------------------------------------------------------------- |
| **`options`** | <code><a href="#cancelprovisioningoptions">CancelProvisioningOptions</a></code> |

--------------------


### isTokenized(...)

```typescript
isTokenized(options: IsTokenizedOptions) => Promise<IsTokenizedResult>
```

| Param         | Type                                                              |
| ------------- | ----------------------------------------------------------------- |
| **`options`** | <code><a href="#istokenizedoptions">IsTokenizedOptions</a></code> |

**Returns:** <code>Promise&lt;<a href="#istokenizedresult">IsTokenizedResult</a>&gt;</code>

--------------------


### syncExtensionState(...)

```typescript
syncExtensionState(options: { state: AppleWalletExtensionState; }) => Promise<SyncExtensionStateResult>
```

| Param         | Type                                                                                        |
| ------------- | ------------------------------------------------------------------------------------------- |
| **`options`** | <code>{ state: <a href="#applewalletextensionstate">AppleWalletExtensionState</a>; }</code> |

**Returns:** <code>Promise&lt;<a href="#syncextensionstateresult">SyncExtensionStateResult</a>&gt;</code>

--------------------


### clearExtensionState()

```typescript
clearExtensionState() => Promise<void>
```

--------------------


### getExtensionAuthToken()

```typescript
getExtensionAuthToken() => Promise<GetExtensionAuthTokenResult>
```

**Returns:** <code>Promise&lt;<a href="#getextensionauthtokenresult">GetExtensionAuthTokenResult</a>&gt;</code>

--------------------


### addListener('walletProvisioningData', ...)

```typescript
addListener(eventName: 'walletProvisioningData', listenerFunc: (event: ProvisioningDataEvent) => void) => Promise<PluginListenerHandle>
```

| Param              | Type                                                                                        |
| ------------------ | ------------------------------------------------------------------------------------------- |
| **`eventName`**    | <code>'walletProvisioningData'</code>                                                       |
| **`listenerFunc`** | <code>(event: <a href="#provisioningdataevent">ProvisioningDataEvent</a>) =&gt; void</code> |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt;</code>

--------------------


### removeAllListeners()

```typescript
removeAllListeners() => Promise<void>
```

--------------------


### getButtonText()

```typescript
getButtonText() => Promise<{ value: string; }>
```

**Returns:** <code>Promise&lt;{ value: string; }&gt;</code>

--------------------


### checkWalletStatus()

```typescript
checkWalletStatus() => Promise<CheckWalletStatusResult>
```

**Returns:** <code>Promise&lt;<a href="#checkwalletstatusresult">CheckWalletStatusResult</a>&gt;</code>

--------------------


### addPass(...)

```typescript
addPass(options: AddPassOptions) => Promise<AddPassResult>
```

| Param         | Type                                                      |
| ------------- | --------------------------------------------------------- |
| **`options`** | <code><a href="#addpassoptions">AddPassOptions</a></code> |

**Returns:** <code>Promise&lt;<a href="#addpassresult">AddPassResult</a>&gt;</code>

--------------------


### Interfaces


#### AddCardResult

| Prop                             | Type                               |
| -------------------------------- | ---------------------------------- |
| **`status`**                     | <code>'added' \| 'canceled'</code> |
| **`primaryAccountIdentifier`**   | <code>string</code>                |
| **`primaryAccountNumberSuffix`** | <code>string</code>                |
| **`deviceAccountIdentifier`**    | <code>string</code>                |
| **`deviceAccountNumberSuffix`**  | <code>string</code>                |


#### StartProvisioningOptions

| Prop                           | Type                                                      |
| ------------------------------ | --------------------------------------------------------- |
| **`primaryAccountSuffix`**     | <code>string</code>                                       |
| **`cardId`**                   | <code>string</code>                                       |
| **`paymentNetwork`**           | <code><a href="#paymentnetwork">PaymentNetwork</a></code> |
| **`primaryAccountIdentifier`** | <code>string</code>                                       |
| **`localizedDescription`**     | <code>string</code>                                       |


#### CompleteProvisioningOptions

| Prop                     | Type                |
| ------------------------ | ------------------- |
| **`activationData`**     | <code>string</code> |
| **`encryptedPassData`**  | <code>string</code> |
| **`ephemeralPublicKey`** | <code>string</code> |


#### CancelProvisioningOptions

| Prop         | Type                |
| ------------ | ------------------- |
| **`reason`** | <code>string</code> |


#### IsTokenizedResult

| Prop              | Type                 |
| ----------------- | -------------------- |
| **`isTokenized`** | <code>boolean</code> |


#### IsTokenizedOptions

| Prop                           | Type                 |
| ------------------------------ | -------------------- |
| **`primaryAccountIdentifier`** | <code>string</code>  |
| **`includeRemote`**            | <code>boolean</code> |


#### SyncExtensionStateResult

| Prop        | Type                      |
| ----------- | ------------------------- |
| **`cards`** | <code>WalletCard[]</code> |


#### WalletCard

| Prop                             | Type                 |
| -------------------------------- | -------------------- |
| **`primaryAccountIdentifier`**   | <code>string</code>  |
| **`primaryAccountNumberSuffix`** | <code>string</code>  |
| **`deviceAccountIdentifier`**    | <code>string</code>  |
| **`deviceAccountNumberSuffix`**  | <code>string</code>  |
| **`isRemote`**                   | <code>boolean</code> |


#### AppleWalletExtensionState

| Prop            | Type                                                                                |
| --------------- | ----------------------------------------------------------------------------------- |
| **`session`**   | <code><a href="#applewalletextensionsession">AppleWalletExtensionSession</a></code> |
| **`updatedAt`** | <code>number</code>                                                                 |


#### AppleWalletExtensionSession

| Prop                     | Type                |
| ------------------------ | ------------------- |
| **`extensionAuthToken`** | <code>string</code> |
| **`lang`**               | <code>string</code> |


#### GetExtensionAuthTokenResult

| Prop                     | Type                |
| ------------------------ | ------------------- |
| **`extensionAuthToken`** | <code>string</code> |


#### PluginListenerHandle

| Prop         | Type                                      |
| ------------ | ----------------------------------------- |
| **`remove`** | <code>() =&gt; Promise&lt;void&gt;</code> |


#### ProvisioningDataEvent

| Prop                           | Type                  |
| ------------------------------ | --------------------- |
| **`primaryAccountIdentifier`** | <code>string</code>   |
| **`cardId`**                   | <code>string</code>   |
| **`certificates`**             | <code>string[]</code> |
| **`nonce`**                    | <code>string</code>   |
| **`nonceSignature`**           | <code>string</code>   |


#### CheckWalletStatusResult

| Prop              | Type                               |
| ----------------- | ---------------------------------- |
| **`iphone`**      | <code>AppleWalletCardData[]</code> |
| **`watch`**       | <code>AppleWalletCardData[]</code> |
| **`watchPaired`** | <code>boolean</code>               |


#### AppleWalletCardData

| Prop                             | Type                 |
| -------------------------------- | -------------------- |
| **`serialNumber`**               | <code>number</code>  |
| **`isRemotePass`**               | <code>boolean</code> |
| **`primaryAccountIdentifier`**   | <code>string</code>  |
| **`deviceAccountIdentifier`**    | <code>string</code>  |
| **`primaryAccountNumberSuffix`** | <code>number</code>  |
| **`deviceAccountNumberSuffix`**  | <code>number</code>  |


#### AddPassResult

| Prop                     | Type                               |
| ------------------------ | ---------------------------------- |
| **`status`**             | <code>'added' \| 'canceled'</code> |
| **`serialNumber`**       | <code>string</code>                |
| **`passTypeIdentifier`** | <code>string</code>                |


#### AddPassOptions

| Prop           | Type                | Description                                       |
| -------------- | ------------------- | ------------------------------------------------- |
| **`passData`** | <code>string</code> | Base64-encoded contents of a signed .pkpass file. |


### Enums


#### PaymentNetwork

| Members            |
| ------------------ |
| **`interac`**      |
| **`JCB`**          |
| **`mada`**         |
| **`maestro`**      |
| **`masterCard`**   |
| **`mir`**          |
| **`privateLabel`** |
| **`quicPay`**      |
| **`suica`**        |
| **`visa`**         |
| **`vPay`**         |
| **`barcode`**      |
| **`girocard`**     |
| **`waon`**         |
| **`nanaco`**       |
| **`postFinance`**  |
| **`tmoney`**       |

</docgen-api>

## Adding `.pkpass`

`addPass` accepts a ready-made, signed `.pkpass` file encoded as base64. Apple Wallet does not accept the raw JSON payload directly, so the pass package must be assembled and signed on your backend first.

```typescript
import { AppleWallet } from 'capacitor-apple-wallet';

await AppleWallet.addPass({
  passData: pkpassBase64,
});
```

### What backend should build

Your backend should build a `.pkpass` archive with at least these files:

- `pass.json`
- `icon.png`
- `icon@2x.png`
- `logo.png` and `logo@2x.png` if you want a header logo
- `manifest.json`
- `signature`

The high-level flow is:

1. Build `pass.json`.
2. Add required images.
3. Compute SHA-1 hashes for every file and write them to `manifest.json`.
4. Sign `manifest.json` with your Apple Wallet Pass Type ID certificate.
5. Zip the files into a `.pkpass`.
6. Return the `.pkpass` bytes as base64 to the app.

### Example `pass.json`

This is a minimal generic pass with a QR code:

```json
{
  "formatVersion": 1,
  "passTypeIdentifier": "pass.com.yourcompany.app",
  "serialNumber": "1234567890",
  "teamIdentifier": "YOUR_TEAM_ID",
  "organizationName": "Your Company",
  "description": "QR Pass",
  "logoText": "Your App",
  "foregroundColor": "rgb(255,255,255)",
  "backgroundColor": "rgb(0,0,0)",
  "barcode": {
    "message": "https://your-link-or-data",
    "format": "PKBarcodeFormatQR",
    "messageEncoding": "iso-8859-1"
  },
  "generic": {
    "primaryFields": [
      {
        "key": "title",
        "label": "QR",
        "value": "Scan me"
      }
    ]
  }
}
```

Notes:

- `passTypeIdentifier` must match the Pass Type ID certificate used to sign the pass.
- `teamIdentifier` must be your Apple Developer Team ID.
- `serialNumber` must uniquely identify this pass within that `passTypeIdentifier`.
- For new projects, Apple documents pass creation under Wallet Passes:
  [Building a Pass](https://developer.apple.com/documentation/walletpasses/building-a-pass),
  [Creating a generic pass](https://developer.apple.com/documentation/walletpasses/creating-a-generic-pass),
  [Create Wallet identifiers and certificates](https://developer.apple.com/help/account/capabilities/create-wallet-identifiers-and-certificates).

### How to get the Apple Wallet certificate

Apple requires a dedicated certificate for signing Wallet passes.

1. Sign in to your Apple Developer account.
2. Open Certificates, Identifiers & Profiles.
3. Create a new `Pass Type ID`, for example `pass.com.yourcompany.app`.
4. Create a new certificate of type `Pass Type ID Certificate`.
5. During certificate creation, upload a CSR file.
6. Download the generated `.cer` certificate from Apple.

Official Apple instructions:
[Create Wallet identifiers and certificates](https://developer.apple.com/help/account/capabilities/create-wallet-identifiers-and-certificates)

### How to get the private key

The private key is created on the machine where you generated the CSR.

Typical flow on macOS:

1. Open `Keychain Access`.
2. Create a `Certificate Signing Request` from Keychain Access.
3. Finish certificate issuance in Apple Developer and download the `.cer`.
4. Double-click the downloaded `.cer` to import it into Keychain.
5. In Keychain Access, find the imported Pass Type ID certificate and expand it.
6. You should see the matching private key under that certificate.
7. Export the certificate together with the private key as `.p12`.

Your backend will usually use:

- `pass certificate` as `.pem` or `.p12`
- `private key` from that certificate export
- `WWDR` intermediate certificate from Apple

In practice, many backend libraries expect one of these setups:

- a `.p12` file plus its password
- or extracted `.pem` certificate and `.pem` private key

### What the app receives

Once the backend has generated and signed the pass, it should return either:

- raw `.pkpass` bytes encoded as base64
- or a downloadable `.pkpass` file that your app converts to base64 before calling the plugin

Then call:

```typescript
await AppleWallet.addPass({
  passData: pkpassBase64,
});
```

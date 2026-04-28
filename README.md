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
* [`deactivateExtensionState()`](#deactivateextensionstate)
* [`addListener('walletProvisioningData', ...)`](#addlistenerwalletprovisioningdata)
* [`removeAllListeners()`](#removealllisteners)
* [`getButtonText()`](#getbuttontext)
* [`checkWalletStatus()`](#checkwalletstatus)
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


### deactivateExtensionState()

```typescript
deactivateExtensionState() => Promise<void>
```

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

| Prop               | Type                |
| ------------------ | ------------------- |
| **`appAuthToken`** | <code>string</code> |
| **`lang`**         | <code>string</code> |


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

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
* [`showNativeButton(...)`](#shownativebutton)
* [`hideNativeButton()`](#hidenativebutton)
* [`addListener('nativeButtonTapped', ...)`](#addlistenernativebuttontapped)
* [Interfaces](#interfaces)
* [Enums](#enums)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### startProvisioning(...)

```typescript
startProvisioning(options: StartProvisioningOptions) => any
```

| Param         | Type                                                                          |
| ------------- | ----------------------------------------------------------------------------- |
| **`options`** | <code><a href="#startprovisioningoptions">StartProvisioningOptions</a></code> |

**Returns:** <code>any</code>

--------------------


### completeProvisioning(...)

```typescript
completeProvisioning(options: CompleteProvisioningOptions) => any
```

| Param         | Type                                                                                |
| ------------- | ----------------------------------------------------------------------------------- |
| **`options`** | <code><a href="#completeprovisioningoptions">CompleteProvisioningOptions</a></code> |

**Returns:** <code>any</code>

--------------------


### cancelProvisioning(...)

```typescript
cancelProvisioning(options?: CancelProvisioningOptions | undefined) => any
```

| Param         | Type                                                                            |
| ------------- | ------------------------------------------------------------------------------- |
| **`options`** | <code><a href="#cancelprovisioningoptions">CancelProvisioningOptions</a></code> |

**Returns:** <code>any</code>

--------------------


### isTokenized(...)

```typescript
isTokenized(options: IsTokenizedOptions) => any
```

| Param         | Type                                                              |
| ------------- | ----------------------------------------------------------------- |
| **`options`** | <code><a href="#istokenizedoptions">IsTokenizedOptions</a></code> |

**Returns:** <code>any</code>

--------------------


### syncExtensionState(...)

```typescript
syncExtensionState(options: { state: AppleWalletExtensionState; }) => any
```

| Param         | Type                                                                                        |
| ------------- | ------------------------------------------------------------------------------------------- |
| **`options`** | <code>{ state: <a href="#applewalletextensionstate">AppleWalletExtensionState</a>; }</code> |

**Returns:** <code>any</code>

--------------------


### clearExtensionState()

```typescript
clearExtensionState() => any
```

**Returns:** <code>any</code>

--------------------


### deactivateExtensionState()

```typescript
deactivateExtensionState() => any
```

**Returns:** <code>any</code>

--------------------


### addListener('walletProvisioningData', ...)

```typescript
addListener(eventName: 'walletProvisioningData', listenerFunc: (event: ProvisioningDataEvent) => void) => any
```

| Param              | Type                                                                                        |
| ------------------ | ------------------------------------------------------------------------------------------- |
| **`eventName`**    | <code>'walletProvisioningData'</code>                                                       |
| **`listenerFunc`** | <code>(event: <a href="#provisioningdataevent">ProvisioningDataEvent</a>) =&gt; void</code> |

**Returns:** <code>any</code>

--------------------


### removeAllListeners()

```typescript
removeAllListeners() => any
```

**Returns:** <code>any</code>

--------------------


### showNativeButton(...)

```typescript
showNativeButton(options: { x: number; y: number; width: number; height: number; }) => any
```

| Param         | Type                                                                  |
| ------------- | --------------------------------------------------------------------- |
| **`options`** | <code>{ x: number; y: number; width: number; height: number; }</code> |

**Returns:** <code>any</code>

--------------------


### hideNativeButton()

```typescript
hideNativeButton() => any
```

**Returns:** <code>any</code>

--------------------


### addListener('nativeButtonTapped', ...)

```typescript
addListener(eventName: 'nativeButtonTapped', listenerFunc: () => void) => any
```

| Param              | Type                              |
| ------------------ | --------------------------------- |
| **`eventName`**    | <code>'nativeButtonTapped'</code> |
| **`listenerFunc`** | <code>() =&gt; void</code>        |

**Returns:** <code>any</code>

--------------------


### Interfaces


#### StartProvisioningOptions

| Prop                           | Type                                                      |
| ------------------------------ | --------------------------------------------------------- |
| **`primaryAccountSuffix`**     | <code>string</code>                                       |
| **`paymentNetwork`**           | <code><a href="#paymentnetwork">PaymentNetwork</a></code> |
| **`primaryAccountIdentifier`** | <code>string</code>                                       |
| **`localizedDescription`**     | <code>string</code>                                       |


#### AddCardResult

| Prop                             | Type                               |
| -------------------------------- | ---------------------------------- |
| **`status`**                     | <code>'added' \| 'canceled'</code> |
| **`primaryAccountIdentifier`**   | <code>string</code>                |
| **`primaryAccountNumberSuffix`** | <code>string</code>                |
| **`deviceAccountIdentifier`**    | <code>string</code>                |
| **`deviceAccountNumberSuffix`**  | <code>string</code>                |


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


#### IsTokenizedOptions

| Prop                           | Type                 |
| ------------------------------ | -------------------- |
| **`primaryAccountIdentifier`** | <code>string</code>  |
| **`includeRemote`**            | <code>boolean</code> |


#### IsTokenizedResult

| Prop              | Type                 |
| ----------------- | -------------------- |
| **`isTokenized`** | <code>boolean</code> |


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


#### ProvisioningDataEvent

| Prop                           | Type                |
| ------------------------------ | ------------------- |
| **`primaryAccountIdentifier`** | <code>string</code> |
| **`certificates`**             | <code>{}</code>     |
| **`nonce`**                    | <code>string</code> |
| **`nonceSignature`**           | <code>string</code> |


#### PluginListenerHandle

| Prop         | Type                      |
| ------------ | ------------------------- |
| **`remove`** | <code>() =&gt; any</code> |


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

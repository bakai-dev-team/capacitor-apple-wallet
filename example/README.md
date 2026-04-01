## Apple Wallet Angular Example App

This example is aligned with the current plugin API and demonstrates the
recommended two-step provisioning flow:

1. The app calls `AppleWallet.startProvisioning(...)`.
2. The plugin opens `PKAddPaymentPassViewController`.
3. Native emits `walletProvisioningData` with `certificates`, `nonce`,
   and `nonceSignature`.
4. The app sends that payload to its own backend using its own auth headers.
5. The app forwards the backend response into
   `AppleWallet.completeProvisioning(...)`.

The example also shows that `tokenization_card.apple_get_digitized_card_ids`
should be called directly from the application layer instead of the plugin.

### Running the example

```bash
cd example
npm install
npm start
```

This example is now a real Ionic Angular app with a single standalone page in:

- `src/app/app.component.ts`
- `src/app/app.component.html`
- `src/app/app.component.scss`

### What to configure

- Set your backend endpoint in the `Backend URL` field.
- Optionally set a bearer token in the `Bearer Token` field.
- Run the app on iOS to exercise the real Apple Wallet flow.

### Important note

The `Send Mock completeProvisioning()` button only sends placeholder
base64 data so you can test the JS-to-native handoff. It is not valid Apple
Wallet tokenization data and will not complete a real provisioning flow.

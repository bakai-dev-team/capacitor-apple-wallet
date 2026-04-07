import { WebPlugin } from '@capacitor/core';
export class AppleWalletWeb extends WebPlugin {
    async startProvisioning(options) {
        void options;
        throw this.unavailable('Apple Wallet is available only on iOS.');
    }
    async completeProvisioning(options) {
        void options;
        throw this.unavailable('Apple Wallet is available only on iOS.');
    }
    async cancelProvisioning(options) {
        void options;
        throw this.unavailable('Apple Wallet is available only on iOS.');
    }
    async isTokenized(options) {
        void options;
        throw this.unavailable('Apple Wallet is available only on iOS.');
    }
    async syncExtensionState(options) {
        void options;
        throw this.unavailable('Apple Wallet is available only on iOS.');
    }
    clearExtensionState() {
        throw this.unavailable('Apple Wallet is available only on iOS.');
    }
}
//# sourceMappingURL=web.js.map
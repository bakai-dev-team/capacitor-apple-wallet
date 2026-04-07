import { registerPlugin } from '@capacitor/core';
const AppleWallet = registerPlugin('AppleWallet', {
    web: () => import('./web').then(m => new m.AppleWalletWeb()),
});
export * from './definitions';
export { AppleWallet };
//# sourceMappingURL=index.js.map
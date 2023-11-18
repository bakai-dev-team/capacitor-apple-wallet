import { registerPlugin } from '@capacitor/core';

import type { AppleWalletPlugin } from './definitions';

const AppleWallet = registerPlugin<AppleWalletPlugin>('AppleWallet', {
  web: () => import('./web').then(m => new m.AppleWalletWeb()),
});

export * from './definitions';
export { AppleWallet };

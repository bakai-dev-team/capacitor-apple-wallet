import { WebPlugin } from '@capacitor/core';

import type { AppleWalletPlugin } from './definitions';

export class AppleWalletWeb extends WebPlugin implements AppleWalletPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}

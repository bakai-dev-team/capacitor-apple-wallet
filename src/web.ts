import { WebPlugin } from '@capacitor/core';

import type {
  AddCardResult,
  AppleWalletPlugin,
  CancelProvisioningOptions,
  CompleteProvisioningOptions,
  IsTokenizedOptions,
  IsTokenizedResult,
  StartProvisioningOptions,
} from './definitions';

export class AppleWalletWeb extends WebPlugin implements AppleWalletPlugin {
  async startProvisioning(
    options: StartProvisioningOptions,
  ): Promise<AddCardResult> {
    void options;
    throw this.unavailable('Apple Wallet is available only on iOS.');
  }

  async completeProvisioning(
    options: CompleteProvisioningOptions,
  ): Promise<void> {
    void options;
    throw this.unavailable('Apple Wallet is available only on iOS.');
  }

  async cancelProvisioning(options?: CancelProvisioningOptions): Promise<void> {
    void options;
    throw this.unavailable('Apple Wallet is available only on iOS.');
  }

  async isTokenized(options: IsTokenizedOptions): Promise<IsTokenizedResult> {
    void options;
    throw this.unavailable('Apple Wallet is available only on iOS.');
  }
}

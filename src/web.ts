import { WebPlugin } from '@capacitor/core';

import type {
  AddCardResult,
  AddPassOptions,
  AddPassResult,
  AppleWalletExtensionState,
  AppleWalletPlugin,
  CancelProvisioningOptions,
  CompleteProvisioningOptions,
  GetExtensionAuthTokenResult,
  IsTokenizedOptions,
  IsTokenizedResult,
  SyncExtensionStateResult,
  StartProvisioningOptions,
} from './definitions';
import { CheckWalletStatusResult } from './definitions';

export class AppleWalletWeb extends WebPlugin implements AppleWalletPlugin {
  async startProvisioning(
    options: StartProvisioningOptions,
  ): Promise<AddCardResult> {
    void options;
    throw this.unavailable('Apple Wallet is available only on iOS.');
  }

  async addPass(options: AddPassOptions): Promise<AddPassResult> {
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

  async syncExtensionState(options: {
    state: AppleWalletExtensionState;
  }): Promise<SyncExtensionStateResult> {
    void options;
    throw this.unavailable('Apple Wallet is available only on iOS.');
  }

  clearExtensionState(): Promise<void> {
    throw this.unavailable('Apple Wallet is available only on iOS.');
  }

  async getExtensionAuthToken(): Promise<GetExtensionAuthTokenResult> {
    throw this.unavailable('Apple Wallet is available only on iOS.');
  }

  async checkWalletStatus():Promise<CheckWalletStatusResult>{
    throw this.unavailable('Apple Wallet is available only on iOS.');
  };

  async getButtonText(): Promise<{ value: string }> {
    console.warn('getButtonText is not implemented on web. Returning default.');
    return { value: 'Add to Apple Wallet' };
  }
}

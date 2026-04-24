import { WebPlugin } from '@capacitor/core';
import type { AddCardResult, AppleWalletExtensionState, AppleWalletPlugin, CancelProvisioningOptions, CompleteProvisioningOptions, IsTokenizedOptions, IsTokenizedResult, SyncExtensionStateResult, StartProvisioningOptions } from './definitions';
import { CheckWalletStatusResult } from './definitions';
export declare class AppleWalletWeb extends WebPlugin implements AppleWalletPlugin {
    startProvisioning(options: StartProvisioningOptions): Promise<AddCardResult>;
    completeProvisioning(options: CompleteProvisioningOptions): Promise<void>;
    cancelProvisioning(options?: CancelProvisioningOptions): Promise<void>;
    isTokenized(options: IsTokenizedOptions): Promise<IsTokenizedResult>;
    syncExtensionState(options: {
        state: AppleWalletExtensionState;
    }): Promise<SyncExtensionStateResult>;
    clearExtensionState(): Promise<void>;
    deactivateExtensionState(): Promise<void>;
    checkWalletStatus(): Promise<CheckWalletStatusResult>;
    getButtonText(): Promise<{
        value: string;
    }>;
}

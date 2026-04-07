import { WebPlugin } from '@capacitor/core';
import type { AddCardResult, AppleWalletPlugin, CancelProvisioningOptions, CompleteProvisioningOptions, IsTokenizedOptions, IsTokenizedResult, StartProvisioningOptions } from './definitions';
export declare class AppleWalletWeb extends WebPlugin implements AppleWalletPlugin {
    startProvisioning(options: StartProvisioningOptions): Promise<AddCardResult>;
    completeProvisioning(options: CompleteProvisioningOptions): Promise<void>;
    cancelProvisioning(options?: CancelProvisioningOptions): Promise<void>;
    isTokenized(options: IsTokenizedOptions): Promise<IsTokenizedResult>;
}

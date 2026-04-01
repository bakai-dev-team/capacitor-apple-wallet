import type { PluginListenerHandle } from '@capacitor/core';

export enum PaymentNetwork {
  interac,
  JCB,
  mada,
  maestro,
  masterCard,
  mir,
  privateLabel,
  quicPay,
  suica,
  visa,
  vPay,
  barcode,
  girocard,
  waon,
  nanaco,
  postFinance,
  tmoney,
}

export interface StartProvisioningOptions {
  cardholderName: string;
  primaryAccountSuffix: string;
  paymentNetwork: PaymentNetwork;
  primaryAccountIdentifier: string;
  localizedDescription?: string;
}

export interface ProvisioningDataEvent {
  primaryAccountIdentifier: string;
  certificates: string[];
  nonce: string;
  nonceSignature: string;
}

export interface CompleteProvisioningOptions {
  activationData: string;
  encryptedPassData: string;
  ephemeralPublicKey: string;
}

export interface CancelProvisioningOptions {
  reason?: string;
}

export interface AddCardResult {
  status: 'added' | 'canceled';
  primaryAccountIdentifier?: string;
  primaryAccountNumberSuffix?: string;
  deviceAccountIdentifier?: string;
  deviceAccountNumberSuffix?: string;
}

export interface AppleWalletPlugin {
  startProvisioning(options: StartProvisioningOptions): Promise<AddCardResult>;

  completeProvisioning(options: CompleteProvisioningOptions): Promise<void>;

  cancelProvisioning(options?: CancelProvisioningOptions): Promise<void>;

  addListener(
    eventName: 'walletProvisioningData',
    listenerFunc: (event: ProvisioningDataEvent) => void,
  ): Promise<PluginListenerHandle>;

  removeAllListeners(): Promise<void>;
}

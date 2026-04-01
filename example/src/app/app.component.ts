import { CommonModule } from '@angular/common';
import { Component, OnDestroy, OnInit } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Capacitor, type PluginListenerHandle } from '@capacitor/core';
import { SplashScreen } from '@capacitor/splash-screen';
import {
  IonApp,
  IonButton,
  IonCard,
  IonCardContent,
  IonCardHeader,
  IonCardSubtitle,
  IonCardTitle,
  IonContent,
  IonHeader,
  IonInput,
  IonItem,
  IonLabel,
  IonSelect,
  IonSelectOption,
  IonTitle,
  IonToolbar,
} from '@ionic/angular/standalone';
import { AppleWallet, PaymentNetwork } from 'capacitor-apple-wallet';

interface PaymentNetworkOption {
  label: string;
  value: PaymentNetwork;
}

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss'],
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    IonApp,
    IonHeader,
    IonToolbar,
    IonTitle,
    IonContent,
    IonCard,
    IonCardHeader,
    IonCardTitle,
    IonCardSubtitle,
    IonCardContent,
    IonItem,
    IonLabel,
    IonInput,
    IonSelect,
    IonSelectOption,
    IonButton,
  ],
})
export class AppComponent implements OnInit, OnDestroy {
  backendUrl = 'https://api.example.com/mobile/wallet';
  authToken = '';
  fpans = '6854707,5313073';
  cardholderName = 'John Doe';
  primaryAccountSuffix = '4707';
  paymentNetwork = PaymentNetwork.visa;
  primaryAccountIdentifier = '6854707';
  localizedDescription = 'Bakai Example Card';

  platformLabel = 'loading...';
  digitizedResult = 'No request sent yet.';
  provisioningEvent = 'Waiting for walletProvisioningData...';
  provisioningResult = 'No provisioning action started yet.';
  requestLog = 'No backend calls yet.';

  readonly paymentNetworkOptions: PaymentNetworkOption[] = [
    { label: 'visa', value: PaymentNetwork.visa },
    { label: 'masterCard', value: PaymentNetwork.masterCard },
    { label: 'JCB', value: PaymentNetwork.JCB },
    { label: 'mada', value: PaymentNetwork.mada },
  ];

  private provisioningListener: PluginListenerHandle | null = null;

  async ngOnInit(): Promise<void> {
    this.platformLabel = `${Capacitor.getPlatform()}${
      Capacitor.isNativePlatform() ? ' (native)' : ' (web)'
    }`;

    await SplashScreen.hide();
  }

  ngOnDestroy(): void {
    void this.provisioningListener?.remove();
  }

  async checkDigitizedCards(): Promise<void> {
    try {
      const response = await this.callBackend(
        'tokenization_card.apple_get_digitized_card_ids',
        {
          fpans: this.fpans
            .split(',')
            .map(value => value.trim())
            .filter(Boolean),
        },
      );

      this.digitizedResult = this.pretty(response);
    } catch (error) {
      this.digitizedResult = this.pretty({
        error: error instanceof Error ? error.message : 'Unknown error',
      });
    }
  }

  async startProvisioning(): Promise<void> {
    try {
      await this.ensureProvisioningListener();
      this.provisioningResult = 'Waiting for Apple Wallet callback...';

      const result = await AppleWallet.startProvisioning({
        cardholderName: this.cardholderName.trim(),
        primaryAccountSuffix: this.primaryAccountSuffix.trim(),
        paymentNetwork: this.paymentNetwork,
        primaryAccountIdentifier: this.primaryAccountIdentifier.trim(),
        localizedDescription: this.localizedDescription.trim() || undefined,
      });

      this.provisioningResult = this.pretty(result);
    } catch (error) {
      this.provisioningResult = this.pretty({
        error: error instanceof Error ? error.message : 'Unknown error',
      });
    }
  }

  async sendMockProvisioningResponse(): Promise<void> {
    try {
      await AppleWallet.completeProvisioning({
        activationData: 'ZHVtbXktYWN0aXZhdGlvbi1kYXRh',
        encryptedPassData: 'ZHVtbXktZW5jcnlwdGVkLXBhc3MtZGF0YQ==',
        ephemeralPublicKey: 'ZHVtbXktZXBoZW1lcmFsLXB1YmxpYy1rZXk=',
      });

      this.provisioningResult = this.pretty({
        status: 'mock_response_sent',
        note: 'These are demo base64 values, not real Apple tokenization data.',
      });
    } catch (error) {
      this.provisioningResult = this.pretty({
        error: error instanceof Error ? error.message : 'Unknown error',
      });
    }
  }

  async cancelProvisioning(): Promise<void> {
    try {
      await AppleWallet.cancelProvisioning({
        reason: 'Canceled from Ionic Angular example UI.',
      });

      this.provisioningResult = this.pretty({
        status: 'canceled',
        reason: 'Canceled from Ionic Angular example UI.',
      });
    } catch (error) {
      this.provisioningResult = this.pretty({
        error: error instanceof Error ? error.message : 'Unknown error',
      });
    }
  }

  private async ensureProvisioningListener(): Promise<void> {
    if (this.provisioningListener) {
      return;
    }

    this.provisioningListener = await AppleWallet.addListener(
      'walletProvisioningData',
      async event => {
        this.provisioningEvent = this.pretty(event);

        try {
          const response = await this.callBackend(
            'tokenization_card.apple_get_digitization_data',
            {
              cardId: event.primaryAccountIdentifier,
              certificates: event.certificates,
              nonce: event.nonce,
              nonceSignature: event.nonceSignature,
              source: 'ionic-angular-example',
            },
          );

          const data = response.data || response;

          await AppleWallet.completeProvisioning({
            activationData: data.activationData,
            encryptedPassData: data.encryptedPassData,
            ephemeralPublicKey: data.ephemeralPublicKey,
          });

          this.provisioningResult = this.pretty({
            status: 'backend_response_forwarded',
            response: data,
          });
        } catch (error) {
          const message =
            error instanceof Error ? error.message : 'Provisioning backend request failed.';

          await AppleWallet.cancelProvisioning({ reason: message });

          this.provisioningResult = this.pretty({
            status: 'canceled',
            reason: message,
          });
        }
      },
    );
  }

  private async callBackend(method: string, data: unknown): Promise<any> {
    const url = this.backendUrl.trim();
    if (!url) {
      throw new Error('Set Backend URL first.');
    }

    const body = { method, data };
    this.appendLog(`Request: ${method}`, body);

    const response = await fetch(url, {
      method: 'POST',
      headers: this.getBackendHeaders(),
      body: JSON.stringify(body),
    });

    const payload = await response.json();
    this.appendLog(`Response: ${method}`, payload);

    if (!response.ok) {
      throw new Error(payload.message || payload.error || `HTTP ${response.status}`);
    }

    return payload;
  }

  private getBackendHeaders(): Record<string, string> {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
      Accept: 'application/json',
    };

    const token = this.authToken.trim();
    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }

    return headers;
  }

  private appendLog(title: string, payload: unknown): void {
    const timestamp = new Date().toLocaleTimeString();
    const nextEntry = `[${timestamp}] ${title}\n${this.pretty(payload)}`;
    this.requestLog =
      this.requestLog === 'No backend calls yet.'
        ? nextEntry
        : `${this.requestLog}\n\n${nextEntry}`;
  }

  private pretty(value: unknown): string {
    return typeof value === 'string' ? value : JSON.stringify(value, null, 2);
  }
}

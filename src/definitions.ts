export interface AppleWalletPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}

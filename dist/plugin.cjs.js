'use strict';

Object.defineProperty(exports, '__esModule', { value: true });

var core = require('@capacitor/core');

exports.PaymentNetwork = void 0;
(function (PaymentNetwork) {
    PaymentNetwork[PaymentNetwork["interac"] = 0] = "interac";
    PaymentNetwork[PaymentNetwork["JCB"] = 1] = "JCB";
    PaymentNetwork[PaymentNetwork["mada"] = 2] = "mada";
    PaymentNetwork[PaymentNetwork["maestro"] = 3] = "maestro";
    PaymentNetwork[PaymentNetwork["masterCard"] = 4] = "masterCard";
    PaymentNetwork[PaymentNetwork["mir"] = 5] = "mir";
    PaymentNetwork[PaymentNetwork["privateLabel"] = 6] = "privateLabel";
    PaymentNetwork[PaymentNetwork["quicPay"] = 7] = "quicPay";
    PaymentNetwork[PaymentNetwork["suica"] = 8] = "suica";
    PaymentNetwork[PaymentNetwork["visa"] = 9] = "visa";
    PaymentNetwork[PaymentNetwork["vPay"] = 10] = "vPay";
    PaymentNetwork[PaymentNetwork["barcode"] = 11] = "barcode";
    PaymentNetwork[PaymentNetwork["girocard"] = 12] = "girocard";
    PaymentNetwork[PaymentNetwork["waon"] = 13] = "waon";
    PaymentNetwork[PaymentNetwork["nanaco"] = 14] = "nanaco";
    PaymentNetwork[PaymentNetwork["postFinance"] = 15] = "postFinance";
    PaymentNetwork[PaymentNetwork["tmoney"] = 16] = "tmoney";
})(exports.PaymentNetwork || (exports.PaymentNetwork = {}));

const AppleWallet = core.registerPlugin('AppleWallet', {
    web: () => Promise.resolve().then(function () { return web; }).then(m => new m.AppleWalletWeb()),
});

class AppleWalletWeb extends core.WebPlugin {
    async startProvisioning(options) {
        throw this.unavailable('Apple Wallet is available only on iOS.');
    }
    async completeProvisioning(options) {
        throw this.unavailable('Apple Wallet is available only on iOS.');
    }
    async cancelProvisioning(options) {
        throw this.unavailable('Apple Wallet is available only on iOS.');
    }
    async isTokenized(options) {
        throw this.unavailable('Apple Wallet is available only on iOS.');
    }
    async syncExtensionState(options) {
        throw this.unavailable('Apple Wallet is available only on iOS.');
    }
    clearExtensionState() {
        throw this.unavailable('Apple Wallet is available only on iOS.');
    }
}

var web = /*#__PURE__*/Object.freeze({
    __proto__: null,
    AppleWalletWeb: AppleWalletWeb
});

exports.AppleWallet = AppleWallet;
//# sourceMappingURL=plugin.cjs.js.map

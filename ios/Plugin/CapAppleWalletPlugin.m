#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

// Define the plugin using the CAP_PLUGIN Macro, and
// each method the plugin supports using the CAP_PLUGIN_METHOD macro.
CAP_PLUGIN(CapAppleWalletPlugin, "AppleWallet",
           CAP_PLUGIN_METHOD(startProvisioning, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(completeProvisioning, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(cancelProvisioning, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(isTokenized, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(syncExtensionState, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(clearExtensionState, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(deactivateExtensionState, CAPPluginReturnPromise);
)

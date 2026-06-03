package com.harmony.harmony

// local_auth nécessite FlutterFragmentActivity pour la biométrie
import android.app.Activity
import android.content.Intent
import com.harmony.harmony.admin.DeviceAdminPlugin
import com.harmony.harmony.channel.CallFilterMethodChannel
import com.harmony.harmony.contacts.ContactsReaderPlugin
import com.harmony.harmony.messages.MessagesFilterPlugin
import com.harmony.harmony.usage.UsageStatsPlugin
import com.harmony.harmony.vpn.ContentFilterPlugin
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {

    // Référence conservée pour router onActivityResult vers le plugin VPN.
    private var contentFilterPlugin: ContentFilterPlugin? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Canal filtrage d'appels (Sprint 1)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CallFilterMethodChannel.CHANNEL_NAME,
        ).setMethodCallHandler(CallFilterMethodChannel(this))

        // Canal lecture des contacts natifs (Sprint 5.2)
        // Lit TOUS les contacts y compris ceux sans account_type (émulateurs, téléphones sans Google)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            ContactsReaderPlugin.CHANNEL_NAME,
        ).setMethodCallHandler(ContactsReaderPlugin(this))

        // Canal filtrage des messages (Sprint 6)
        // SMS via ContentProvider + notifications WhatsApp/Signal/Telegram via HarmonyNotificationListener
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            MessagesFilterPlugin.CHANNEL_NAME,
        ).setMethodCallHandler(MessagesFilterPlugin(this))

        // Canal administrateur d'appareil — verrouillage d'écran Harmony Kids (Sprint B1)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            DeviceAdminPlugin.CHANNEL_NAME,
        ).setMethodCallHandler(DeviceAdminPlugin(this))

        // Canal temps d'écran — lecture UsageStatsManager + permission PACKAGE_USAGE_STATS (Sprint 5A)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            UsageStatsPlugin.CHANNEL_NAME,
        ).setMethodCallHandler(UsageStatsPlugin(this))

        // Canal filtrage DNS familial — VPN local sans inspection de contenu (Sprint C)
        // La référence est gardée pour capturer le résultat de la permission VPN dans onActivityResult.
        val plugin = ContentFilterPlugin(this)
        contentFilterPlugin = plugin
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            ContentFilterPlugin.CHANNEL_NAME,
        ).setMethodCallHandler(plugin)
    }

    /**
     * Capture le résultat du dialog de permission VPN.
     *
     * Flux :
     *   ContentFilterPlugin.handleStart()
     *     → startActivityForResult(prepareIntent, VPN_REQUEST_CODE)
     *     → [utilisateur accepte ou refuse]
     *     → onActivityResult ici
     *     → plugin.onVpnPermissionGranted() ou onVpnPermissionDenied()
     *     → HarmonyDnsVpnService démarré (si accordé)
     */
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == ContentFilterPlugin.VPN_REQUEST_CODE) {
            if (resultCode == Activity.RESULT_OK) {
                contentFilterPlugin?.onVpnPermissionGranted()
            } else {
                contentFilterPlugin?.onVpnPermissionDenied()
            }
        }
    }
}

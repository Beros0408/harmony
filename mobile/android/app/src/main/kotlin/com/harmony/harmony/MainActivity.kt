package com.harmony.harmony

// local_auth nécessite FlutterFragmentActivity pour la biométrie
import com.harmony.harmony.admin.DeviceAdminPlugin
import com.harmony.harmony.channel.CallFilterMethodChannel
import com.harmony.harmony.contacts.ContactsReaderPlugin
import com.harmony.harmony.messages.MessagesFilterPlugin
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {

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
    }
}

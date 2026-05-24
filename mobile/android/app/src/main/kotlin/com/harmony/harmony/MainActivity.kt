package com.harmony.harmony

// local_auth nécessite FlutterFragmentActivity pour la biométrie
import com.harmony.harmony.channel.CallFilterMethodChannel
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CallFilterMethodChannel.CHANNEL_NAME,
        ).setMethodCallHandler(CallFilterMethodChannel(this))
    }
}

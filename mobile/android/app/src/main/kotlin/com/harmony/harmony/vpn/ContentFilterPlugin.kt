package com.harmony.harmony.vpn

import android.app.Activity
import android.content.Intent
import android.net.VpnService
import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Pont Flutter ↔ Kotlin pour le contrôle du filtrage DNS.
 * Channel : "harmony/content_filter"
 *
 * Méthodes exposées :
 *   - startFiltering()  → String : "started" | "permission_required" | "error"
 *   - stopFiltering()   → String : "stopped"
 *   - isFiltering()     → Boolean
 *
 * Permission VPN (fire-and-forget) : si [VpnService.prepare] renvoie un Intent,
 * la boîte de dialogue système est ouverte (même pattern que requestAdmin).
 * L'app Flutter rappellera startFiltering() au prochain cycle de polling
 * (15 s) ; à ce moment VpnService.prepare() renverra null et le service démarrera.
 */
class ContentFilterPlugin(private val activity: Activity) : MethodChannel.MethodCallHandler {

    companion object {
        const val CHANNEL_NAME = "harmony/content_filter"
        private const val TAG  = "ContentFilterPlugin"
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startFiltering" -> handleStart(result)
            "stopFiltering"  -> handleStop(result)
            "isFiltering"    -> result.success(HarmonyDnsVpnService.isRunning)
            else             -> result.notImplemented()
        }
    }

    private fun handleStart(result: MethodChannel.Result) {
        try {
            val prepareIntent = VpnService.prepare(activity)
            if (prepareIntent != null) {
                // La permission VPN n'a pas encore été accordée par l'utilisateur.
                // Lance la boîte de dialogue Android (fire-and-forget).
                activity.startActivity(prepareIntent)
                Log.i(TAG, "Demande de permission VPN affichée")
                result.success("permission_required")
            } else {
                startVpnService()
                result.success("started")
            }
        } catch (e: Exception) {
            Log.e(TAG, "handleStart error: ${e.message}", e)
            result.success("error")
        }
    }

    private fun handleStop(result: MethodChannel.Result) {
        try {
            activity.startService(
                Intent(activity, HarmonyDnsVpnService::class.java).apply {
                    action = HarmonyDnsVpnService.ACTION_STOP
                }
            )
            result.success("stopped")
        } catch (e: Exception) {
            Log.e(TAG, "handleStop error: ${e.message}", e)
            result.success("error")
        }
    }

    private fun startVpnService() {
        activity.startForegroundService(
            Intent(activity, HarmonyDnsVpnService::class.java).apply {
                action = HarmonyDnsVpnService.ACTION_START
            }
        )
        Log.i(TAG, "HarmonyDnsVpnService démarré en foreground")
    }
}

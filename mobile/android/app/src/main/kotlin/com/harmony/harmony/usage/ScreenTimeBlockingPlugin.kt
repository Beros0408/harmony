package com.harmony.harmony.usage

import android.content.Context
import android.content.Intent
import android.provider.Settings
import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Pont Flutter ↔ Kotlin pour le blocage bienveillant des apps (Sprint 5C).
 * Channel : "harmony/screen_time_blocking"
 *
 * Méthodes exposées :
 *   - isAccessibilityGranted()        → Boolean
 *   - requestAccessibilitySettings()  : ouvre les réglages d'accessibilité Android.
 *   - updateBlockList(Map)            : met à jour l'état de blocage dans [HarmonyScreenTimeService].
 */
class ScreenTimeBlockingPlugin(private val context: Context) : MethodChannel.MethodCallHandler {

    companion object {
        const val CHANNEL_NAME = "harmony/screen_time_blocking"
        private const val TAG  = "ScreenTimeBlockingPlugin"
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isAccessibilityGranted"       -> result.success(isAccessibilityGranted())
            "requestAccessibilitySettings" -> handleOpenSettings(result)
            "updateBlockList"              -> handleUpdateBlockList(call, result)
            "setRemotePause"               -> handleSetRemotePause(call, result)
            else                           -> result.notImplemented()
        }
    }

    // ─── Vérification de la permission ────────────────────────────────────────

    /**
     * Vérifie si HarmonyScreenTimeService est activé dans les réglages d'accessibilité.
     * Utilise Settings.Secure pour éviter le cast vers AccessibilityManager.
     */
    private fun isAccessibilityGranted(): Boolean {
        val enabled = Settings.Secure.getString(
            context.contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES,
        ) ?: return false
        return enabled.contains("HarmonyScreenTimeService", ignoreCase = true)
    }

    // ─── Ouverture des réglages ────────────────────────────────────────────────

    private fun handleOpenSettings(result: MethodChannel.Result) {
        // Fire-and-forget : Flutter re-vérifie isAccessibilityGranted() au retour au premier plan
        context.startActivity(
            Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            },
        )
        result.success(null)
    }

    // ─── Mise à jour de la liste de blocage ───────────────────────────────────

    /**
     * Reçoit la liste des packages bloqués et le flag quota global depuis Flutter,
     * et met à jour les champs statiques de [HarmonyScreenTimeService].
     *
     * Payload attendu : { "blocked_packages": List<String>, "global_blocked": Boolean }
     */
    private fun handleUpdateBlockList(call: MethodCall, result: MethodChannel.Result) {
        val packages     = call.argument<List<String>>("blocked_packages") ?: emptyList()
        val globalBlocked = call.argument<Boolean>("global_blocked") ?: false

        HarmonyScreenTimeService.blockedPackages = packages.toSet()
        HarmonyScreenTimeService.isGlobalBlocked  = globalBlocked

        Log.d(
            TAG,
            "updateBlockList: global=$globalBlocked packages=${packages.size} → $packages",
        )
        result.success(null)
    }

    /**
     * Active ou désactive la pause distante parent (Sprint 5D-3).
     * Force une ré-évaluation immédiate de l'app en premier plan.
     *
     * Payload attendu : { "paused": Boolean }
     */
    private fun handleSetRemotePause(call: MethodCall, result: MethodChannel.Result) {
        val paused = call.argument<Boolean>("paused") ?: false
        HarmonyScreenTimeService.isRemotelyPaused = paused
        // Applique immédiatement sans attendre le prochain changement d'app
        HarmonyScreenTimeService.instance?.reevaluate()
        Log.d(TAG, "setRemotePause: paused=$paused")
        result.success(null)
    }
}

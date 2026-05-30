package com.harmony.harmony.admin

import android.app.Activity
import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Intent
import android.util.Log
import com.harmony.harmony.R
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Pont Flutter ↔ Kotlin pour le verrouillage d'écran via DevicePolicyManager.
 * Channel : "harmony/device_admin"
 *
 * Méthodes exposées :
 *   - isAdminActive()  → Boolean : le mode administrateur est-il accordé ?
 *   - requestAdmin()   : lance l'intent système pour demander les droits admin.
 *   - lockNow()        : verrouille l'écran immédiatement (nécessite admin actif).
 */
class DeviceAdminPlugin(private val activity: Activity) : MethodChannel.MethodCallHandler {

    companion object {
        const val CHANNEL_NAME = "harmony/device_admin"
        private const val TAG = "DeviceAdminPlugin"
    }

    private val dpm: DevicePolicyManager by lazy {
        activity.getSystemService(DevicePolicyManager::class.java)
    }

    // ComponentName identifiant notre DeviceAdminReceiver
    private val adminComponent: ComponentName by lazy {
        ComponentName(activity, HarmonyDeviceAdminReceiver::class.java)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isAdminActive" -> result.success(dpm.isAdminActive(adminComponent))
            "requestAdmin"  -> handleRequestAdmin(result)
            "lockNow"       -> handleLockNow(result)
            else            -> result.notImplemented()
        }
    }

    /**
     * Lance l'écran système Android qui demande à l'utilisateur d'accorder
     * les droits d'administrateur d'appareil à Harmony Kids.
     * Fire-and-forget : Flutter re-vérifie isAdminActive() après le retour.
     */
    private fun handleRequestAdmin(result: MethodChannel.Result) {
        val intent = Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN).apply {
            putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, adminComponent)
            putExtra(
                DevicePolicyManager.EXTRA_ADD_EXPLANATION,
                activity.getString(R.string.device_admin_description),
            )
        }
        activity.startActivity(intent)
        // La réponse est fire-and-forget : l'utilisateur revient dans l'app
        // et Flutter rappelle isAdminActive() pour mettre à jour l'UI.
        result.success(null)
    }

    /**
     * Verrouille l'écran immédiatement via DevicePolicyManager.lockNow().
     * Renvoie une erreur si le mode admin n'est pas actif.
     */
    private fun handleLockNow(result: MethodChannel.Result) {
        if (!dpm.isAdminActive(adminComponent)) {
            result.error(
                "ADMIN_NOT_ACTIVE",
                "Le mode administrateur n'est pas activé. Active-le d'abord.",
                null,
            )
            return
        }
        try {
            dpm.lockNow()
            Log.i(TAG, "Écran verrouillé via lockNow()")
            result.success(null)
        } catch (e: SecurityException) {
            Log.e(TAG, "lockNow() échoué : ${e.message}")
            result.error("LOCK_FAILED", "Échec du verrouillage : ${e.message}", null)
        }
    }
}

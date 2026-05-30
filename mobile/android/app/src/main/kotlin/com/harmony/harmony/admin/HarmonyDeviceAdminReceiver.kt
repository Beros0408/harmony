package com.harmony.harmony.admin

import android.app.admin.DeviceAdminReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * Récepteur DeviceAdmin pour Harmony Kids.
 * Déclaré dans AndroidManifest avec la politique "force-lock" (res/xml/device_admin.xml).
 * Reçoit les broadcasts système liés au cycle de vie de l'admin.
 */
class HarmonyDeviceAdminReceiver : DeviceAdminReceiver() {

    companion object {
        private const val TAG = "HarmonyDeviceAdmin"
    }

    override fun onEnabled(context: Context, intent: Intent) {
        Log.i(TAG, "Mode administrateur activé — verrouillage d'écran disponible")
    }

    override fun onDisabled(context: Context, intent: Intent) {
        Log.i(TAG, "Mode administrateur désactivé")
    }

    override fun onDisableRequested(context: Context, intent: Intent): CharSequence {
        return "La désactivation supprimera la capacité de verrouiller l'écran à distance."
    }
}

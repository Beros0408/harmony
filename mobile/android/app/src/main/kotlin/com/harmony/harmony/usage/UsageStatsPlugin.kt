package com.harmony.harmony.usage

import android.app.AppOpsManager
import android.app.Activity
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Process
import android.provider.Settings
import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.Calendar

/**
 * Pont Flutter ↔ Kotlin pour la mesure du temps d'écran via UsageStatsManager.
 * Channel : "harmony/usage_stats"
 *
 * Méthodes exposées :
 *   - isPermissionGranted() → Boolean : PACKAGE_USAGE_STATS est-il accordé ?
 *   - requestPermission()   : ouvre les réglages Android USAGE_ACCESS (fire-and-forget).
 *   - getDailyUsage()       → List<Map> : usage par app depuis 00:00 jusqu'à maintenant.
 */
class UsageStatsPlugin(private val activity: Activity) : MethodChannel.MethodCallHandler {

    companion object {
        const val CHANNEL_NAME = "harmony/usage_stats"
        private const val TAG = "UsageStatsPlugin"

        // Packages système évidents à exclure (launchers, UI système)
        private val EXCLUDED_PACKAGES = setOf(
            "com.android.launcher3",
            "com.android.launcher",
            "com.sec.android.app.launcher",
            "com.huawei.android.launcher",
            "com.miui.home",
            "com.google.android.apps.nexuslauncher",
            "com.android.settings",
            "com.android.systemui",
            "android",
        )

        // Seuil minimum : ignorer les apps avec moins d'une minute d'usage
        private const val MIN_USAGE_SECONDS = 60L
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isPermissionGranted" -> result.success(isPermissionGranted())
            "requestPermission"   -> handleRequestPermission(result)
            "getDailyUsage"       -> handleGetDailyUsage(result)
            else                  -> result.notImplemented()
        }
    }

    fun isPermissionGranted(): Boolean {
        val appOps = activity.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            Process.myUid(),
            activity.packageName,
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun handleRequestPermission(result: MethodChannel.Result) {
        // Fire-and-forget : Flutter re-vérifie isPermissionGranted() lors du retour au premier plan
        activity.startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
        result.success(null)
    }

    private fun handleGetDailyUsage(result: MethodChannel.Result) {
        if (!isPermissionGranted()) {
            result.error("PERMISSION_DENIED", "PACKAGE_USAGE_STATS non accordée", null)
            return
        }
        try {
            val usm = activity.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
            val pm  = activity.packageManager

            // Fenêtre : 00:00 du jour courant → maintenant
            val startMs = Calendar.getInstance().apply {
                set(Calendar.HOUR_OF_DAY, 0)
                set(Calendar.MINUTE, 0)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
            }.timeInMillis
            val endMs = System.currentTimeMillis()

            val statsMap = usm.queryAndAggregateUsageStats(startMs, endMs)

            val entries = mutableListOf<Map<String, Any?>>()
            for ((pkg, stats) in statsMap) {
                if (EXCLUDED_PACKAGES.contains(pkg)) continue
                val seconds = stats.totalTimeInForeground / 1000L
                if (seconds < MIN_USAGE_SECONDS) continue

                val label: String? = try {
                    pm.getApplicationLabel(pm.getApplicationInfo(pkg, 0)).toString()
                } catch (_: PackageManager.NameNotFoundException) { null }

                val category: String? = try {
                    val info = pm.getApplicationInfo(pkg, 0)
                    mapCategory(info.category)
                } catch (_: PackageManager.NameNotFoundException) { null }

                entries.add(
                    mapOf(
                        "package_name"     to pkg,
                        "app_label"        to label,
                        "category"         to category,
                        "duration_seconds" to seconds.toInt(),
                    )
                )
            }

            Log.i(TAG, "getDailyUsage() → ${entries.size} apps remontées")
            result.success(entries)
        } catch (e: Exception) {
            Log.e(TAG, "getDailyUsage() erreur : ${e.message}")
            result.error("GET_USAGE_ERROR", "Impossible de lire l'usage : ${e.message}", null)
        }
    }

    /**
     * Traduit ApplicationInfo.category en chaîne exploitable côté Flutter.
     * Sur API < 26, category vaut CATEGORY_UNDEFINED (-1) → null.
     */
    private fun mapCategory(category: Int): String? = when (category) {
        0    -> "games"        // CATEGORY_GAME
        1    -> "music"        // CATEGORY_AUDIO
        2    -> "video"        // CATEGORY_VIDEO
        3    -> "photo"        // CATEGORY_IMAGE
        4    -> "social"       // CATEGORY_SOCIAL
        5    -> "news"         // CATEGORY_NEWS
        6    -> "maps"         // CATEGORY_MAPS
        7    -> "productivity" // CATEGORY_PRODUCTIVITY
        else -> null
    }
}

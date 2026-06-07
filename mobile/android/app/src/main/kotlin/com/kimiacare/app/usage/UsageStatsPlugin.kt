package com.kimiacare.app.usage

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

        // ─── Mapping ApplicationInfo.category (entier API Android) ──────────────

        /**
         * Traduit ApplicationInfo.category en clé de catégorie Harmony.
         * Sur API < 26, category vaut CATEGORY_UNDEFINED (-1) → null.
         * Renvoie null si la catégorie Android ne correspond à aucune cible
         * (photo, news, maps) afin que [mapCategoryByPackage] prenne le relais.
         */
        internal fun mapCategory(category: Int): String? = when (category) {
            0    -> "games"        // CATEGORY_GAME
            1    -> "music"        // CATEGORY_AUDIO
            2    -> "video"        // CATEGORY_VIDEO
            4    -> "social"       // CATEGORY_SOCIAL
            7    -> "productivity" // CATEGORY_PRODUCTIVITY
            // 3 (IMAGE), 5 (NEWS), 6 (MAPS) : pas de catégorie cible → fallback package
            else -> null
        }

        // ─── Mapping de repli par nom de paquet connu ────────────────────────────

        /** Associations package → catégorie pour les apps les plus courantes. */
        internal val PACKAGE_CATEGORY_MAP: Map<String, String> = mapOf(
            // Réseaux sociaux
            "com.instagram.android"               to "social",
            "com.facebook.katana"                 to "social",
            "com.twitter.android"                 to "social",
            "com.snapchat.android"                to "social",
            "com.zhiliaoapp.musically"            to "social",   // TikTok
            "com.ss.android.ugc.trill"            to "social",   // TikTok alt
            "com.linkedin.android"                to "social",
            "com.pinterest"                       to "social",
            "com.reddit.frontpage"                to "social",
            "com.discord"                         to "social",
            "com.tumblr"                          to "social",
            // Vidéo & streaming
            "com.google.android.youtube"          to "video",
            "com.netflix.mediaclient"             to "video",
            "com.amazon.avod.thirdpartyclient"    to "video",    // Prime Video
            "com.disney.disneyplus"               to "video",
            "com.hbo.hbonow"                      to "video",
            "com.twitch.android.app"              to "video",
            "com.dailymotion.dailymotion"         to "video",
            "tv.pluto.android"                    to "video",
            // Messagerie & appels
            "com.whatsapp"                        to "communication",
            "com.facebook.orca"                   to "communication",  // Messenger
            "org.telegram.messenger"              to "communication",
            "com.viber.voip"                      to "communication",
            "com.skype.raider"                    to "communication",
            "us.zoom.videomeetings"               to "communication",
            "com.google.android.apps.messaging"   to "communication",
            "com.samsung.android.messaging"       to "communication",
            "com.android.mms"                     to "communication",
            "com.microsoft.teams"                 to "communication",
            // Musique & audio
            "com.spotify.music"                   to "music",
            "com.google.android.music"            to "music",
            "com.google.android.apps.youtube.music" to "music",
            "com.deezer.android"                  to "music",
            "com.soundcloud.android"              to "music",
            "com.amazon.mp3"                      to "music",
            "com.shazam.android"                  to "music",
            "com.pandora.android"                 to "music",
            // Navigateur web
            "com.android.chrome"                  to "browser",
            "org.mozilla.firefox"                 to "browser",
            "com.opera.browser"                   to "browser",
            "com.brave.browser"                   to "browser",
            "com.microsoft.emmx"                  to "browser",  // Edge
            "com.sec.android.app.sbrowser"        to "browser",  // Samsung Internet
            "com.ucmobile.intl"                   to "browser",
            // Éducation
            "com.duolingo"                        to "education",
            "org.khanacademy.android"             to "education",
            "com.google.android.apps.classroom"   to "education",
            "com.coursera.android"                to "education",
            "com.quizlet.quizletandroid"          to "education",
            // Jeux
            "com.supercell.clashofclans"          to "games",
            "com.supercell.clashroyale"           to "games",
            "com.mojang.minecraftpe"              to "games",
            "com.roblox.client"                   to "games",
            "com.king.candycrushsaga"             to "games",
            "com.activision.callofduty.shooter"   to "games",
            "com.epicgames.fortnite"              to "games",
            "com.pubg.krmobile"                   to "games",
            "com.ea.game.pvzfree_row"             to "games",
            // Productivité
            "com.microsoft.office.outlook"        to "productivity",
            "com.google.android.gm"               to "productivity",  // Gmail
            "com.microsoft.office.word"           to "productivity",
            "com.google.android.apps.docs"        to "productivity",
            "com.google.android.calendar"         to "productivity",
            "com.notion.id"                       to "productivity",
            "com.slack"                           to "productivity",
            "com.evernote"                        to "productivity",
            "com.todoist.android.Todoist"         to "productivity",
        )

        /**
         * Cherche la catégorie d'une app par son nom de paquet.
         * Retourne null si l'app n'est pas dans la liste connue.
         */
        internal fun mapCategoryByPackage(packageName: String): String? =
            PACKAGE_CATEGORY_MAP[packageName]
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

                // Chaîne de résolution : catégorie API Android → repli par package → "other"
                val category: String = try {
                    val info = pm.getApplicationInfo(pkg, 0)
                    mapCategory(info.category) ?: mapCategoryByPackage(pkg) ?: "other"
                } catch (_: PackageManager.NameNotFoundException) {
                    mapCategoryByPackage(pkg) ?: "other"
                }

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
}

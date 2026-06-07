package com.kimiacare.app.vpn

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
 * Flux de permission VPN (correction Sprint C bugfix) :
 *   VpnService.prepare() doit être lancé via startActivityForResult — pas
 *   startActivity — car Android 10+ exige un receiver de résultat enregistré
 *   pour afficher le dialog système et enregistrer la permission.
 *   Le résultat est capturé dans MainActivity.onActivityResult.
 *
 * Anti-spam : [permissionPending] est mis à true dès que startActivityForResult
 * est appelé. Il passe à false uniquement quand onActivityResult répond
 * (accordé ou refusé). Pendant ce temps les appels startFiltering() retournent
 * immédiatement "permission_required" sans relancer de dialog.
 * Un cooldown d'une minute s'ajoute après un refus pour éviter la boucle en cas
 * de rejet silencieux (app en arrière-plan, restriction background Android 10+).
 */
class ContentFilterPlugin(private val activity: Activity) : MethodChannel.MethodCallHandler {

    companion object {
        const val CHANNEL_NAME      = "harmony/content_filter"
        const val VPN_REQUEST_CODE  = 7001
        private const val TAG       = "ContentFilterPlugin"

        // Cooldown d'une minute après refus/rejet silencieux (background)
        private const val PERMISSION_COOLDOWN_MS = 60_000L

        @Volatile var permissionPending       = false
            private set
        @Volatile private var lastRequestTime = 0L
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startFiltering" -> handleStart(result)
            "stopFiltering"  -> handleStop(result)
            "isFiltering"    -> result.success(HarmonyDnsVpnService.isRunning)
            else             -> result.notImplemented()
        }
    }

    // ── Démarrage avec gestion de permission ─────────────────────────────────

    private fun handleStart(result: MethodChannel.Result) {
        try {
            // 1. Si une demande est déjà en attente de réponse, ne pas relancer.
            if (permissionPending) {
                Log.d(TAG, "Permission VPN déjà en attente — dialog déjà affiché")
                result.success("permission_required")
                return
            }

            // 2. Cooldown post-refus pour éviter la boucle en arrière-plan.
            val now = System.currentTimeMillis()
            if (now - lastRequestTime < PERMISSION_COOLDOWN_MS) {
                Log.d(TAG, "Cooldown actif — prochain essai dans ${(PERMISSION_COOLDOWN_MS - (now - lastRequestTime)) / 1000}s")
                result.success("permission_required")
                return
            }

            val prepareIntent = VpnService.prepare(activity)
            if (prepareIntent != null) {
                // Permission pas encore accordée : afficher le dialog système via
                // startActivityForResult (requis par l'API Android — startActivity
                // ne fonctionne pas et n'affiche pas le dialog sur Android 10+).
                permissionPending = true
                lastRequestTime   = now
                activity.startActivityForResult(prepareIntent, VPN_REQUEST_CODE)
                Log.i(TAG, "Dialog permission VPN lancé via startActivityForResult")
                result.success("permission_required")
            } else {
                // Permission déjà accordée — démarrer directement le service.
                startVpnService()
                result.success("started")
            }
        } catch (e: Exception) {
            Log.e(TAG, "handleStart error: ${e.message}", e)
            permissionPending = false
            result.success("error")
        }
    }

    // ── Callbacks depuis MainActivity.onActivityResult ────────────────────────

    /** Appelé par MainActivity quand l'utilisateur a accordé la permission VPN. */
    fun onVpnPermissionGranted() {
        permissionPending = false
        Log.i(TAG, "Permission VPN accordée — démarrage du service")
        startVpnService()
    }

    /** Appelé par MainActivity quand l'utilisateur a refusé (ou rejet silencieux en background). */
    fun onVpnPermissionDenied() {
        permissionPending = false
        // lastRequestTime reste à sa valeur : le cooldown s'applique au prochain essai.
        Log.w(TAG, "Permission VPN refusée ou dialog annulé")
    }

    // ── Arrêt ────────────────────────────────────────────────────────────────

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

    // ── Démarrage interne du VpnService ──────────────────────────────────────

    fun startVpnService() {
        activity.startForegroundService(
            Intent(activity, HarmonyDnsVpnService::class.java).apply {
                action = HarmonyDnsVpnService.ACTION_START
            }
        )
        Log.i(TAG, "HarmonyDnsVpnService démarré en foreground")
    }
}

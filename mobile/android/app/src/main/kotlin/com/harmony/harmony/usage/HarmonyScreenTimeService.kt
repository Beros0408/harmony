package com.harmony.harmony.usage

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Context
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.Typeface
import android.util.Log
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.view.accessibility.AccessibilityEvent
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView

/**
 * Service d'accessibilité — détecte l'app au premier plan et affiche un overlay bienveillant
 * quand une limite de temps d'écran est dépassée.
 *
 * État mis à jour par [ScreenTimeBlockingPlugin] via MethodChannel depuis Flutter.
 * L'overlay utilise TYPE_ACCESSIBILITY_OVERLAY (pas besoin de SYSTEM_ALERT_WINDOW).
 */
class HarmonyScreenTimeService : AccessibilityService() {

    companion object {
        private const val TAG = "HarmonyScreenTimeSvc"

        // Packages à ne JAMAIS bloquer — casser ces apps rendrait l'appareil inutilisable
        val NEVER_BLOCK: Set<String> = setOf(
            "com.harmony.harmony",                        // Harmony Kids elle-même
            "android",                                    // Système Android
            "com.android.systemui",                       // UI système (barre de statut, etc.)
            "com.android.settings",                       // Réglages Android
            "com.google.android.dialer",                  // Téléphone Google
            "com.android.phone",                          // Téléphone AOSP
            "com.android.emergency",                      // Appels d'urgence
            "com.samsung.android.dialer",                 // Téléphone Samsung
            "com.google.android.packageinstaller",        // Installeur de paquets
            "com.android.packageinstaller",
            "com.google.android.permissioncontroller",    // Gestion permissions Android
            // Launchers courants — bloquer le launcher casserait complètement le téléphone
            "com.android.launcher",
            "com.android.launcher2",
            "com.android.launcher3",
            "com.google.android.apps.nexuslauncher",
            "com.sec.android.app.launcher",               // Samsung One UI
            "com.huawei.android.launcher",
            "com.miui.home",                              // MIUI (Xiaomi)
            "com.oneplus.launcher",
            "com.bbk.launcher2",                          // Vivo
            "com.oppo.launcher",
        )

        // Mis à jour par ScreenTimeBlockingPlugin — @Volatile pour visibilité cross-thread
        @Volatile var blockedPackages: Set<String> = emptySet()
        @Volatile var isGlobalBlocked: Boolean = false
    }

    private var overlayView: View? = null
    private var lastForegroundPkg: String = ""

    override fun onServiceConnected() {
        super.onServiceConnected()
        val info = AccessibilityServiceInfo().apply {
            eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            notificationTimeout = 100
        }
        serviceInfo = info
        Log.i(TAG, "Service d'accessibilité connecté")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event?.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return
        val pkg = event.packageName?.toString()?.takeIf { it.isNotEmpty() } ?: return
        // Ignorer les événements répétés pour le même package (dialogues, etc.)
        if (pkg == lastForegroundPkg) return
        lastForegroundPkg = pkg
        evaluatePackage(pkg)
    }

    /** Détermine si le package doit être bloqué et affiche/cache l'overlay en conséquence. */
    private fun evaluatePackage(pkg: String) {
        if (NEVER_BLOCK.contains(pkg)) {
            hideOverlay()
            return
        }

        val appLimitExceeded = blockedPackages.contains(pkg)
        val shouldBlock = appLimitExceeded || isGlobalBlocked

        if (shouldBlock) {
            Log.d(TAG, "Blocage: $pkg (global=$isGlobalBlocked appLimit=$appLimitExceeded)")
            showOverlay(isGlobal = isGlobalBlocked && !appLimitExceeded)
        } else {
            hideOverlay()
        }
    }

    // ─── Overlay ──────────────────────────────────────────────────────────────

    private fun showOverlay(isGlobal: Boolean) {
        if (overlayView != null) return // déjà affiché
        try {
            val view = buildOverlayView(isGlobal)
            val params = WindowManager.LayoutParams(
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
                PixelFormat.OPAQUE,
            )
            (getSystemService(Context.WINDOW_SERVICE) as WindowManager).addView(view, params)
            overlayView = view
        } catch (e: Exception) {
            Log.e(TAG, "Impossible d'afficher l'overlay: ${e.message}")
            // Fallback fiable : retour au lanceur
            performGlobalAction(GLOBAL_ACTION_HOME)
        }
    }

    private fun hideOverlay() {
        val view = overlayView ?: return
        try {
            (getSystemService(Context.WINDOW_SERVICE) as WindowManager).removeView(view)
        } catch (_: Exception) {}
        overlayView = null
    }

    /**
     * Construit la vue overlay bienveillante (dark mode Harmony) sans layout XML.
     * Ton doux, pas punitif — encourage la pause plutôt que de sanctionner.
     */
    private fun buildOverlayView(isGlobal: Boolean): LinearLayout {
        val bgColor      = Color.parseColor("#0A0F1E") // AppColors.bgBase
        val textPrimary  = Color.parseColor("#E8EDF5") // AppColors.textPrimary
        val textMuted    = Color.parseColor("#8BA3C7") // AppColors.textSecondary
        val accentBlue   = Color.parseColor("#3B82F6") // AppColors.accentBlue

        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setBackgroundColor(bgColor)
            val pad = dp(32)
            setPadding(pad, dp(64), pad, dp(64))
        }

        // Emoji lune — douceur, non punitif
        root.addView(TextView(this).apply {
            text = "🌙"
            textSize = 56f
            gravity = Gravity.CENTER
        })

        // Titre principal
        root.addView(TextView(this).apply {
            text = "C'est l'heure d'une pause"
            textSize = 20f
            setTextColor(textPrimary)
            gravity = Gravity.CENTER
            typeface = Typeface.DEFAULT_BOLD
            setPadding(0, dp(24), 0, dp(12))
        })

        // Message explicatif selon le type de limite
        val msg = if (isGlobal)
            "Tu as atteint ton quota de temps d'écran pour aujourd'hui.\nReviens demain, bonne nuit ! 🌟"
        else
            "Tu as utilisé tout ton temps pour cette application aujourd'hui.\nEssaie autre chose !"

        root.addView(TextView(this).apply {
            text = msg
            textSize = 15f
            setTextColor(textMuted)
            gravity = Gravity.CENTER
            setLineSpacing(0f, 1.5f)
            setPadding(dp(8), 0, dp(8), dp(56))
        })

        // Bouton "Retour à l'accueil" — seule action possible
        root.addView(Button(this).apply {
            text = "Retour à l'accueil"
            setTextColor(Color.WHITE)
            setBackgroundColor(accentBlue)
            textSize = 15f
            val lp = LinearLayout.LayoutParams(dp(220), dp(52))
            layoutParams = lp
            setOnClickListener {
                performGlobalAction(GLOBAL_ACTION_HOME)
                // L'event TYPE_WINDOW_STATE_CHANGED du launcher masquera l'overlay automatiquement
            }
        })

        return root
    }

    private fun dp(value: Int): Int =
        (value * resources.displayMetrics.density).toInt()

    override fun onInterrupt() {
        hideOverlay()
        Log.i(TAG, "Service interrompu")
    }

    override fun onDestroy() {
        hideOverlay()
        Log.i(TAG, "Service détruit")
        super.onDestroy()
    }
}

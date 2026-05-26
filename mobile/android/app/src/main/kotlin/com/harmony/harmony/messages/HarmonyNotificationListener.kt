package com.harmony.harmony.messages

import android.app.Notification
import android.os.Bundle
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import java.util.UUID
import java.util.concurrent.CopyOnWriteArrayList

/**
 * Service système qui écoute toutes les notifications postées sur l'appareil.
 * Filtre par package pour ne capturer que WhatsApp, Signal et Telegram.
 * Les messages captés sont stockés en mémoire dans [interceptedMessages].
 *
 * L'utilisateur doit activer l'accès dans :
 * Paramètres → Applications → Accès spécial → Accès aux notifications → Harmony
 */
class HarmonyNotificationListener : NotificationListenerService() {

    companion object {
        private const val TAG = "HARMONY-MESSAGES"

        /** Packages autorisés à être capturés. */
        private val WATCHED_PACKAGES = setOf(
            "com.whatsapp",
            "org.thoughtcrime.securesms",  // Signal
            "org.telegram.messenger",
        )

        /** File de messages capturés — thread-safe, max 200 entrées. */
        val interceptedMessages: CopyOnWriteArrayList<Map<String, Any>> = CopyOnWriteArrayList()
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        sbn ?: return
        val pkg = sbn.packageName ?: return
        if (pkg !in WATCHED_PACKAGES) return

        val extras: Bundle = sbn.notification?.extras ?: return
        val title = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString() ?: ""
        val text = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString() ?: ""

        // Ignorer les notifications de groupe ou de résumé (pas de contenu réel)
        if (text.isBlank()) return

        Log.d(TAG, "onNotificationPosted: pkg=$pkg sender='$title' content='${text.take(40)}'")

        val message = mapOf<String, Any>(
            "id" to UUID.randomUUID().toString(),
            "sender" to title,
            "content" to text,
            "timestamp" to System.currentTimeMillis(),
            "packageName" to pkg,
            "isBlocked" to false,
        )

        // Limiter la file à 200 messages (FIFO)
        if (interceptedMessages.size >= 200) {
            interceptedMessages.removeAt(0)
        }
        interceptedMessages.add(message)
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification?) {
        // Non traité au Sprint 6
    }
}

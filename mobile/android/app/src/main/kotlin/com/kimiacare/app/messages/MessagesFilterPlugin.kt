package com.kimiacare.app.messages

import android.content.ContentResolver
import android.content.Context
import android.content.Intent
import android.database.Cursor
import android.provider.Settings
import android.provider.Telephony
import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.UUID

/**
 * Plugin natif pour le filtrage des messages (Sprint 6).
 * MethodChannel : com.kimiacare.app/messages_filter
 *
 * Méthodes exposées :
 *   - isNotificationListenerEnabled() : bool
 *   - requestNotificationListenerAccess() : void (ouvre les Settings système)
 *   - readRecentSms(limit) : List<Map>
 *   - getInterceptedNotifications() : List<Map>
 */
class MessagesFilterPlugin(private val context: Context) : MethodChannel.MethodCallHandler {

    companion object {
        const val CHANNEL_NAME = "com.kimiacare.app/messages_filter"
        private const val TAG = "HARMONY-MESSAGES"
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "onMethodCall: ${call.method}")
        when (call.method) {
            "isNotificationListenerEnabled" -> {
                result.success(isListenerEnabled())
            }
            "requestNotificationListenerAccess" -> {
                openListenerSettings()
                result.success(null)
            }
            "readRecentSms" -> {
                val limit = call.argument<Int>("limit") ?: 50
                try {
                    val messages = readRecentSms(limit)
                    Log.d(TAG, "readRecentSms() → ${messages.size} SMS")
                    result.success(messages)
                } catch (e: SecurityException) {
                    Log.e(TAG, "readRecentSms() SecurityException: ${e.message}")
                    result.error("PERMISSION_DENIED", e.message, null)
                } catch (e: Exception) {
                    Log.e(TAG, "readRecentSms() exception: ${e.message}", e)
                    result.error("READ_SMS_ERROR", e.message, null)
                }
            }
            "getInterceptedNotifications" -> {
                val notifications = HarmonyNotificationListener.interceptedMessages.toList()
                Log.d(TAG, "getInterceptedNotifications() → ${notifications.size} notifications")
                result.success(notifications)
            }
            else -> result.notImplemented()
        }
    }

    /** Vérifie si Harmony est dans la liste des applications autorisées à écouter les notifications. */
    private fun isListenerEnabled(): Boolean {
        val enabledListeners = Settings.Secure.getString(
            context.contentResolver,
            "enabled_notification_listeners",
        ) ?: return false
        val packageName = context.packageName
        val enabled = enabledListeners.contains(packageName)
        Log.d(TAG, "isListenerEnabled() → $enabled (listeners=$enabledListeners)")
        return enabled
    }

    /** Ouvre l'écran système de gestion des accès aux notifications. */
    private fun openListenerSettings() {
        val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        context.startActivity(intent)
    }

    /**
     * Lit les SMS entrants depuis le ContentProvider Android.
     * Requiert la permission READ_SMS.
     */
    private fun readRecentSms(limit: Int): List<Map<String, Any>> {
        val cr: ContentResolver = context.contentResolver
        val messages = mutableListOf<Map<String, Any>>()

        val projection = arrayOf(
            Telephony.Sms._ID,
            Telephony.Sms.ADDRESS,
            Telephony.Sms.BODY,
            Telephony.Sms.DATE,
            Telephony.Sms.TYPE,
        )

        val cursor: Cursor? = cr.query(
            Telephony.Sms.CONTENT_URI,
            projection,
            "${Telephony.Sms.TYPE} = ?",
            arrayOf(Telephony.Sms.MESSAGE_TYPE_INBOX.toString()),
            "${Telephony.Sms.DATE} DESC",
        )

        Log.d(TAG, "readRecentSms() cursor count: ${cursor?.count ?: -1}")

        cursor?.use { c ->
            var count = 0
            while (c.moveToNext() && count < limit) {
                val id = c.safeGetString(Telephony.Sms._ID) ?: UUID.randomUUID().toString()
                val address = c.safeGetString(Telephony.Sms.ADDRESS) ?: ""
                val body = c.safeGetString(Telephony.Sms.BODY) ?: ""
                val date = c.safeGetLong(Telephony.Sms.DATE) ?: System.currentTimeMillis()

                Log.d(TAG, "  SMS: from=$address body='${body.take(30)}'")

                messages.add(
                    mapOf(
                        "id" to id,
                        "sender" to address,
                        "content" to body,
                        "timestamp" to date,
                        "packageName" to "sms",
                        "isBlocked" to false,
                    ),
                )
                count++
            }
        }

        return messages
    }

    private fun Cursor.safeGetString(columnName: String): String? {
        val idx = getColumnIndex(columnName)
        return if (idx >= 0 && !isNull(idx)) getString(idx) else null
    }

    private fun Cursor.safeGetLong(columnName: String): Long? {
        val idx = getColumnIndex(columnName)
        return if (idx >= 0 && !isNull(idx)) getLong(idx) else null
    }
}

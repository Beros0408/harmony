package com.harmony.harmony.channel

import android.app.Activity
import android.app.role.RoleManager
import android.os.Build
import android.util.Log
import androidx.annotation.RequiresApi
import com.harmony.harmony.calls.BlockedCall
import com.harmony.harmony.calls.CallDecisionEngine
import com.harmony.harmony.calls.CallLogStore
import com.harmony.harmony.calls.CallRules
import com.harmony.harmony.calls.FilterMode
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Pont Flutter ↔ Kotlin pour le filtrage d'appels.
 * Channel : "com.harmony.app/call_filter"
 */
class CallFilterMethodChannel(private val activity: Activity) :
    MethodChannel.MethodCallHandler {

    companion object {
        const val CHANNEL_NAME = "com.harmony.app/call_filter"
        private const val TAG = "CallFilterChannel"
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isDefaultScreeningApp" -> handleIsDefaultScreeningApp(result)
            "requestScreeningRole" -> handleRequestScreeningRole(result)
            "syncRules" -> handleSyncRules(call, result)
            "getBlockedCalls" -> handleGetBlockedCalls(result)
            "clearBlockedCalls" -> handleClearBlockedCalls(result)
            else -> result.notImplemented()
        }
    }

    private fun handleIsDefaultScreeningApp(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            result.success(false)
            return
        }
        val roleManager = activity.getSystemService(RoleManager::class.java)
        result.success(roleManager.isRoleHeld(RoleManager.ROLE_CALL_SCREENING))
    }

    @RequiresApi(Build.VERSION_CODES.Q)
    private fun handleRequestScreeningRole(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            result.success(false)
            return
        }
        val roleManager = activity.getSystemService(RoleManager::class.java)
        if (!roleManager.isRoleAvailable(RoleManager.ROLE_CALL_SCREENING)) {
            Log.w(TAG, "ROLE_CALL_SCREENING non disponible sur cet appareil")
            result.success(false)
            return
        }
        val intent = roleManager.createRequestRoleIntent(RoleManager.ROLE_CALL_SCREENING)
        activity.startActivity(intent)
        result.success(null) // Fire-and-forget — Flutter re-vérifie via isDefaultScreeningApp
    }

    @Suppress("UNCHECKED_CAST")
    private fun handleSyncRules(call: MethodCall, result: MethodChannel.Result) {
        val rawRules = call.argument<List<Map<String, Any>>>("rules") ?: emptyList()
        val whitelist = mutableSetOf<String>()
        val blacklist = mutableSetOf<String>()
        var mode = FilterMode.NORMAL
        var blockStart = 22
        var blockEnd = 7

        for (raw in rawRules) {
            when (raw["type"] as? String) {
                "whitelist" -> (raw["phoneNumber"] as? String)?.let { whitelist.add(it) }
                "blacklist" -> (raw["phoneNumber"] as? String)?.let { blacklist.add(it) }
                "mode" -> {
                    mode = when (raw["value"] as? String) {
                        "focus" -> FilterMode.FOCUS
                        "night" -> FilterMode.NIGHT
                        "emergency" -> FilterMode.EMERGENCY
                        else -> FilterMode.NORMAL
                    }
                }
                "blockHours" -> {
                    blockStart = (raw["start"] as? Int) ?: 22
                    blockEnd = (raw["end"] as? Int) ?: 7
                }
            }
        }

        CallDecisionEngine.updateRules(
            CallRules(
                whitelist = whitelist,
                blacklist = blacklist,
                currentMode = mode,
                blockHourStart = blockStart,
                blockHourEnd = blockEnd,
            ),
        )
        Log.d(TAG, "Règles synchronisées : ${whitelist.size} whitelist, ${blacklist.size} blacklist, mode=$mode")
        result.success(null)
    }

    private fun handleGetBlockedCalls(result: MethodChannel.Result) {
        val mapped = CallLogStore.calls.map { call: BlockedCall ->
            mapOf(
                "phoneNumber" to call.phoneNumber,
                "timestamp" to call.timestamp,
                "latencyMs" to call.latencyMs,
            )
        }
        result.success(mapped)
    }

    private fun handleClearBlockedCalls(result: MethodChannel.Result) {
        CallLogStore.clear()
        result.success(null)
    }
}

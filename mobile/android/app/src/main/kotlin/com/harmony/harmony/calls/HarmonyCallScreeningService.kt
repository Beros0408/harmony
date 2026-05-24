package com.harmony.harmony.calls

import android.telecom.Call
import android.telecom.CallScreeningService
import android.util.Log
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

/**
 * Service Android natif de filtrage des appels entrants.
 * Déclaré dans AndroidManifest avec BIND_SCREENING_SERVICE.
 *
 * Hot path : [onScreenCall] → [CallDecisionEngine.shouldBlock] → [respondToCall]
 * Latence cible : < 150 ms (KPI cahier des charges : 200 ms)
 */
class HarmonyCallScreeningService : CallScreeningService() {

    companion object {
        private const val TAG = "HarmonyCallScreening"
    }

    private val serviceScope = CoroutineScope(Dispatchers.IO + SupervisorJob())

    override fun onScreenCall(callDetails: Call.Details) {
        val startNano = System.nanoTime()
        val phoneNumber = callDetails.handle?.schemeSpecificPart ?: ""

        Log.d(TAG, "Appel entrant détecté : $phoneNumber")

        // Décision synchrone en mémoire — latence typique < 1 ms
        val shouldBlock = CallDecisionEngine.shouldBlock(phoneNumber)

        val latencyMs = (System.nanoTime() - startNano) / 1_000_000L
        Log.d(TAG, "Décision en ${latencyMs}ms : bloquer=$shouldBlock pour $phoneNumber")

        val response = CallScreeningService.CallResponse.Builder()
            .setDisallowCall(shouldBlock)
            .setRejectCall(shouldBlock)
            .setSkipCallLog(false)
            .setSkipNotification(shouldBlock)
            .build()

        respondToCall(callDetails, response)

        // Journalisation asynchrone — ne doit JAMAIS bloquer le hot path
        if (shouldBlock) {
            serviceScope.launch {
                CallLogStore.add(BlockedCall(phoneNumber = phoneNumber, latencyMs = latencyMs))
            }
        }
    }

    override fun onDestroy() {
        serviceScope.cancel()
        super.onDestroy()
    }
}

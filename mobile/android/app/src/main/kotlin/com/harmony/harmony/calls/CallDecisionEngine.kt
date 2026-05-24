package com.harmony.harmony.calls

/**
 * Moteur de décision de filtrage d'appels — entièrement en mémoire.
 *
 * Les règles sont synchronisées depuis Flutter via [updateRules] (MethodChannel).
 * [shouldBlock] est appelé dans le hot path du CallScreeningService : sa latence
 * doit rester < 150 ms (marge sur le KPI de 200 ms du cahier des charges).
 *
 * Ordre de priorité :
 *   1. Whitelist → toujours autoriser
 *   2. Mode EMERGENCY → tout passer sauf whitelist (déjà géré ci-dessus)
 *   3. Blacklist → bloquer
 *   4. Plage horaire nocturne active → bloquer si mode non-NORMAL
 *   5. Par défaut → autoriser
 */
object CallDecisionEngine {

    @Volatile
    private var rules = CallRules()

    /** Remplace atomiquement les règles actives (appelé depuis le MethodChannel). */
    fun updateRules(newRules: CallRules) {
        rules = newRules
    }

    /** Retourne true si l'appel doit être bloqué. Appel synchrone, < 1 ms. */
    fun shouldBlock(phoneNumber: String): Boolean {
        val r = rules // lecture atomique du snapshot immuable
        val normalized = normalizeNumber(phoneNumber)

        if (r.whitelist.any { normalizeNumber(it) == normalized }) return false
        if (r.currentMode == FilterMode.EMERGENCY) return false
        if (r.blacklist.any { normalizeNumber(it) == normalized }) return true
        if (r.isBlockingHour() && r.currentMode != FilterMode.NORMAL) return true
        return false
    }

    /** Normalise un numéro pour comparaison : retire espaces, tirets, parenthèses. */
    private fun normalizeNumber(number: String): String =
        number.filter { it.isDigit() || it == '+' }
}

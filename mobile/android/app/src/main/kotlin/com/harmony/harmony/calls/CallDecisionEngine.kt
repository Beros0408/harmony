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
 *   2. Mode EMERGENCY → bloquer tout sauf whitelist
 *   3. Blacklist → bloquer dans tous les modes
 *   4. Mode NORMAL → tout autoriser (pas de règle temporelle)
 *   5. Mode NIGHT : plage horaire → bloquer
 *   6. Mode FOCUS : plage horaire → bloquer
 *   7. Mode WORK : jour ouvré + plage horaire → bloquer
 *   8. Mode WEEKEND : week-end → bloquer
 *   9. Par défaut → autoriser
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

        // 1. Whitelist — priorité absolue
        if (r.whitelist.any { normalizeNumber(it) == normalized }) return false

        // 2. EMERGENCY — whitelist uniquement
        if (r.currentMode == FilterMode.EMERGENCY) return true

        // 3. Blacklist — bloqué dans tous les modes (y compris NORMAL)
        if (r.blacklist.any { normalizeNumber(it) == normalized }) return true

        // 4. NORMAL — aucune règle temporelle, laisser passer
        if (r.currentMode == FilterMode.NORMAL) return false

        // 5-8. Modes temporels
        return when (r.currentMode) {
            FilterMode.NIGHT -> r.isBlockingHour()
            FilterMode.FOCUS -> r.isBlockingHour()
            FilterMode.WORK  -> r.isWeekday() && r.isBlockingHour()
            FilterMode.WEEKEND -> r.isWeekend()
            else -> false
        }
    }

    /** Normalise un numéro pour comparaison : retire espaces, tirets, parenthèses. */
    private fun normalizeNumber(number: String): String =
        number.filter { it.isDigit() || it == '+' }
}

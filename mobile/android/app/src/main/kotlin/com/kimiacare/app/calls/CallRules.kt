package com.kimiacare.app.calls

import java.util.Calendar

/**
 * Snapshot immuable des règles de filtrage actives.
 * Remplacé atomiquement par [CallDecisionEngine.updateRules] sans verrou de lecture.
 */
data class CallRules(
    val whitelist: Set<String> = emptySet(),
    val blacklist: Set<String> = emptySet(),
    val currentMode: FilterMode = FilterMode.NORMAL,
    val blockHourStart: Int = 22,
    val blockHourEnd: Int = 7,
) {
    /** Vrai si l'heure actuelle est dans la plage de blocage nocturne. */
    fun isBlockingHour(): Boolean {
        val h = Calendar.getInstance().get(Calendar.HOUR_OF_DAY)
        return if (blockHourStart > blockHourEnd) {
            h >= blockHourStart || h < blockHourEnd
        } else {
            h in blockHourStart until blockHourEnd
        }
    }

    /** Vrai si aujourd'hui est un jour ouvré (lun–ven). */
    fun isWeekday(): Boolean {
        val dow = Calendar.getInstance().get(Calendar.DAY_OF_WEEK)
        return dow in Calendar.MONDAY..Calendar.FRIDAY
    }

    /** Vrai si aujourd'hui est un week-end (sam–dim). */
    fun isWeekend(): Boolean = !isWeekday()
}

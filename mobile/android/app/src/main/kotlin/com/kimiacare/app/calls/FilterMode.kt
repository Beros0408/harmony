package com.kimiacare.app.calls

enum class FilterMode {
    /** Aucun filtrage actif — tous les appels passent. */
    NORMAL,
    /** Focus : bloque les inconnus et la blacklist pendant les heures configurées. */
    FOCUS,
    /** Nuit : bloque tout sauf whitelist pendant la plage horaire nocturne. */
    NIGHT,
    /** Travail : comme FOCUS mais actif uniquement en semaine (lun–ven). */
    WORK,
    /** Week-end : bloque les appels professionnels (blacklist) sam–dim. */
    WEEKEND,
    /** Urgence : whitelist uniquement, tous les autres appels sont bloqués. */
    EMERGENCY,
}

package com.harmony.harmony.calls

/**
 * Journal en mémoire des appels bloqués (capacité : 1 000 entrées FIFO).
 * Accès thread-safe via synchronisation sur l'objet.
 */
object CallLogStore {

    private const val MAX_ENTRIES = 1_000
    private val _calls = ArrayDeque<BlockedCall>(MAX_ENTRIES)

    val calls: List<BlockedCall>
        @Synchronized get() = _calls.toList()

    @Synchronized
    fun add(call: BlockedCall) {
        if (_calls.size >= MAX_ENTRIES) _calls.removeFirst()
        _calls.addLast(call)
    }

    @Synchronized
    fun clear() = _calls.clear()
}

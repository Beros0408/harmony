package com.harmony.harmony.calls

data class BlockedCall(
    val phoneNumber: String,
    val timestamp: Long = System.currentTimeMillis(),
    val latencyMs: Long,
)

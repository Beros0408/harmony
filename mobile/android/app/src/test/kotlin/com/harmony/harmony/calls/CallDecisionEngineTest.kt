package com.harmony.harmony.calls

import org.assertj.core.api.Assertions.assertThat
import org.junit.Before
import org.junit.Test

class CallDecisionEngineTest {

    private val whitelist = setOf("+33601234567")
    private val blacklist = setOf(
        "+33698765432", "+33611111111", "+33622222222",
        "+33633333333", "+33644444444",
    )

    @Before
    fun setUp() {
        CallDecisionEngine.updateRules(
            CallRules(
                whitelist = whitelist,
                blacklist = blacklist,
                currentMode = FilterMode.NORMAL,
            ),
        )
    }

    @Test
    fun `numéro en whitelist n'est jamais bloqué`() {
        assertThat(CallDecisionEngine.shouldBlock("+33601234567")).isFalse()
    }

    @Test
    fun `numéro en blacklist est bloqué`() {
        assertThat(CallDecisionEngine.shouldBlock("+33698765432")).isTrue()
    }

    @Test
    fun `numéro inconnu en mode NORMAL n'est pas bloqué`() {
        assertThat(CallDecisionEngine.shouldBlock("+33600000000")).isFalse()
    }

    @Test
    fun `whitelist prend priorité sur blacklist`() {
        // Numéro à la fois en whitelist et blacklist → whitelist gagne
        CallDecisionEngine.updateRules(
            CallRules(
                whitelist = setOf("+33600000000"),
                blacklist = setOf("+33600000000"),
                currentMode = FilterMode.NORMAL,
            ),
        )
        assertThat(CallDecisionEngine.shouldBlock("+33600000000")).isFalse()
    }

    @Test
    fun `mode EMERGENCY autorise tout sauf blacklist gérée par whitelist`() {
        CallDecisionEngine.updateRules(
            CallRules(
                whitelist = emptySet(),
                blacklist = setOf("+33699999999"),
                currentMode = FilterMode.EMERGENCY,
            ),
        )
        // En mode EMERGENCY, blacklist ignorée (tout passe)
        assertThat(CallDecisionEngine.shouldBlock("+33699999999")).isFalse()
        assertThat(CallDecisionEngine.shouldBlock("+33600000000")).isFalse()
    }

    @Test
    fun `latence moyenne sur 1000 décisions est inférieure à 200ms`() {
        CallDecisionEngine.updateRules(
            CallRules(
                whitelist = whitelist,
                blacklist = blacklist,
                currentMode = FilterMode.NORMAL,
            ),
        )

        val testNumbers = (0 until 1000).map { i ->
            when {
                i % 5 == 0 -> "+33601234567"   // whitelist
                i % 7 == 0 -> "+33698765432"   // blacklist
                else -> "+336${i.toString().padStart(8, '0')}" // inconnu
            }
        }

        val timings = LongArray(testNumbers.size)
        for (i in testNumbers.indices) {
            val start = System.nanoTime()
            CallDecisionEngine.shouldBlock(testNumbers[i])
            timings[i] = (System.nanoTime() - start) / 1_000_000L
        }

        val avg = timings.average()
        val p95 = timings.sorted()[949]
        val max = timings.max()

        println("=== Latence CallDecisionEngine ===")
        println("Moyenne : ${avg}ms  |  P95 : ${p95}ms  |  Max : ${max}ms")

        assertThat(avg).isLessThan(200.0)
        assertThat(p95).isLessThan(200L)
    }
}

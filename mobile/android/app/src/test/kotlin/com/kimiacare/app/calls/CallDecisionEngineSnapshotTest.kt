package com.kimiacare.app.calls

import org.assertj.core.api.Assertions.assertThat
import org.junit.Before
import org.junit.Test
import java.util.concurrent.CountDownLatch
import java.util.concurrent.Executors

/**
 * Vérifie la cohérence du snapshot atomique @Volatile et la gestion des nouveaux modes WORK/WEEKEND.
 */
class CallDecisionEngineSnapshotTest {

    @Before
    fun reset() {
        CallDecisionEngine.updateRules(CallRules())
    }

    @Test
    fun `snapshot vide - tout passe en mode NORMAL`() {
        assertThat(CallDecisionEngine.shouldBlock("+33600000000")).isFalse()
        assertThat(CallDecisionEngine.shouldBlock("+33699999999")).isFalse()
    }

    @Test
    fun `updateRules remplace le snapshot - la blacklist est immédiatement active`() {
        assertThat(CallDecisionEngine.shouldBlock("+33698765432")).isFalse() // avant sync

        CallDecisionEngine.updateRules(
            CallRules(blacklist = setOf("+33698765432"), currentMode = FilterMode.NORMAL),
        )

        assertThat(CallDecisionEngine.shouldBlock("+33698765432")).isTrue() // après sync
    }

    @Test
    fun `updateRules remplace entièrement - ancien numéro n'est plus bloqué`() {
        CallDecisionEngine.updateRules(
            CallRules(blacklist = setOf("+33600000001"), currentMode = FilterMode.NORMAL),
        )
        assertThat(CallDecisionEngine.shouldBlock("+33600000001")).isTrue()

        // Nouveau snapshot sans l'ancien numéro
        CallDecisionEngine.updateRules(
            CallRules(blacklist = setOf("+33600000002"), currentMode = FilterMode.NORMAL),
        )
        assertThat(CallDecisionEngine.shouldBlock("+33600000001")).isFalse()
        assertThat(CallDecisionEngine.shouldBlock("+33600000002")).isTrue()
    }

    @Test
    fun `mode WORK - blacklist bloquée quel que soit le jour`() {
        CallDecisionEngine.updateRules(
            CallRules(
                blacklist = setOf("+33677777777"),
                currentMode = FilterMode.WORK,
                blockHourStart = 0,
                blockHourEnd = 23,
            ),
        )
        // Blacklist toujours prioritaire (priorité 3 dans l'engine)
        assertThat(CallDecisionEngine.shouldBlock("+33677777777")).isTrue()
    }

    @Test
    fun `sync multiple numéros - tous sont bloqués après updateRules`() {
        val numbers = listOf(
            "+33611111111", "+33622222222", "+33633333333",
            "+33644444444", "+33655555555",
        )
        CallDecisionEngine.updateRules(
            CallRules(blacklist = numbers.toSet(), currentMode = FilterMode.NORMAL),
        )
        numbers.forEach { n ->
            assertThat(CallDecisionEngine.shouldBlock(n))
                .`as`("$n doit être bloqué")
                .isTrue()
        }
    }

    @Test
    fun `sync blacklist vide (clear) - plus aucun numéro bloqué`() {
        // Seed : 3 numéros bloqués
        CallDecisionEngine.updateRules(
            CallRules(
                blacklist = setOf("+33611111111", "+33622222222", "+33633333333"),
                currentMode = FilterMode.NORMAL,
            ),
        )
        assertThat(CallDecisionEngine.shouldBlock("+33611111111")).isTrue()

        // Simulate clear() → sync with empty blacklist
        CallDecisionEngine.updateRules(CallRules(blacklist = emptySet(), currentMode = FilterMode.NORMAL))

        assertThat(CallDecisionEngine.shouldBlock("+33611111111")).isFalse()
        assertThat(CallDecisionEngine.shouldBlock("+33622222222")).isFalse()
        assertThat(CallDecisionEngine.shouldBlock("+33633333333")).isFalse()
    }

    @Test
    fun `thread safety - mises à jour concurrentes ne corrompent pas le snapshot`() {
        val pool = Executors.newFixedThreadPool(8)
        val latch = CountDownLatch(1)
        val readErrors = mutableListOf<Throwable>()
        val tasks = (0 until 200).map { i ->
            pool.submit {
                latch.await()
                try {
                    if (i % 2 == 0) {
                        CallDecisionEngine.updateRules(
                            CallRules(
                                blacklist = setOf("+3360000000$i"),
                                currentMode = FilterMode.NORMAL,
                            ),
                        )
                    } else {
                        // Lecture concurrente — ne doit jamais lancer d'exception
                        CallDecisionEngine.shouldBlock("+3360000000$i")
                    }
                } catch (e: Throwable) {
                    synchronized(readErrors) { readErrors.add(e) }
                }
            }
        }
        latch.countDown()
        tasks.forEach { it.get() }
        pool.shutdown()

        assertThat(readErrors).isEmpty()
    }
}

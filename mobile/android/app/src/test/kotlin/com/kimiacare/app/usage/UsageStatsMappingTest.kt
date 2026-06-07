package com.kimiacare.app.usage

import org.assertj.core.api.Assertions.assertThat
import org.junit.Test

/**
 * Tests unitaires du mapping de catégories dans [UsageStatsPlugin].
 * Vérifie la correspondance Android API category → clé technique
 * et le repli par nom de paquet connu.
 */
class UsageStatsMappingTest {

    // ─── mapCategory — catégories API Android ────────────────────────────────

    @Test
    fun `mapCategory 0 (GAME) renvoie games`() {
        assertThat(UsageStatsPlugin.mapCategory(0)).isEqualTo("games")
    }

    @Test
    fun `mapCategory 1 (AUDIO) renvoie music`() {
        assertThat(UsageStatsPlugin.mapCategory(1)).isEqualTo("music")
    }

    @Test
    fun `mapCategory 2 (VIDEO) renvoie video`() {
        assertThat(UsageStatsPlugin.mapCategory(2)).isEqualTo("video")
    }

    @Test
    fun `mapCategory 3 (IMAGE) renvoie null — repli par package`() {
        assertThat(UsageStatsPlugin.mapCategory(3)).isNull()
    }

    @Test
    fun `mapCategory 4 (SOCIAL) renvoie social`() {
        assertThat(UsageStatsPlugin.mapCategory(4)).isEqualTo("social")
    }

    @Test
    fun `mapCategory 5 (NEWS) renvoie null — repli par package`() {
        assertThat(UsageStatsPlugin.mapCategory(5)).isNull()
    }

    @Test
    fun `mapCategory 6 (MAPS) renvoie null — repli par package`() {
        assertThat(UsageStatsPlugin.mapCategory(6)).isNull()
    }

    @Test
    fun `mapCategory 7 (PRODUCTIVITY) renvoie productivity`() {
        assertThat(UsageStatsPlugin.mapCategory(7)).isEqualTo("productivity")
    }

    @Test
    fun `mapCategory -1 (UNDEFINED) renvoie null`() {
        assertThat(UsageStatsPlugin.mapCategory(-1)).isNull()
    }

    @Test
    fun `mapCategory valeur inconnue renvoie null`() {
        assertThat(UsageStatsPlugin.mapCategory(99)).isNull()
    }

    // ─── mapCategoryByPackage — repli par nom de paquet ──────────────────────

    @Test
    fun `Instagram est social`() {
        assertThat(UsageStatsPlugin.mapCategoryByPackage("com.instagram.android"))
            .isEqualTo("social")
    }

    @Test
    fun `TikTok (zhiliaoapp) est social`() {
        assertThat(UsageStatsPlugin.mapCategoryByPackage("com.zhiliaoapp.musically"))
            .isEqualTo("social")
    }

    @Test
    fun `YouTube est video`() {
        assertThat(UsageStatsPlugin.mapCategoryByPackage("com.google.android.youtube"))
            .isEqualTo("video")
    }

    @Test
    fun `Netflix est video`() {
        assertThat(UsageStatsPlugin.mapCategoryByPackage("com.netflix.mediaclient"))
            .isEqualTo("video")
    }

    @Test
    fun `WhatsApp est communication`() {
        assertThat(UsageStatsPlugin.mapCategoryByPackage("com.whatsapp"))
            .isEqualTo("communication")
    }

    @Test
    fun `Telegram est communication`() {
        assertThat(UsageStatsPlugin.mapCategoryByPackage("org.telegram.messenger"))
            .isEqualTo("communication")
    }

    @Test
    fun `Spotify est music`() {
        assertThat(UsageStatsPlugin.mapCategoryByPackage("com.spotify.music"))
            .isEqualTo("music")
    }

    @Test
    fun `Chrome est browser`() {
        assertThat(UsageStatsPlugin.mapCategoryByPackage("com.android.chrome"))
            .isEqualTo("browser")
    }

    @Test
    fun `Firefox est browser`() {
        assertThat(UsageStatsPlugin.mapCategoryByPackage("org.mozilla.firefox"))
            .isEqualTo("browser")
    }

    @Test
    fun `Duolingo est education`() {
        assertThat(UsageStatsPlugin.mapCategoryByPackage("com.duolingo"))
            .isEqualTo("education")
    }

    @Test
    fun `Clash of Clans est games`() {
        assertThat(UsageStatsPlugin.mapCategoryByPackage("com.supercell.clashofclans"))
            .isEqualTo("games")
    }

    @Test
    fun `Minecraft est games`() {
        assertThat(UsageStatsPlugin.mapCategoryByPackage("com.mojang.minecraftpe"))
            .isEqualTo("games")
    }

    @Test
    fun `Gmail est productivity`() {
        assertThat(UsageStatsPlugin.mapCategoryByPackage("com.google.android.gm"))
            .isEqualTo("productivity")
    }

    @Test
    fun `paquet inconnu renvoie null`() {
        assertThat(UsageStatsPlugin.mapCategoryByPackage("com.unknown.randomapp"))
            .isNull()
    }

    @Test
    fun `paquet vide renvoie null`() {
        assertThat(UsageStatsPlugin.mapCategoryByPackage(""))
            .isNull()
    }

    // ─── Chaîne complète : mapCategory ?: mapCategoryByPackage ?: "other" ────

    @Test
    fun `chaine complete — Instagram sans categorie API donne social`() {
        // Simule API < 26 : mapCategory(-1) = null, repli par package
        val cat = UsageStatsPlugin.mapCategory(-1)
            ?: UsageStatsPlugin.mapCategoryByPackage("com.instagram.android")
            ?: "other"
        assertThat(cat).isEqualTo("social")
    }

    @Test
    fun `chaine complete — app inconnue sans categorie API donne other`() {
        val cat = UsageStatsPlugin.mapCategory(-1)
            ?: UsageStatsPlugin.mapCategoryByPackage("com.unknown.randomapp")
            ?: "other"
        assertThat(cat).isEqualTo("other")
    }

    @Test
    fun `chaine complete — CATEGORY_GAME (0) ignore le package name`() {
        // Catégorie API prend la priorité sur le nom du paquet
        val cat = UsageStatsPlugin.mapCategory(0)
            ?: UsageStatsPlugin.mapCategoryByPackage("com.instagram.android")
            ?: "other"
        assertThat(cat).isEqualTo("games")
    }
}

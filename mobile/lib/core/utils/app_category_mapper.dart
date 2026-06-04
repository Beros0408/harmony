import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Utilitaire partagé : mapping des catégories d'applications.
///
/// Utilisé par :
/// - [screen_time_summary_screen.dart] pour l'affichage (libellés + icônes)
/// - Les tests unitaires pour valider la logique de mapping côté Dart
///
/// Le mapping autoritatif (package → catégorie) s'effectue côté Kotlin
/// ([UsageStatsPlugin.kt]) ; cette classe reflète le même mapping pour
/// les tests Dart et pour les cas où la donnée ancienne contient une
/// catégorie nulle ou générique.
class AppCategoryMapper {
  AppCategoryMapper._();

  // ─── Catégories cibles ──────────────────────────────────────────────────────

  /// Toutes les clés techniques valides.
  static const Set<String> validCategories = {
    'social',
    'games',
    'video',
    'communication',
    'education',
    'productivity',
    'music',
    'browser',
    'other',
  };

  // ─── Libellés français ──────────────────────────────────────────────────────

  static const Map<String, String> _labels = {
    'social':        'Réseaux sociaux',
    'games':         'Jeux',
    'video':         'Vidéo & streaming',
    'communication': 'Messagerie & appels',
    'education':     'Éducation',
    'productivity':  'Productivité',
    'music':         'Musique & audio',
    'browser':       'Navigateur web',
    'other':         'Autre',
  };

  /// Retourne le libellé français d'une catégorie.
  /// Les clés inconnues ou nulles sont renvoyées sous "Autre".
  static String categoryLabel(String? category) {
    if (category == null || category.isEmpty) return _labels['other']!;
    return _labels[category] ?? _labels['other']!;
  }

  // ─── Icônes ─────────────────────────────────────────────────────────────────

  static IconData categoryIcon(String? category) => switch (category) {
        'social'        => Icons.people_outline,
        'games'         => Icons.videogame_asset_outlined,
        'video'         => Icons.play_circle_outline,
        'communication' => Icons.chat_bubble_outline,
        'education'     => Icons.school_outlined,
        'productivity'  => Icons.work_outline,
        'music'         => Icons.music_note_outlined,
        'browser'       => Icons.language_outlined,
        _               => Icons.apps_outlined,
      };

  // ─── Couleurs d'accentuation (tokens du design system) ─────────────────────

  /// Retourne une couleur d'accentuation issue du design system pour une catégorie.
  /// N'utilise que les constantes [AppColors] existantes — pas de valeur hexadécimale
  /// arbitraire.
  static Color categoryAccent(String? category) => switch (category) {
        'social'        => AppColors.accentRose,
        'games'         => AppColors.accentPurple,
        'video'         => AppColors.accentRed,
        'communication' => AppColors.accentGreen,
        'education'     => AppColors.accentBlue,
        'productivity'  => AppColors.accentCyan,
        'music'         => AppColors.accentAmber,
        'browser'       => AppColors.accentBlue,
        _               => AppColors.accentBlue,
      };

  // ─── Mapping de repli par package name (miroir du Kotlin pour les tests) ────

  /// Miroir du mapping Kotlin [UsageStatsPlugin.PACKAGE_CATEGORY_MAP].
  /// Utilisé uniquement pour les tests unitaires Dart et pour normaliser
  /// d'éventuelles données remontées sans catégorie.
  static const Map<String, String> packageCategoryMap = {
    // Réseaux sociaux
    'com.instagram.android':               'social',
    'com.facebook.katana':                 'social',
    'com.twitter.android':                 'social',
    'com.snapchat.android':               'social',
    'com.zhiliaoapp.musically':            'social',
    'com.ss.android.ugc.trill':            'social',
    'com.linkedin.android':               'social',
    'com.pinterest':                      'social',
    'com.reddit.frontpage':               'social',
    'com.discord':                        'social',
    'com.tumblr':                         'social',
    // Vidéo & streaming
    'com.google.android.youtube':         'video',
    'com.netflix.mediaclient':            'video',
    'com.amazon.avod.thirdpartyclient':   'video',
    'com.disney.disneyplus':              'video',
    'com.hbo.hbonow':                     'video',
    'com.twitch.android.app':             'video',
    'com.dailymotion.dailymotion':        'video',
    'tv.pluto.android':                   'video',
    // Messagerie & appels
    'com.whatsapp':                       'communication',
    'com.facebook.orca':                  'communication',
    'org.telegram.messenger':             'communication',
    'com.viber.voip':                     'communication',
    'com.skype.raider':                   'communication',
    'us.zoom.videomeetings':              'communication',
    'com.google.android.apps.messaging':  'communication',
    'com.samsung.android.messaging':      'communication',
    'com.android.mms':                    'communication',
    'com.microsoft.teams':                'communication',
    // Musique & audio
    'com.spotify.music':                  'music',
    'com.google.android.music':           'music',
    'com.google.android.apps.youtube.music': 'music',
    'com.deezer.android':                 'music',
    'com.soundcloud.android':             'music',
    'com.amazon.mp3':                     'music',
    'com.shazam.android':                 'music',
    'com.pandora.android':                'music',
    // Navigateur web
    'com.android.chrome':                 'browser',
    'org.mozilla.firefox':               'browser',
    'com.opera.browser':                  'browser',
    'com.brave.browser':                  'browser',
    'com.microsoft.emmx':                 'browser',
    'com.sec.android.app.sbrowser':       'browser',
    'com.ucmobile.intl':                  'browser',
    // Éducation
    'com.duolingo':                       'education',
    'org.khanacademy.android':            'education',
    'com.google.android.apps.classroom':  'education',
    'com.coursera.android':               'education',
    'com.quizlet.quizletandroid':         'education',
    // Jeux
    'com.supercell.clashofclans':         'games',
    'com.supercell.clashroyale':          'games',
    'com.mojang.minecraftpe':             'games',
    'com.roblox.client':                  'games',
    'com.king.candycrushsaga':            'games',
    'com.activision.callofduty.shooter':  'games',
    'com.epicgames.fortnite':             'games',
    'com.pubg.krmobile':                  'games',
    'com.ea.game.pvzfree_row':            'games',
    // Productivité
    'com.microsoft.office.outlook':       'productivity',
    'com.google.android.gm':              'productivity',
    'com.microsoft.office.word':          'productivity',
    'com.google.android.apps.docs':       'productivity',
    'com.google.android.calendar':        'productivity',
    'com.notion.id':                      'productivity',
    'com.slack':                          'productivity',
    'com.evernote':                       'productivity',
    'com.todoist.android.Todoist':        'productivity',
  };

  /// Résout la catégorie finale pour une entrée d'usage.
  ///
  /// Priorité :
  /// 1. [existingCategory] si valide (non null, non vide, non "other")
  /// 2. Repli par [packageName] dans [packageCategoryMap]
  /// 3. "other" par défaut
  static String resolveCategory(String packageName, String? existingCategory) {
    if (existingCategory != null &&
        existingCategory.isNotEmpty &&
        existingCategory != 'other') {
      return existingCategory;
    }
    return packageCategoryMap[packageName] ?? 'other';
  }

  // ─── Mapping catégorie Android API → clé technique (miroir du Kotlin) ───────

  /// Miroir de [UsageStatsPlugin.mapCategory] pour les tests Dart.
  /// Retourne null quand l'entier ne correspond à aucune catégorie cible
  /// (photo=3, news=5, maps=6) — le repli par package prend alors le relais.
  static String? mapAndroidCategory(int androidCategory) => switch (androidCategory) {
        0 => 'games',        // CATEGORY_GAME
        1 => 'music',        // CATEGORY_AUDIO
        2 => 'video',        // CATEGORY_VIDEO
        4 => 'social',       // CATEGORY_SOCIAL
        7 => 'productivity', // CATEGORY_PRODUCTIVITY
        _ => null,           // 3 (IMAGE), 5 (NEWS), 6 (MAPS) et inconnus
      };
}

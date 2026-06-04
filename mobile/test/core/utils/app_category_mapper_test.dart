import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/core/utils/app_category_mapper.dart';

void main() {
  // ─── categoryLabel ────────────────────────────────────────────────────────

  group('categoryLabel — libellés français', () {
    test('social → Réseaux sociaux', () {
      expect(AppCategoryMapper.categoryLabel('social'), equals('Réseaux sociaux'));
    });

    test('games → Jeux', () {
      expect(AppCategoryMapper.categoryLabel('games'), equals('Jeux'));
    });

    test('video → Vidéo & streaming', () {
      expect(AppCategoryMapper.categoryLabel('video'), equals('Vidéo & streaming'));
    });

    test('communication → Messagerie & appels', () {
      expect(
        AppCategoryMapper.categoryLabel('communication'),
        equals('Messagerie & appels'),
      );
    });

    test('education → Éducation', () {
      expect(AppCategoryMapper.categoryLabel('education'), equals('Éducation'));
    });

    test('productivity → Productivité', () {
      expect(AppCategoryMapper.categoryLabel('productivity'), equals('Productivité'));
    });

    test('music → Musique & audio', () {
      expect(AppCategoryMapper.categoryLabel('music'), equals('Musique & audio'));
    });

    test('browser → Navigateur web', () {
      expect(AppCategoryMapper.categoryLabel('browser'), equals('Navigateur web'));
    });

    test('other → Autre', () {
      expect(AppCategoryMapper.categoryLabel('other'), equals('Autre'));
    });

    test('null → Autre', () {
      expect(AppCategoryMapper.categoryLabel(null), equals('Autre'));
    });

    test('chaîne vide → Autre', () {
      expect(AppCategoryMapper.categoryLabel(''), equals('Autre'));
    });

    test('clé inconnue → Autre (robustesse données anciennes)', () {
      expect(AppCategoryMapper.categoryLabel('photo'), equals('Autre'));
    });

    test('clé inconnue "news" → Autre', () {
      expect(AppCategoryMapper.categoryLabel('news'), equals('Autre'));
    });

    test('clé inconnue "maps" → Autre', () {
      expect(AppCategoryMapper.categoryLabel('maps'), equals('Autre'));
    });
  });

  // ─── mapAndroidCategory — miroir du mapping Kotlin ────────────────────────

  group('mapAndroidCategory — catégories API Android', () {
    test('0 (GAME) → games', () {
      expect(AppCategoryMapper.mapAndroidCategory(0), equals('games'));
    });

    test('1 (AUDIO) → music', () {
      expect(AppCategoryMapper.mapAndroidCategory(1), equals('music'));
    });

    test('2 (VIDEO) → video', () {
      expect(AppCategoryMapper.mapAndroidCategory(2), equals('video'));
    });

    test('3 (IMAGE) → null (repli par package)', () {
      expect(AppCategoryMapper.mapAndroidCategory(3), isNull);
    });

    test('4 (SOCIAL) → social', () {
      expect(AppCategoryMapper.mapAndroidCategory(4), equals('social'));
    });

    test('5 (NEWS) → null (repli par package)', () {
      expect(AppCategoryMapper.mapAndroidCategory(5), isNull);
    });

    test('6 (MAPS) → null (repli par package)', () {
      expect(AppCategoryMapper.mapAndroidCategory(6), isNull);
    });

    test('7 (PRODUCTIVITY) → productivity', () {
      expect(AppCategoryMapper.mapAndroidCategory(7), equals('productivity'));
    });

    test('-1 (UNDEFINED) → null', () {
      expect(AppCategoryMapper.mapAndroidCategory(-1), isNull);
    });

    test('valeur inconnue → null', () {
      expect(AppCategoryMapper.mapAndroidCategory(99), isNull);
    });
  });

  // ─── resolveCategory — résolution finale ─────────────────────────────────

  group('resolveCategory — chaîne de résolution', () {
    test('package connu + catégorie null → catégorie par package', () {
      expect(
        AppCategoryMapper.resolveCategory('com.instagram.android', null),
        equals('social'),
      );
    });

    test('package connu + catégorie existante non-other → catégorie existante gardée', () {
      // Ex. : Kotlin a déjà résolu via ApplicationInfo.category
      expect(
        AppCategoryMapper.resolveCategory('com.instagram.android', 'video'),
        equals('video'),
      );
    });

    test(
        'package connu + catégorie "other" → catégorie par package prend le relais', () {
      expect(
        AppCategoryMapper.resolveCategory('com.spotify.music', 'other'),
        equals('music'),
      );
    });

    test('package inconnu + catégorie null → "other"', () {
      expect(
        AppCategoryMapper.resolveCategory('com.unknown.randomapp', null),
        equals('other'),
      );
    });

    test('package inconnu + catégorie "other" → "other"', () {
      expect(
        AppCategoryMapper.resolveCategory('com.unknown.randomapp', 'other'),
        equals('other'),
      );
    });

    test('YouTube → video', () {
      expect(
        AppCategoryMapper.resolveCategory('com.google.android.youtube', null),
        equals('video'),
      );
    });

    test('Chrome → browser', () {
      expect(
        AppCategoryMapper.resolveCategory('com.android.chrome', null),
        equals('browser'),
      );
    });

    test('WhatsApp → communication', () {
      expect(
        AppCategoryMapper.resolveCategory('com.whatsapp', null),
        equals('communication'),
      );
    });

    test('Duolingo → education', () {
      expect(
        AppCategoryMapper.resolveCategory('com.duolingo', null),
        equals('education'),
      );
    });

    test('Clash of Clans → games', () {
      expect(
        AppCategoryMapper.resolveCategory('com.supercell.clashofclans', null),
        equals('games'),
      );
    });

    test('Gmail → productivity', () {
      expect(
        AppCategoryMapper.resolveCategory('com.google.android.gm', null),
        equals('productivity'),
      );
    });
  });

  // ─── packageCategoryMap — couverture minimale ─────────────────────────────

  group('packageCategoryMap — entrées clés présentes', () {
    const expected = {
      'com.instagram.android':            'social',
      'com.zhiliaoapp.musically':         'social',
      'com.google.android.youtube':       'video',
      'com.netflix.mediaclient':          'video',
      'com.whatsapp':                     'communication',
      'org.telegram.messenger':           'communication',
      'com.spotify.music':                'music',
      'com.android.chrome':               'browser',
      'org.mozilla.firefox':              'browser',
      'com.duolingo':                     'education',
      'com.roblox.client':                'games',
      'com.mojang.minecraftpe':           'games',
      'com.google.android.gm':            'productivity',
      'com.notion.id':                    'productivity',
    };

    for (final entry in expected.entries) {
      test('${entry.key} → ${entry.value}', () {
        expect(
          AppCategoryMapper.packageCategoryMap[entry.key],
          equals(entry.value),
        );
      });
    }
  });
}

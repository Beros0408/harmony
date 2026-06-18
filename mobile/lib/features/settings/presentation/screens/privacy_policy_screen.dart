import 'package:flutter/material.dart';
import 'package:harmony/l10n/app_localizations.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/harmony_app_bar.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: HarmonyAppBar(title: l10n.settingsPrivacyPolicy),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version 1.0 — Juin 2026', style: tt.bodySmall),
            const SizedBox(height: AppSpacing.xl),
            _Section(
              title: '1. Responsable du traitement',
              body:
                  "L'application KimiaCare est éditée par Beros Yakatshi.\n"
                  'Contact : berosform@gmail.com',
              tt: tt,
            ),
            _Section(
              title: '2. Données collectées et finalités',
              body:
                  '• Localisation GPS de l\'enfant (temps réel et historique) — '
                  'sécurité, zones autorisées, déclenchement des alertes SOS.\n\n'
                  '• Contacts SOS (nom et numéro de téléphone) — '
                  'contact d\'urgence en cas d\'alerte.\n\n'
                  '• Règles de filtrage des appels et journal des appels bloqués — '
                  'supervision parentale et protection contre les appels indésirables.\n\n'
                  '• Profil enfant (prénom, avatar) — personnalisation de l\'interface.\n\n'
                  '• Données d\'activité physique (pas, minutes actives) — '
                  'suivi de l\'activité de l\'enfant.\n\n'
                  '• Compte parent (adresse e-mail, token JWT) — '
                  'authentification sécurisée.\n\n'
                  '• Données d\'abonnement — gestion de l\'accès aux fonctionnalités '
                  'Premium via RevenueCat.',
              tt: tt,
            ),
            _Section(
              title: '3. Base légale',
              body:
                  'Le traitement repose sur le consentement parental éclairé, '
                  'recueilli lors de la première utilisation de l\'application (onboarding).',
              tt: tt,
            ),
            _Section(
              title: '4. Conservation des données',
              body:
                  'Les données sont conservées tant que le compte est actif. '
                  'Elles peuvent être supprimées à tout moment par le parent '
                  'directement depuis la fiche de l\'enfant (bouton « Supprimer '
                  'toutes les données »). Il n\'existe pas de suppression automatique programmée.',
              tt: tt,
            ),
            _Section(
              title: '5. Hébergement',
              body:
                  'Les données sont hébergées sur Supabase (infrastructure Amazon '
                  'Web Services), région Europe — Irlande (eu-west-1). '
                  'Vos données restent dans l\'Union européenne.',
              tt: tt,
            ),
            _Section(
              title: '6. Partage avec des tiers',
              body:
                  '• RevenueCat — gestion des abonnements in-app.\n\n'
                  '• Firebase Cloud Messaging (Google) — envoi de notifications push.\n\n'
                  '• Google AdMob — des publicités peuvent être affichées en version '
                  'gratuite de l\'application.\n\n'
                  'Aucune donnée personnelle n\'est vendue ni partagée à des fins '
                  'de ciblage publicitaire tiers.',
              tt: tt,
            ),
            _Section(
              title: '7. Sécurité',
              body:
                  '• Les données stockées localement sur l\'appareil sont chiffrées '
                  'via SQLCipher (AES-256).\n\n'
                  '• Toutes les communications entre l\'application et le serveur '
                  'sont sécurisées par HTTPS/TLS.\n\n'
                  '• Les tokens d\'authentification JWT ont une durée de vie limitée.',
              tt: tt,
            ),
            _Section(
              title: '8. Données relatives aux mineurs',
              body:
                  'KimiaCare est destinée exclusivement aux parents ou tuteurs légaux. '
                  'Les données de l\'enfant sont collectées sous la responsabilité et '
                  'avec le consentement explicite du parent. '
                  'L\'enfant n\'a pas de compte propre sur l\'application.',
              tt: tt,
            ),
            _Section(
              title: '9. Vos droits (RGPD)',
              body:
                  'Conformément au Règlement général sur la protection des données '
                  '(RGPD), vous disposez des droits suivants :\n\n'
                  '• Droit d\'accès : exportez les données de votre enfant depuis '
                  'sa fiche (bouton « Exporter les données »).\n\n'
                  '• Droit de rectification : modifiez le profil depuis les paramètres '
                  'de l\'application.\n\n'
                  '• Droit à l\'effacement : supprimez toutes les données depuis la '
                  'fiche de l\'enfant (bouton « Supprimer toutes les données »).\n\n'
                  '• Droit à la portabilité : l\'export génère un fichier JSON '
                  'lisible et structuré.\n\n'
                  '• Droit d\'opposition et de limitation : contactez-nous par e-mail.\n\n'
                  'Contact pour exercer vos droits : berosform@gmail.com',
              tt: tt,
            ),
            _Section(
              title: '10. Modifications',
              body:
                  'Cette politique de confidentialité peut être mise à jour. '
                  'Toute modification substantielle vous sera notifiée via l\'application.',
              tt: tt,
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Version 1.0 — Juin 2026', style: tt.bodySmall),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.body,
    required this.tt,
  });

  final String title;
  final String body;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: tt.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          Text(body, style: tt.bodyMedium),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:harmony/l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/language/language_cubit.dart';
import '../../../../shared/widgets/harmony_app_bar.dart';
import '../../../../shared/widgets/harmony_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = context.watch<LanguageCubit>().state;

    final languages = [
      ('fr', '🇫🇷', l10n.settingsLanguageFrench),
      ('en', '🇬🇧', l10n.settingsLanguageEnglish),
      ('es', '🇪🇸', l10n.settingsLanguageSpanish),
      ('pt', '🇵🇹', l10n.settingsLanguagePortuguese),
      ('it', '🇮🇹', l10n.settingsLanguageItalian),
    ];

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: HarmonyAppBar(title: l10n.settingsTitle),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(l10n.settingsLanguage, style: AppTypography.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.md),
          HarmonyCard(
            padding: AppSpacing.md,
            child: Column(
              children: languages.map((entry) {
                final (code, flag, name) = entry;
                final isSelected = currentLocale.languageCode == code;
                return InkWell(
                  onTap: () => context.read<LanguageCubit>().change(Locale(code)),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.md,
                    ),
                    child: Row(
                      children: [
                        Text(flag, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(name, style: AppTypography.textTheme.bodyMedium),
                        ),
                        if (isSelected)
                          const Icon(Icons.check, color: AppColors.accentBlue, size: 20),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

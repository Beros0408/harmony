import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:harmony/l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/language/language_cubit.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../shared/widgets/harmony_app_bar.dart';
import '../../../../shared/widgets/harmony_card.dart';
import '../../../../shared/widgets/harmony_theme_toggle.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = context.watch<LanguageCubit>().state;
    final currentTheme = context.watch<ThemeCubit>().state;

    final languages = [
      ('fr', '🇫🇷', l10n.settingsLanguageFrench),
      ('en', '🇬🇧', l10n.settingsLanguageEnglish),
      ('es', '🇪🇸', l10n.settingsLanguageSpanish),
      ('pt', '🇵🇹', l10n.settingsLanguagePortuguese),
      ('it', '🇮🇹', l10n.settingsLanguageItalian),
    ];

    final themeOptions = [
      (ThemeMode.system, Icons.brightness_auto_outlined, l10n.settingsThemeSystem),
      (ThemeMode.light, Icons.light_mode_outlined, l10n.settingsThemeLight),
      (ThemeMode.dark, Icons.dark_mode_outlined, l10n.settingsThemeDark),
    ];

    return Scaffold(
      appBar: HarmonyAppBar(title: l10n.settingsTitle),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.settingsTheme, style: Theme.of(context).textTheme.titleSmall),
              HarmonyThemeToggle(
                mode: currentTheme,
                onChanged: (m) => context.read<ThemeCubit>().change(m),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          HarmonyCard(
            padding: AppSpacing.md,
            child: Column(
              children: themeOptions.map((entry) {
                final (mode, icon, label) = entry;
                final isSelected = currentTheme == mode;
                return InkWell(
                  onTap: () => context.read<ThemeCubit>().change(mode),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.md,
                    ),
                    child: Row(
                      children: [
                        Icon(icon, size: 20, color: AppColors.accentBlue),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
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

          const SizedBox(height: AppSpacing.xl),

          Text(l10n.settingsLanguage, style: Theme.of(context).textTheme.titleSmall),
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
                          child: Text(name, style: Theme.of(context).textTheme.bodyMedium),
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

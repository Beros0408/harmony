import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/harmony_app_bar.dart';
import '../../../../shared/widgets/harmony_button.dart';
import '../../logic/google_calendar_cubit.dart';

class GoogleCalendarSettingsScreen extends StatefulWidget {
  const GoogleCalendarSettingsScreen({super.key});

  @override
  State<GoogleCalendarSettingsScreen> createState() =>
      _GoogleCalendarSettingsScreenState();
}

class _GoogleCalendarSettingsScreenState
    extends State<GoogleCalendarSettingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GoogleCalendarCubit>().checkConnection();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: HarmonyAppBar(title: l10n.agendaGoogleTitle),
      body: BlocBuilder<GoogleCalendarCubit, GoogleCalendarState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              // Carte statut connexion
              _StatusCard(state: state),
              const SizedBox(height: AppSpacing.lg),

              // Actions
              if (!state.isConnected) ...[
                HarmonyButton(
                  label: l10n.agendaGoogleConnectButton,
                  icon: Icons.login_rounded,
                  onPressed: state.status == GoogleCalendarStatus.connecting
                      ? null
                      : () => context.read<GoogleCalendarCubit>().signIn(),
                ),
              ] else ...[
                // Synchroniser
                HarmonyButton(
                  label: state.status == GoogleCalendarStatus.syncing
                      ? l10n.agendaGoogleSyncing
                      : l10n.agendaGoogleSync,
                  icon: Icons.sync_rounded,
                  onPressed: state.status == GoogleCalendarStatus.syncing
                      ? null
                      : () =>
                          context.read<GoogleCalendarCubit>().syncFromGoogle(),
                ),
                const SizedBox(height: AppSpacing.md),
                // Déconnecter
                OutlinedButton.icon(
                  onPressed: () =>
                      context.read<GoogleCalendarCubit>().signOut(),
                  icon: const Icon(Icons.logout_rounded,
                      color: AppColors.accentRed,),
                  label: Text(
                    l10n.agendaGoogleDisconnect,
                    style: AppTypography.textTheme.labelLarge
                        ?.copyWith(color: AppColors.accentRed),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.accentRed),
                    shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.lgRadius,),
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ],

              // Erreur
              if (state.status == GoogleCalendarStatus.error &&
                  state.error != null) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.accentRed.withValues(alpha: 0.1),
                    borderRadius: AppRadius.mdRadius,
                    border: Border.all(
                        color: AppColors.accentRed.withValues(alpha: 0.3),),
                  ),
                  child: Text(
                    state.error!,
                    style: AppTypography.textTheme.bodySmall
                        ?.copyWith(color: AppColors.accentRed),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.state});
  final GoogleCalendarState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    final isConnected = state.isConnected;
    final statusColor =
        isConnected ? AppColors.accentGreen : AppColors.textMuted;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: AppRadius.lgRadius,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: AppRadius.mdRadius,
            ),
            child: Icon(
              isConnected
                  ? Icons.cloud_done_rounded
                  : Icons.cloud_off_rounded,
              color: statusColor,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isConnected
                      ? l10n.agendaGoogleConnectedAs
                      : l10n.agendaGoogleNotConnected,
                  style: AppTypography.textTheme.labelMedium,
                ),
                if (state.account != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    state.account!.accountEmail,
                    style: AppTypography.textTheme.bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                  if (state.account!.lastSyncAt != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${l10n.agendaGoogleLastSync} '
                      '${DateFormat.yMd(locale).add_Hm().format(state.account!.lastSyncAt!)}',
                      style: AppTypography.textTheme.bodySmall
                          ?.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ] else ...[
                  const SizedBox(height: 2),
                  Text(
                    '—',
                    style: AppTypography.textTheme.bodySmall
                        ?.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ],
            ),
          ),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

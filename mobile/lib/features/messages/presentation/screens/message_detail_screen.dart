import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:harmony/l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/harmony_app_bar.dart';
import '../../../../shared/widgets/harmony_badge.dart';
import '../../../../shared/widgets/harmony_card.dart';
import '../../data/models/captured_message.dart';

class MessageDetailScreen extends StatelessWidget {
  const MessageDetailScreen({super.key, required this.message});

  final CapturedMessage message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: HarmonyAppBar(title: message.sender),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Carte métadonnées : source + date + statut
          HarmonyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _SourceIcon(source: message.source, isBlocked: message.isBlocked),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.sender,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatFullDate(message.timestamp),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    HarmonyBadge(
                      label: _sourceLabel(l10n, message.source),
                      variant: HarmonyBadgeVariant.info,
                    ),
                  ],
                ),
                if (message.isBlocked) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const HarmonyBadge(
                        label: 'Bloqué',
                        variant: HarmonyBadgeVariant.danger,
                      ),
                      if (message.blockReason != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Flexible(
                          child: Text(
                            message.blockReason!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Carte contenu complet du message
          HarmonyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Message',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        letterSpacing: 0.8,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  message.content,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Actions
          OutlinedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.messageDetailMarkRead),
                duration: const Duration(seconds: 2),
              ),
            ),
            icon: const Icon(Icons.mark_email_read_outlined),
            label: Text(l10n.messageDetailMarkRead),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          OutlinedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.messageDetailBlockContact),
                duration: const Duration(seconds: 2),
                backgroundColor: AppColors.accentRed,
              ),
            ),
            icon: const Icon(Icons.block_outlined),
            label: Text(l10n.messageDetailBlockContact),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accentRed,
              side: const BorderSide(color: AppColors.accentRed),
              minimumSize: const Size.fromHeight(48),
            ),
          ),

          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  String _formatFullDate(DateTime dt) =>
      DateFormat('EEEE d MMMM yyyy · HH:mm', 'fr_FR').format(dt);

  String _sourceLabel(AppLocalizations l10n, MessageSource source) =>
      switch (source) {
        MessageSource.sms => l10n.messageDetailTypeSms,
        MessageSource.whatsApp => l10n.messageDetailTypeWhatsapp,
        MessageSource.signal => l10n.messageDetailTypeSignal,
        MessageSource.telegram => l10n.messageDetailTypeTelegram,
        MessageSource.unknown => source.displayName,
      };
}

class _SourceIcon extends StatelessWidget {
  const _SourceIcon({required this.source, required this.isBlocked});

  final MessageSource source;
  final bool isBlocked;

  @override
  Widget build(BuildContext context) {
    final color = isBlocked ? AppColors.accentRed : _colorFor(source);

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(_iconFor(source), color: color, size: 20),
    );
  }

  Color _colorFor(MessageSource s) => switch (s) {
        MessageSource.sms => AppColors.accentBlue,
        MessageSource.whatsApp => const Color(0xFF25D366),
        MessageSource.signal => const Color(0xFF3A76F0),
        MessageSource.telegram => const Color(0xFF0088CC),
        MessageSource.unknown => AppColors.accentAmber,
      };

  IconData _iconFor(MessageSource s) => switch (s) {
        MessageSource.sms => Icons.sms_outlined,
        MessageSource.whatsApp => Icons.chat_outlined,
        MessageSource.signal => Icons.lock_outlined,
        MessageSource.telegram => Icons.send_outlined,
        MessageSource.unknown => Icons.message_outlined,
      };
}

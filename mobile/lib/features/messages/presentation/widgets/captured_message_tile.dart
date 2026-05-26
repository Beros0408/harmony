import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/harmony_badge.dart';
import '../../../../shared/widgets/harmony_card.dart';
import '../../data/models/captured_message.dart';

/// Affiche un message capturé (SMS ou notification d'app).
class CapturedMessageTile extends StatelessWidget {
  const CapturedMessageTile({super.key, required this.message});

  final CapturedMessage message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return HarmonyCard(
      padding: AppSpacing.sm,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SourceAvatar(source: message.source, isBlocked: message.isBlocked),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          message.sender,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        _formatTime(message.timestamp),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message.content,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: message.isBlocked
                              ? cs.onSurfaceVariant.withValues(alpha: 0.6)
                              : cs.onSurfaceVariant,
                          decoration: message.isBlocked
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (message.isBlocked) ...[
                    const SizedBox(height: AppSpacing.xs),
                    HarmonyBadge(
                      label: 'Bloqué',
                      variant: HarmonyBadgeVariant.danger,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
      return DateFormat('HH:mm').format(dt);
    }
    return DateFormat('dd/MM').format(dt);
  }
}

class _SourceAvatar extends StatelessWidget {
  const _SourceAvatar({required this.source, required this.isBlocked});

  final MessageSource source;
  final bool isBlocked;

  @override
  Widget build(BuildContext context) {
    final color = isBlocked ? AppColors.accentRed : _colorFor(source);

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _iconFor(source),
        color: color,
        size: 18,
      ),
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

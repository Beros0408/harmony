import 'package:flutter/material.dart';
import 'package:harmony/core/constants/app_colors.dart';
import 'package:harmony/features/voicemail/data/mock/voicemail_mocks.dart';
import 'package:harmony/l10n/app_localizations.dart';
import 'package:harmony/shared/widgets/harmony_audio_waveform.dart';

class VoicemailItemCard extends StatefulWidget {
  const VoicemailItemCard({
    super.key,
    required this.voicemail,
    required this.onMarkRead,
    required this.onDelete,
    required this.onCallBack,
  });

  final HarmonyVoicemail voicemail;
  final VoidCallback onMarkRead;
  final VoidCallback onDelete;
  final VoidCallback onCallBack;

  @override
  State<VoicemailItemCard> createState() => _VoicemailItemCardState();
}

class _VoicemailItemCardState extends State<VoicemailItemCard> {
  bool _expanded = false;
  bool _isPlaying = false;
  double _progress = 0.0;

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Color _urgencyColor() => switch (widget.voicemail.urgency) {
        VoicemailUrgency.urgent => AppColors.accentRed,
        VoicemailUrgency.normal => AppColors.accentBlue,
        VoicemailUrgency.low => AppColors.textMuted,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final isUnread = !widget.voicemail.isRead;

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnread
                ? AppColors.accentBlue.withValues(alpha: 0.4)
                : cs.outline,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  _Avatar(
                    name: widget.voicemail.callerName,
                    urgencyColor: _urgencyColor(),
                    isUnread: isUnread,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.voicemail.callerName,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: isUnread
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (widget.voicemail.urgency ==
                                VoicemailUrgency.urgent)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.accentRed.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  l10n.voicemailUrgent,
                                  style: const TextStyle(
                                    color: AppColors.accentRed,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.voicemail.shortPreview,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDuration(widget.voicemail.duration),
                          style: const TextStyle(
                            fontFamily: 'GeistMono',
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isUnread)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.accentBlue,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _expanded
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(height: 16),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _isPlaying = !_isPlaying),
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: AppColors.accentBlue.withValues(
                                      alpha: 0.12,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: AppColors.accentBlue,
                                    size: 28,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onHorizontalDragUpdate: (d) {
                                    final box = context.findRenderObject()
                                        as RenderBox?;
                                    if (box == null) return;
                                    setState(
                                      () => _progress = (_progress +
                                              d.delta.dx / box.size.width)
                                          .clamp(0.0, 1.0),
                                    );
                                  },
                                  child: HarmonyAudioWaveform(
                                    progress: _progress,
                                    isPlaying: _isPlaying,
                                    height: 48,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.voicemailTranscriptionLabel,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.voicemail.transcription,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  height: 1.5,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _ActionButton(
                                icon: Icons.phone_outlined,
                                label: l10n.voicemailCallBack,
                                onTap: widget.onCallBack,
                              ),
                              const SizedBox(width: 8),
                              _ActionButton(
                                icon: Icons.mark_email_read_outlined,
                                label: l10n.voicemailMarkRead,
                                onTap: widget.onMarkRead,
                              ),
                              const SizedBox(width: 8),
                              _ActionButton(
                                icon: Icons.delete_outline_rounded,
                                label: l10n.voicemailDelete,
                                onTap: widget.onDelete,
                                isDestructive: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.name,
    required this.urgencyColor,
    required this.isUnread,
  });

  final String name;
  final Color urgencyColor;
  final bool isUnread;

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: urgencyColor.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(color: urgencyColor.withValues(alpha: 0.4)),
      ),
      child: Center(
        child: Text(
          _initials,
          style: TextStyle(
            color: urgencyColor,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.accentRed : AppColors.accentBlue;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

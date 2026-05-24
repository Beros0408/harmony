import 'package:flutter/material.dart';
import 'package:harmony/features/call_filter/domain/outgoing_call_detector.dart';
import 'package:harmony/l10n/app_localizations.dart';

/// Shows a warning dialog when an outgoing call is assessed as risky.
/// Returns true if the user chooses to proceed, false to cancel.
Future<bool> showOutgoingCallAlertDialog({
  required BuildContext context,
  required String phoneNumber,
  required OutgoingCallRisk risk,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _OutgoingCallAlertDialog(
      phoneNumber: phoneNumber,
      risk: risk,
    ),
  );
  return result ?? false;
}

class _OutgoingCallAlertDialog extends StatelessWidget {
  const _OutgoingCallAlertDialog({
    required this.phoneNumber,
    required this.risk,
  });

  final String phoneNumber;
  final OutgoingCallRisk risk;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDanger = risk.level == OutgoingCallRiskLevel.danger;
    final iconColor = isDanger ? Colors.red.shade400 : Colors.amber.shade400;
    final icon = isDanger ? Icons.warning_rounded : Icons.info_outline_rounded;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.outgoingCallAlertTitle,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            phoneNumber,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontFamily: 'GeistMono',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(risk.reason, style: theme.textTheme.bodyMedium),
          if (risk.estimatedCostPerMinute != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                l10n.outgoingCallAlertEstimatedCost(
                  risk.estimatedCostPerMinute!.toStringAsFixed(2),
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: iconColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.outgoingCallAlertCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(backgroundColor: iconColor),
          child: Text(
            l10n.outgoingCallAlertContinueButton,
            style: const TextStyle(color: Colors.black87),
          ),
        ),
      ],
    );
  }
}

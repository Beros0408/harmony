import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

class PinPad extends StatelessWidget {
  const PinPad({
    super.key,
    required this.onDigit,
    required this.onDelete,
    this.extraAction,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;

  /// Widget optionnel affiché à gauche de la touche 0 (ex. bouton biométrique)
  final Widget? extraAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRow(['1', '2', '3']),
        const SizedBox(height: 8),
        _buildRow(['4', '5', '6']),
        const SizedBox(height: 8),
        _buildRow(['7', '8', '9']),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ExtraCell(child: extraAction),
            _DigitKey(digit: '0', onTap: onDigit),
            _DeleteKey(onTap: onDelete),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: digits.map((d) => _DigitKey(digit: d, onTap: onDigit)).toList(),
    );
  }
}

class _DigitKey extends StatelessWidget {
  const _DigitKey({required this.digit, required this.onTap});

  final String digit;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return _PadButton(
      onTap: () => onTap(digit),
      child: Text(
        digit,
        style: AppTypography.textTheme.headlineSmall?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class _DeleteKey extends StatelessWidget {
  const _DeleteKey({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _PadButton(
      onTap: onTap,
      child: const Icon(
        Icons.backspace_outlined,
        color: AppColors.textSecondary,
        size: 24,
      ),
    );
  }
}

class _ExtraCell extends StatelessWidget {
  const _ExtraCell({this.child});
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 72,
      child: Center(child: child),
    );
  }
}

class _PadButton extends StatefulWidget {
  const _PadButton({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  State<_PadButton> createState() => _PadButtonState();
}

class _PadButtonState extends State<_PadButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: 88,
        height: 72,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: _pressed
              ? AppColors.bgInteractive
              : Colors.transparent,
        ),
        child: Center(child: widget.child),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';

class HarmonySearchBar extends StatefulWidget {
  const HarmonySearchBar({
    super.key,
    this.hintText = 'Rechercher...',
    this.onChanged,
    this.controller,
    this.autofocus = false,
  });

  final String hintText;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final bool autofocus;

  @override
  State<HarmonySearchBar> createState() => _HarmonySearchBarState();
}

class _HarmonySearchBarState extends State<HarmonySearchBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onTextChange);
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  void _onTextChange() {
    setState(() => _hasText = _controller.text.isNotEmpty);
    widget.onChanged?.call(_controller.text);
  }

  void _clear() {
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.removeListener(_onTextChange);
    _focusNode.dispose();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final borderColor = _isFocused ? AppColors.accentBlue : cs.outline;
    final borderWidth = _isFocused ? 1.5 : 1.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: AppRadius.lgRadius,
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(
            Icons.search,
            size: 18,
            color: _isFocused ? AppColors.accentBlue : cs.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: widget.autofocus,
              style: TextStyle(color: cs.onSurface, fontSize: 14),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (_hasText)
            GestureDetector(
              onTap: _clear,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.close, size: 16, color: cs.onSurfaceVariant),
              ),
            )
          else
            const SizedBox(width: 12),
        ],
      ),
    );
  }
}

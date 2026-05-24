import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class HarmonyAudioWaveform extends StatefulWidget {
  const HarmonyAudioWaveform({
    super.key,
    this.progress = 0.0,
    this.barCount = 35,
    this.color = AppColors.accentBlue,
    this.isPlaying = false,
    this.height = 48.0,
  });

  final double progress; // 0.0–1.0
  final int barCount;
  final Color color;
  final bool isPlaying;
  final double height;

  @override
  State<HarmonyAudioWaveform> createState() => _HarmonyAudioWaveformState();
}

class _HarmonyAudioWaveformState extends State<HarmonyAudioWaveform>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<double> _amplitudes;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _amplitudes = _generateAmplitudes();
    if (widget.isPlaying) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(HarmonyAudioWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _controller.repeat(reverse: true);
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<double> _generateAmplitudes() {
    final rng = math.Random(42);
    return List.generate(widget.barCount, (i) {
      final normalized = i / (widget.barCount - 1);
      final envelope = math.sin(normalized * math.pi);
      return 0.15 + envelope * 0.85 * (0.4 + rng.nextDouble() * 0.6);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return SizedBox(
          height: widget.height,
          child: CustomPaint(
            painter: _WaveformPainter(
              amplitudes: _amplitudes,
              progress: widget.progress,
              color: widget.color,
              animValue: widget.isPlaying ? _controller.value : 0.0,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }
}

class _WaveformPainter extends CustomPainter {
  const _WaveformPainter({
    required this.amplitudes,
    required this.progress,
    required this.color,
    required this.animValue,
  });

  final List<double> amplitudes;
  final double progress;
  final Color color;
  final double animValue;

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = (size.width / amplitudes.length) * 0.6;
    final gap = (size.width / amplitudes.length) * 0.4;
    final playedPaint = Paint()..color = color;
    final unplayedPaint = Paint()
      ..color = color.withValues(alpha: 0.25);
    final cursorPaint = Paint()
      ..color = color
      ..strokeWidth = 2;

    for (var i = 0; i < amplitudes.length; i++) {
      final x = i * (barWidth + gap) + barWidth / 2;
      final fraction = i / (amplitudes.length - 1);
      final isPlayed = fraction <= progress;

      // Slight animation jitter when playing
      final amp = amplitudes[i] *
          (isPlayed && animValue > 0
              ? 1.0 + animValue * 0.15 * math.sin(i.toDouble())
              : 1.0);
      final barHeight = math.max(2.0, amp * size.height);
      final top = (size.height - barHeight) / 2;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x - barWidth / 2, top, barWidth, barHeight),
        const Radius.circular(2),
      );
      canvas.drawRRect(rect, isPlayed ? playedPaint : unplayedPaint);
    }

    // Playback cursor
    if (progress > 0 && progress < 1) {
      final cx = progress * size.width;
      canvas.drawLine(Offset(cx, 0), Offset(cx, size.height), cursorPaint);
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) =>
      old.progress != progress || old.animValue != animValue;
}

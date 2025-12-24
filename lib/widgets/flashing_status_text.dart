import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FlashingStatusText extends StatefulWidget {
  final String text;
  const FlashingStatusText({super.key, required this.text});

  @override
  State<FlashingStatusText> createState() => _FlashingStatusTextState();
}

class _FlashingStatusTextState extends State<FlashingStatusText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnim;

  @override
  void initState() {
    super.initState();

    final baseColor = AppTheme.getStatusColor(widget.text);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _colorAnim = ColorTween(
      begin: baseColor.withValues(alpha: 0.4),
      end: baseColor,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnim,
      builder: (_, __) => Text(
        widget.text,
        style: TextStyle(color: _colorAnim.value, fontWeight: FontWeight.w600),
      ),
    );
  }
}

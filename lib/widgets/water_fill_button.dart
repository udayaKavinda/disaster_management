import 'package:flutter/material.dart';
import 'dart:math' as math;

class WaterFillButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double progress; // 0.0 to 1.0
  final bool disabled;

  const WaterFillButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
    this.isLoading = false,
    this.progress = 0.0,
    this.disabled = false,
  });

  @override
  State<WaterFillButton> createState() => _WaterFillButtonState();
}

class _WaterFillButtonState extends State<WaterFillButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Stack(
        children: [
          // Background button
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: widget.onPressed == null || widget.disabled
                    ? [Colors.grey[400]!, Colors.grey[400]!]
                    : [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColorDark,
                      ],
              ),
            ),
          ),

          // Water fill effect
          if (widget.isLoading)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AnimatedBuilder(
                animation: _waveController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: WaterWavePainter(
                      progress: widget.progress,
                      wavePhase: _waveController.value,
                    ),
                    child: Container(),
                  );
                },
              ),
            ),

          // Button content
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: widget.disabled ? null : widget.onPressed,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(widget.icon, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      widget.label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    if (widget.isLoading) ...[
                      const SizedBox(width: 12),
                      Text(
                        '${(widget.progress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WaterWavePainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final double wavePhase; // 0.0 to 1.0 (animation phase)

  WaterWavePainter({required this.progress, required this.wavePhase});

  @override
  void paint(Canvas canvas, Size size) {
    final waterHeight = size.height * progress;
    final paint = Paint()
      ..color = Colors.lightBlueAccent.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final path = Path();

    // Start from bottom left
    path.moveTo(0, size.height);

    // Draw left edge up to water level
    path.lineTo(0, size.height - waterHeight);

    // Draw wave at the top of water
    final waveWidth = size.width;
    final waveHeight = 8.0;
    final phaseShift = wavePhase * 2 * math.pi;

    for (double i = 0; i <= waveWidth; i++) {
      final x = i;
      final y =
          size.height -
          waterHeight +
          math.sin((i / waveWidth) * 4 * math.pi + phaseShift) * waveHeight;
      path.lineTo(x, y);
    }

    // Draw right edge down to bottom
    path.lineTo(size.width, size.height);

    // Close path
    path.close();

    canvas.drawPath(path, paint);

    // Add a second wave layer for depth
    final paint2 = Paint()
      ..color = Colors.blue.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height);
    path2.lineTo(0, size.height - waterHeight);

    for (double i = 0; i <= waveWidth; i++) {
      final x = i;
      final y =
          size.height -
          waterHeight +
          math.sin((i / waveWidth) * 4 * math.pi + phaseShift + math.pi) *
              waveHeight *
              0.7;
      path2.lineTo(x, y);
    }

    path2.lineTo(size.width, size.height);
    path2.close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(WaterWavePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.wavePhase != wavePhase;
  }
}

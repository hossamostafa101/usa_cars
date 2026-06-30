import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HexagonButton extends StatefulWidget {
  final Size size;
  final VoidCallback onTap;
  final Widget child;
  final Gradient? gradient;
  final Gradient? highlightGradient;
  final Color borderColor;
  final double borderWidth;
  final double shadowBlur;
  final double lift;

  const HexagonButton({
    super.key,
    required this.size,
    required this.onTap,
    required this.child,
    this.gradient,
    this.highlightGradient,
    this.borderColor = const Color(0x1AFFFFFF),
    this.borderWidth = 1.2,
    this.shadowBlur = 18,
    this.lift = 0,
  });

  @override
  State<HexagonButton> createState() => _HexagonButtonState();
}

class _HexagonButtonState extends State<HexagonButton>
    with TickerProviderStateMixin {
  late final AnimationController _pressController;
  late final AnimationController _pulseController;
  late final AnimationController _rotationController;

  late final Animation<double> _scale;
  late final Animation<double> _pulse;
  late final Animation<double> _rotation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    );

    _scale = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );

    _pulse = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotation = Tween<double>(begin: 0.0, end: 2 * pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
  }

  void _onPointerDown(PointerDownEvent event) {
    setState(() => _isPressed = true);
    _pressController.forward();
  }

  void _onPointerUp(PointerUpEvent event) {
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  @override
  void dispose() {
    _pressController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Default to green gradient if none provided (grocery vibe)
    final defaultGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF22C55E),
        Color(0xFF16A34A),
      ],
    );

    final defaultHighlight = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0x66FFFFFF),
        Color(0x00FFFFFF),
      ],
    );

    return Transform.translate(
      offset: Offset(0, -widget.lift),
      child: AnimatedBuilder(
        animation: Listenable.merge(
            [_pressController, _pulseController, _rotationController]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scale.value * _pulse.value,
            child: Listener(
              onPointerDown: _onPointerDown,
              onPointerUp: _onPointerUp,
              onPointerCancel: _onPointerCancel,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  widget.onTap();
                },
                child: SizedBox(
                  width: widget.size.width,
                  height: widget.size.height,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer green glow
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _HexGlowPainter(
                            blur: widget.shadowBlur + (_isPressed ? 4 : 0),
                            color: const Color(0xFF16A34A).withOpacity(0.35),
                          ),
                        ),
                      ),
                      // Shadow
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _HexShadowPainter(
                            blur: widget.shadowBlur,
                            offset: _isPressed ? 2 : 6,
                          ),
                        ),
                      ),
                      // Main hexagon
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _HexGradientPainter(
                            gradient: widget.gradient ?? defaultGradient,
                          ),
                        ),
                      ),
                      // Rotating highlight
                      Positioned.fill(
                        child: Transform.rotate(
                          angle: _rotation.value,
                          child: CustomPaint(
                            painter: _HexGradientPainter(
                              gradient:
                              widget.highlightGradient ?? defaultHighlight,
                            ),
                          ),
                        ),
                      ),
                      // Inner shine
                      const Positioned.fill(child: CustomPaint(painter: _HexShinePainter())),
                      // Border
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _HexBorderPainter(
                            color: widget.borderColor,
                            strokeWidth: widget.borderWidth,
                          ),
                        ),
                      ),
                      // Content
                      AnimatedScale(
                        scale: _isPressed ? 0.9 : 1.0,
                        duration: const Duration(milliseconds: 100),
                        child: widget.child,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

Path _hexPath(Size size) {
  final radius = size.width / 2;
  final centerX = size.width / 2;
  final centerY = size.height / 2;
  const angleStep = pi / 3;

  final path = Path();
  for (int i = 0; i < 6; i++) {
    final angle = angleStep * i;
    final x = centerX + radius * cos(angle);
    final y = centerY + radius * sin(angle);
    if (i == 0) {
      path.moveTo(x, y);
    } else {
      path.lineTo(x, y);
    }
  }
  path.close();
  return path;
}

class _HexGradientPainter extends CustomPainter {
  final Gradient gradient;
  _HexGradientPainter({required this.gradient});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = gradient.createShader(Offset.zero & size)
      ..isAntiAlias = true;
    canvas.drawPath(_hexPath(size), paint);
  }

  @override
  bool shouldRepaint(covariant _HexGradientPainter oldDelegate) {
    return oldDelegate.gradient != gradient;
  }
}

class _HexBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _HexBorderPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = color
      ..isAntiAlias = true;
    canvas.drawPath(_hexPath(size), paint);
  }

  @override
  bool shouldRepaint(covariant _HexBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}

class _HexShadowPainter extends CustomPainter {
  final double blur;
  final double offset;

  _HexShadowPainter({required this.blur, this.offset = 6});

  @override
  void paint(Canvas canvas, Size size) {
    final path = _hexPath(size);
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.18)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
    canvas.save();
    canvas.translate(0, offset);
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _HexShadowPainter oldDelegate) {
    return oldDelegate.blur != blur || oldDelegate.offset != offset;
  }
}

class _HexGlowPainter extends CustomPainter {
  final double blur;
  final Color color;

  _HexGlowPainter({required this.blur, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = _hexPath(size);
    final paint = Paint()
      ..color = color
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HexGlowPainter oldDelegate) {
    return oldDelegate.blur != blur || oldDelegate.color != color;
  }
}

class _HexShinePainter extends CustomPainter {
  const _HexShinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = _hexPath(size);
    final paint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.5),
        radius: 0.8,
        colors: [
          Colors.white.withOpacity(0.28),
          Colors.white.withOpacity(0.10),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size)
      ..isAntiAlias = true;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

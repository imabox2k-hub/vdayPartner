import 'package:flutter/material.dart';
import 'dart:math'; // Needed for confetti random positions

void main() => runApp(const ValentineApp());

class ValentineApp extends StatelessWidget {
  const ValentineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ValentineHome(),
      theme: ThemeData(useMaterial3: true),
    );
  }
}

class ValentineHome extends StatefulWidget {
  const ValentineHome({super.key});

  @override
  State<ValentineHome> createState() => _ValentineHomeState();
}

class _ValentineHomeState extends State<ValentineHome>
    with TickerProviderStateMixin {
  //  Emoji Selection
  final List<String> emojiOptions = ['Sweet Heart', 'Party Heart'];
  String selectedEmoji = 'Sweet Heart';

  //  Pulse Animation
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  //  Balloon Animation

  late AnimationController _balloonController;
  late Animation<double> _balloonAnimation;
  bool _showBalloons = false;

  // Sparkle Animation

  late AnimationController _sparkleController;
  late Animation<double> _sparkleAnimation;

  @override
  void initState() {
    super.initState();

    // ── Set up pulse animation (same as before) ──
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // ── Set up balloon animation ──
    // Duration: 3 seconds for balloons to float from bottom to top
    _balloonController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    // Value goes from 0.0 (bottom) to 1.0 (top of screen)
    _balloonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _balloonController, curve: Curves.easeOut),
    );

    // ── Set up sparkle animation ──
    // Duration: 1.5 seconds per sparkle cycle
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    // Value goes from 0.0 to 1.0, controlling sparkle opacity and size
    _sparkleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.easeInOut),
    );

    // Make sparkles repeat forever!
    _sparkleController.repeat(reverse: true);
  }

  @override
  void dispose() {
    // Clean up ALL controllers when widget is removed
    _pulseController.dispose();
    _balloonController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  // Trigger the pulse animation
  void _triggerPulse() {
    _pulseController.forward().then((_) {
      _pulseController.reverse();
    });
  }

  // ── NEW: Trigger balloon celebration ──
  // This shows balloons and animates them floating upward
  void _triggerBalloons() {
    setState(() {
      _showBalloons = true; // make balloons visible
    });

    // Start the animation from the beginning
    _balloonController.forward(from: 0.0).then((_) {
      // After 3 seconds, hide balloons
      setState(() {
        _showBalloons = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cupid's Canvas"),
        centerTitle: true,
        // ── NEW: Gradient background for app bar ──
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF6B9D), Color(0xFFFFC3A0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      // ── NEW: Radial gradient background for the whole screen ──
      // Creates a soft pink-to-red glow effect
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Color(0xFFFFF0F5), // very light pink in center
              Color(0xFFFFB6C1), // light pink
              Color(0xFFFF69B4), // hot pink at edges
            ],
            center: Alignment.center,
            radius: 1.5,
          ),
        ),
        // ── Stack allows us to layer balloons on top of other widgets ──
        child: Stack(
          children: [
            // Main content column
            Column(
              children: [
                const SizedBox(height: 16),

                // ──────────────────────────────────────────────
                // Emoji Selection Dropdown
                // ──────────────────────────────────────────────
                DropdownButton<String>(
                  value: selectedEmoji,
                  items: emojiOptions
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => selectedEmoji = value ?? selectedEmoji),
                ),

                const SizedBox(height: 16),

                // ──────────────────────────────────────────────
                // Buttons Row: Pulse and Balloons
                // ──────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Pulse button
                    ElevatedButton.icon(
                      onPressed: _triggerPulse,
                      icon: const Icon(Icons.favorite, color: Colors.pink),
                      label: const Text('Pulse!'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink.shade50,
                        foregroundColor: Colors.pink,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // ── NEW: Balloon button ──
                    ElevatedButton.icon(
                      onPressed: _triggerBalloons,
                      icon: const Icon(Icons.celebration, color: Colors.orange),
                      label: const Text('Balloons!'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade50,
                        foregroundColor: Colors.orange,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ──────────────────────────────────────────────
                // Animated Heart with Sparkles and Love Trail
                // ──────────────────────────────────────────────
                Expanded(
                  child: Center(
                    child: AnimatedBuilder(
                      // Listen to BOTH pulse and sparkle animations
                      animation: Listenable.merge([
                        _pulseAnimation,
                        _sparkleAnimation,
                      ]),
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: CustomPaint(
                            size: const Size(300, 300),
                            painter: HeartEmojiPainter(
                              type: selectedEmoji,
                              // Pass sparkle animation value to the painter
                              sparkleValue: _sparkleAnimation.value,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),

            // ── NEW: Balloon overlay (only visible when _showBalloons is true) ──
            if (_showBalloons)
              AnimatedBuilder(
                animation: _balloonAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    size: MediaQuery.of(context).size,
                    painter: BalloonPainter(
                      animationValue: _balloonAnimation.value,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class BalloonPainter extends CustomPainter {
  BalloonPainter({required this.animationValue});

  final double animationValue; // 0.0 to 1.0

  @override
  void paint(Canvas canvas, Size size) {
    // Define balloon colors
    final balloonColors = [
      Colors.red,
      Colors.pink,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.deepPurple,
    ];

    // Create 8 balloons at different horizontal positions
    for (int i = 0; i < 8; i++) {
      // Spread balloons evenly across the screen width
      final xPosition = (size.width / 9) * (i + 1);

      // Calculate balloon's current height based on animation
      // Balloons start below the screen (size.height + 100)
      // and float up to above the screen (-100)
      final startY = size.height + 100;
      final endY = -100.0;
      final currentY = startY + (endY - startY) * animationValue;

      // Add a slight wave motion for variety
      final waveOffset = sin(animationValue * 3.14 * 2 + i) * 15;
      final balloonX = xPosition + waveOffset;

      // ── Draw balloon string (a curved line) ──
      final stringPaint = Paint()
        ..color = Colors.grey.shade700
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      // String goes from balloon bottom to a point below it
      final stringPath = Path()
        ..moveTo(balloonX, currentY + 40) // bottom of balloon
        ..quadraticBezierTo(
          balloonX + 10,
          currentY + 60,
          balloonX,
          currentY + 80, // string endpoint
        );
      canvas.drawPath(stringPath, stringPaint);

      // ── Draw balloon body (oval shape) ──
      final balloonPaint = Paint()
        ..color = balloonColors[i]
        ..style = PaintingStyle.fill;

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(balloonX, currentY),
          width: 40,
          height: 50,
        ),
        balloonPaint,
      );

      // ── Draw balloon knot (small triangle at bottom) ──
      final knotPaint = Paint()..color = balloonColors[i].withOpacity(0.8);
      final knotPath = Path()
        ..moveTo(balloonX, currentY + 25)
        ..lineTo(balloonX - 5, currentY + 35)
        ..lineTo(balloonX + 5, currentY + 35)
        ..close();
      canvas.drawPath(knotPath, knotPaint);

      // ── Add shine/highlight on balloon ──
      final shinePaint = Paint()..color = Colors.white.withOpacity(0.4);
      canvas.drawCircle(Offset(balloonX - 8, currentY - 10), 8, shinePaint);
    }
  }

  @override
  bool shouldRepaint(covariant BalloonPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

class HeartEmojiPainter extends CustomPainter {
  HeartEmojiPainter({
    required this.type,
    this.sparkleValue = 0.0, // animation value for sparkles
  });

  final String type;
  final double sparkleValue;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    // ── NEW: Draw love trail (glowing aura behind heart) ──
    final trailPath = Path()
      ..moveTo(center.dx, center.dy + 65) // slightly bigger than main heart
      ..cubicTo(
        center.dx + 115,
        center.dy - 15,
        center.dx + 65,
        center.dy - 125,
        center.dx,
        center.dy - 45,
      )
      ..cubicTo(
        center.dx - 65,
        center.dy - 125,
        center.dx - 115,
        center.dy - 15,
        center.dx,
        center.dy + 65,
      )
      ..close();

    // Draw trail with soft pink glow
    final trailPaint = Paint()
      ..color = Colors.pink
          .withOpacity(1.0) // increased from 0.2 to 0.5 for more visibility
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        60,
      ); // increased from 15 to 30 for stronger glow
    canvas.drawPath(trailPath, trailPaint);

    // ── Step 1: Draw the heart shape with GRADIENT ──
    final heartPath = Path()
      ..moveTo(center.dx, center.dy + 60)
      ..cubicTo(
        center.dx + 110,
        center.dy - 10,
        center.dx + 60,
        center.dy - 120,
        center.dx,
        center.dy - 40,
      )
      ..cubicTo(
        center.dx - 60,
        center.dy - 120,
        center.dx - 110,
        center.dy - 10,
        center.dx,
        center.dy + 60,
      )
      ..close();

    // ── NEW: Use gradient instead of solid color ──
    if (type == 'Party Heart') {
      // Party heart: pink to light pink gradient
      paint.shader = const LinearGradient(
        colors: [Color(0xFFFF6B9D), Color(0xFFFFC3A0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    } else {
      // Sweet heart: deep pink to rose gradient
      paint.shader = const LinearGradient(
        colors: [Color(0xFFE91E63), Color(0xFFF48FB1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    }
    canvas.drawPath(heartPath, paint);

    // ── Step 2: Draw eyes ──
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(center.dx - 30, center.dy - 10), 10, eyePaint);
    canvas.drawCircle(Offset(center.dx + 30, center.dy - 10), 10, eyePaint);

    final pupilPaint = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(center.dx - 30, center.dy - 10), 5, pupilPaint);
    canvas.drawCircle(Offset(center.dx + 30, center.dy - 10), 5, pupilPaint);

    // ── Step 3: Draw mouth ──
    if (type == 'Sweet Heart') {
      final mouthPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(center.dx, center.dy + 15), radius: 20),
        0,
        3.14,
        false,
        mouthPaint,
      );

      // Rosy cheeks
      final blushPaint = Paint()..color = Colors.pink.shade100.withOpacity(0.6);
      canvas.drawCircle(Offset(center.dx - 45, center.dy + 10), 12, blushPaint);
      canvas.drawCircle(Offset(center.dx + 45, center.dy + 10), 12, blushPaint);
    } else {
      final mouthPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(center.dx, center.dy + 20), radius: 30),
        0,
        3.14,
        false,
        mouthPaint,
      );
    }

    // ── Step 4: Party Heart extras ──
    if (type == 'Party Heart') {
      // Party hat
      final hatPaint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFFD54F), Color(0xFFFFB74D)],
        ).createShader(Rect.fromLTWH(center.dx - 40, center.dy - 110, 80, 70));
      final hatPath = Path()
        ..moveTo(center.dx, center.dy - 110)
        ..lineTo(center.dx - 40, center.dy - 40)
        ..lineTo(center.dx + 40, center.dy - 40)
        ..close();
      canvas.drawPath(hatPath, hatPaint);

      // Hat stripes
      final stripePaint = Paint()
        ..color = Colors.orange
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(center.dx - 28, center.dy - 60),
        Offset(center.dx + 28, center.dy - 60),
        stripePaint,
      );
      canvas.drawLine(
        Offset(center.dx - 18, center.dy - 80),
        Offset(center.dx + 18, center.dy - 80),
        stripePaint,
      );

      // Pom-pom
      final pomPaint = Paint()..color = Colors.red;
      canvas.drawCircle(Offset(center.dx, center.dy - 110), 8, pomPaint);

      // ── NEW: Enhanced confetti with shapes ──
      final random = Random(42);
      final confettiColors = [
        Colors.yellow,
        Colors.blue,
        Colors.green,
        Colors.purple,
        Colors.orange,
        Colors.cyan,
        Colors.red,
      ];

      for (int i = 0; i < 25; i++) {
        final confettiPaint = Paint()
          ..color = confettiColors[i % confettiColors.length];

        final x = random.nextDouble() * size.width;
        final y = random.nextDouble() * size.height;

        // Alternate between circles and triangles for variety
        if (i % 2 == 0) {
          // Draw circle confetti
          final radius = 4.0 + random.nextDouble() * 3;
          canvas.drawCircle(Offset(x, y), radius, confettiPaint);
        } else {
          // Draw triangle confetti
          final triangleSize = 6.0 + random.nextDouble() * 4;
          final trianglePath = Path()
            ..moveTo(x, y - triangleSize)
            ..lineTo(x - triangleSize, y + triangleSize)
            ..lineTo(x + triangleSize, y + triangleSize)
            ..close();
          canvas.drawPath(trianglePath, confettiPaint);
        }
      }
    }

    // ── NEW: Draw animated sparkles around the heart ──

    _drawSparkles(canvas, center, size);
  }

  // Helper method to draw sparkles
  void _drawSparkles(Canvas canvas, Offset center, Size size) {
    final sparklePaint = Paint()
      ..color = Colors.yellow.withOpacity(sparkleValue * 0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()..color = Colors.white.withOpacity(sparkleValue);

    // Create 6 sparkles at different positions around the heart
    final sparklePositions = [
      Offset(center.dx - 80, center.dy - 60),
      Offset(center.dx + 80, center.dy - 60),
      Offset(center.dx - 100, center.dy + 20),
      Offset(center.dx + 100, center.dy + 20),
      Offset(center.dx - 60, center.dy + 70),
      Offset(center.dx + 60, center.dy + 70),
    ];

    for (final pos in sparklePositions) {
      // Each sparkle has 4 lines radiating out from center
      final sparkleSize = 8 * sparkleValue;

      // Horizontal line
      canvas.drawLine(
        Offset(pos.dx - sparkleSize, pos.dy),
        Offset(pos.dx + sparkleSize, pos.dy),
        sparklePaint,
      );

      // Vertical line
      canvas.drawLine(
        Offset(pos.dx, pos.dy - sparkleSize),
        Offset(pos.dx, pos.dy + sparkleSize),
        sparklePaint,
      );

      // Center dot
      canvas.drawCircle(pos, 2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant HeartEmojiPainter oldDelegate) =>
      oldDelegate.type != type || oldDelegate.sparkleValue != sparkleValue;
}

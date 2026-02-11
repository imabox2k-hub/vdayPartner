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

// ──────────────────────────────────────────────────────────
// We add "SingleTickerProviderStateMixin" so we can use
// an AnimationController for the pulsing heart effect.
// Think of it as giving our widget a "clock" to run animations.
// ──────────────────────────────────────────────────────────
class _ValentineHomeState extends State<ValentineHome>
    with SingleTickerProviderStateMixin {
  // ---------- Emoji Selection ----------
  final List<String> emojiOptions = ['Sweet Heart', 'Party Heart'];
  String selectedEmoji = 'Sweet Heart';

  // ---------- Pulse Animation ----------
  // The controller is the "engine" that drives the animation.
  late AnimationController _pulseController;
  // The animation holds the actual value (1.0 → 1.2 → 1.0) that
  // we use to scale the heart up and down.
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Set up the animation controller:
    //   - duration: how long one pulse takes (600 milliseconds)
    //   - vsync: this → uses our SingleTickerProviderStateMixin
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Tween defines the range: scale from 1.0 (normal) to 1.2 (bigger)
    // CurvedAnimation adds a nice ease-in-out feel instead of linear.
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    // Always clean up controllers when the widget is removed!
    _pulseController.dispose();
    super.dispose();
  }

  // This function is called when the user taps the pulse button.
  // It plays the animation forward, then reverses it back to normal.
  void _triggerPulse() {
    _pulseController.forward().then((_) {
      _pulseController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cupid's Canvas"), centerTitle: true),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // ──────────────────────────────────────────────
          // FEATURE 1: Emoji Selection Dropdown
          // Lets the user pick between "Sweet Heart" and
          // "Party Heart". When changed, setState redraws
          // the screen with the new emoji.
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
          // FEATURE 2: Pulse Button
          // A simple button that triggers the pulsing
          // heart animation when tapped.
          // ──────────────────────────────────────────────
          ElevatedButton.icon(
            onPressed: _triggerPulse,
            icon: const Icon(Icons.favorite, color: Colors.pink),
            label: const Text('Pulse!'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink.shade50,
              foregroundColor: Colors.pink,
            ),
          ),

          const SizedBox(height: 16),

          // ──────────────────────────────────────────────
          // FEATURE 3: Animated Heart Drawing
          // AnimatedBuilder listens to _pulseAnimation.
          // Every time the animation value changes, it
          // rebuilds this widget with a new scale value.
          // ──────────────────────────────────────────────
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    // _pulseAnimation.value goes from 1.0 → 1.2 → 1.0
                    scale: _pulseAnimation.value,
                    child: CustomPaint(
                      size: const Size(300, 300),
                      painter: HeartEmojiPainter(type: selectedEmoji),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// FEATURE 3 (continued): Dynamic Drawing with CustomPainter
//
// This painter draws TWO distinct emojis based on `type`:
//   - "Sweet Heart": A classic pink heart with cute eyes
//     and a sweet smile.
//   - "Party Heart": A festive heart with a party hat
//     and colorful confetti dots!
// ══════════════════════════════════════════════════════════
class HeartEmojiPainter extends CustomPainter {
  HeartEmojiPainter({required this.type});

  final String type;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    // ── Step 1: Draw the heart shape ──
    // This uses cubic Bezier curves to form a heart.
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

    // Different color for each emoji type
    paint.color = type == 'Party Heart'
        ? const Color(0xFFF48FB1) // lighter pink for party
        : const Color(0xFFE91E63); // bold pink for sweet
    canvas.drawPath(heartPath, paint);

    // ── Step 2: Draw eyes ──
    // White circles for the eyeballs
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(center.dx - 30, center.dy - 10), 10, eyePaint);
    canvas.drawCircle(Offset(center.dx + 30, center.dy - 10), 10, eyePaint);

    // Black pupils inside the white eyes
    final pupilPaint = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(center.dx - 30, center.dy - 10), 5, pupilPaint);
    canvas.drawCircle(Offset(center.dx + 30, center.dy - 10), 5, pupilPaint);

    // ── Step 3: Draw mouth (different per type) ──
    if (type == 'Sweet Heart') {
      // Sweet Heart gets a cute simple smile
      final mouthPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(center.dx, center.dy + 15), radius: 20),
        0, // start angle
        3.14, // sweep angle (half circle = smile)
        false,
        mouthPaint,
      );

      // Add cute rosy cheeks for the Sweet Heart
      final blushPaint = Paint()..color = Colors.pink.shade100.withOpacity(0.6);
      canvas.drawCircle(Offset(center.dx - 45, center.dy + 10), 12, blushPaint);
      canvas.drawCircle(Offset(center.dx + 45, center.dy + 10), 12, blushPaint);
    } else {
      // Party Heart gets a big open smile (filled arc)
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
      // --- Party Hat ---
      // A yellow triangle on top of the heart
      final hatPaint = Paint()..color = const Color(0xFFFFD54F);
      final hatPath = Path()
        ..moveTo(center.dx, center.dy - 110) // tip of hat
        ..lineTo(center.dx - 40, center.dy - 40) // bottom-left
        ..lineTo(center.dx + 40, center.dy - 40) // bottom-right
        ..close();
      canvas.drawPath(hatPath, hatPaint);

      // Hat stripes for extra detail
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

      // Small circle at the tip of the hat (pom-pom)
      final pomPaint = Paint()..color = Colors.red;
      canvas.drawCircle(Offset(center.dx, center.dy - 110), 8, pomPaint);

      // --- Confetti ---
      // Draw colorful dots scattered around the heart
      final random = Random(42); // fixed seed so confetti doesn't jump around
      final confettiColors = [
        Colors.yellow,
        Colors.blue,
        Colors.green,
        Colors.purple,
        Colors.orange,
        Colors.cyan,
        Colors.red,
      ];

      for (int i = 0; i < 20; i++) {
        final confettiPaint = Paint()
          ..color = confettiColors[i % confettiColors.length];

        // Random position within the canvas area
        final x = random.nextDouble() * size.width;
        final y = random.nextDouble() * size.height;

        // Draw small confetti circles (radius 4-7)
        final radius = 4.0 + random.nextDouble() * 3;
        canvas.drawCircle(Offset(x, y), radius, confettiPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant HeartEmojiPainter oldDelegate) =>
      oldDelegate.type != type;
}

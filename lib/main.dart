import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void initState() {
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 25000));

    animation = Tween<double>(
      begin: 0,
      end: 2,
    ).animate(animationController);

    animationController.forward();

    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController
          ..reset()
          ..forward();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final radius = screenSize.width * 2;
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.maxFinite,
          height: screenSize.height * .45,
          color: Colors.black,
          child: Stack(
            children: [
              AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return Positioned(
                      // left: -radius * 1.8,
                      // bottom: -radius * 1.7,
                      child: Transform.rotate(
                        angle: math.pi * animation.value,
                        // angle: 0,
                        child: CustomPaint(
                          size: Size(radius * .5, radius * .5),
                          painter: PiePainter(
                            sweepAngle: math.pi / 50,
                          ),
                        ),
                      ),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}

class PiePainter extends CustomPainter {
  final double sweepAngle;

  bool repaint = true;

  PiePainter({
    required this.sweepAngle,
  });

  final gradientColors = [
    Colors.purple,
    Colors.purple.withAlpha(100),
    Colors.purple.withAlpha(1),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final int totalSegments = (2 * math.pi / sweepAngle).abs().ceil();
    for (int i = 0; i < totalSegments; i++) {
      final segmentStart = sweepAngle * i * 2;
      final dx = center.dx + radius * math.cos(segmentStart + sweepAngle / 2);
      final dy = center.dy + radius * math.sin(segmentStart + sweepAngle / 2);
      final shader = ui.Gradient.linear(
        center,
        Offset(dx, dy),
        gradientColors,
        [.4, .7, 1],
      );
      final paint = Paint()..shader = shader;
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          rect,
          segmentStart,
          sweepAngle,
          false,
        )
        ..close();
      canvas.drawPath(path, paint);
    }
    repaint = false;
  }

  @override
  bool shouldRepaint(PiePainter oldDelegate) {
    return oldDelegate.repaint;
  }
}

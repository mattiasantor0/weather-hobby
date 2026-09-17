import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SolarCycleCard extends StatelessWidget {
  final DateTime sunrise;
  final DateTime sunset;
  final DateTime currentTime;
  final bool isDay;

  const SolarCycleCard({
    super.key,
    required this.sunrise,
    required this.sunset,
    required this.currentTime,
    required this.isDay,
  });

  @override
  Widget build(BuildContext context) {
    // Calcolo del progresso (0.0 a 1.0)
    double progress = 0.0;
    if (isDay) {
      final total = sunset.difference(sunrise).inMinutes;
      final passed = currentTime.difference(sunrise).inMinutes;
      progress = (passed / total).clamp(0.0, 1.0);
    } else {
      final nextSunrise = sunrise.add(const Duration(hours: 24));
      final total = nextSunrise.difference(sunset).inMinutes;
      final passed = currentTime.difference(sunset).inMinutes;
      progress = (passed / total).clamp(0.0, 1.0);
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white10, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isDay ? Icons.wb_sunny_outlined : Icons.nights_stay_outlined,
                size: 18,
                color: Colors.white38,
              ),
              const SizedBox(width: 8),
              Text(
                isDay ? "CICLO SOLARE" : "CICLO LUNARE",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white38,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          // L'arco grafico
          SizedBox(
            height: 100,
            width: double.infinity,
            child: CustomPaint(
              painter: _SunMoonArcPainter(progress: progress, isDay: isDay),
            ),
          ),
          const SizedBox(height: 15),
          // Orari sotto l'arco
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimeLabel("Alba", sunrise),
              _buildTimeLabel("Tramonto", sunset),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeLabel(String label, DateTime time) {
    return Column(
      crossAxisAlignment: label == "Alba" ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(label, style: GoogleFonts.inter(color: Colors.white38, fontSize: 10)),
        Text(
          "${time.hour}:${time.minute.toString().padLeft(2, '0')}",
          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }
}

class _SunMoonArcPainter extends CustomPainter {
  final double progress;
  final bool isDay;

  _SunMoonArcPainter({required this.progress, required this.isDay});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2.2; // Leggermente più piccolo per non toccare i bordi

    final Paint arcPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Disegno arco di base
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi, pi, false, arcPaint,
    );

    // Calcolo posizione icona
    final angle = pi + (pi * progress);
    final iconPos = Offset(center.dx + radius * cos(angle), center.dy + radius * sin(angle));

    // Glow e pallina
    final glowPaint = Paint()
      ..color = isDay ? Colors.orangeAccent.withOpacity(0.3) : Colors.indigoAccent.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    
    canvas.drawCircle(iconPos, 12, glowPaint);
    
    final iconPaint = Paint()..color = isDay ? Colors.orangeAccent : Colors.indigoAccent;
    canvas.drawCircle(iconPos, 6, iconPaint);
    canvas.drawCircle(iconPos, 3, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _SunMoonArcPainter oldDelegate) => oldDelegate.progress != progress;
}
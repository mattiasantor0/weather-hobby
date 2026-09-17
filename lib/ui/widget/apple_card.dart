import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppleWeatherCard extends StatelessWidget {
  final String title, value, subTitle;
  final IconData icon;
  final Color iconColor;

  const AppleWeatherCard({
    super.key, required this.title, required this.value,
    required this.subTitle, required this.icon, required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white10, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title.toUpperCase(), style: GoogleFonts.inter(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                    Icon(icon, color: iconColor, size: 18),
                  ],
                ),
                const SizedBox(height: 12),
                Text(value, style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
                Text(subTitle, style: GoogleFonts.inter(color: Colors.white60, fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
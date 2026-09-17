import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_app/ui/widget/apple_card.dart';
import 'package:weather_app/ui/widget/search_bar.dart';

import '../logic/weather_cubit.dart';
import '../logic/weather_state.dart';

class WeatherHomePage extends StatelessWidget {
  const WeatherHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1C1E), Color(0xFF080808)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: BlocBuilder<WeatherCubit, WeatherState>(
                builder: (context, state) {
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    children: [
                      PureSearchBar(),

                      if (state is WeatherLoading)
                        const Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: Center(
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          ),
                        ),

                      if (state is WeatherError)
                        Center(
                          child: Text(state.message, style: const TextStyle(color: Colors.redAccent)),
                        ),

                      if (state is WeatherInitial)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 100),
                            child: Text("Cerca una città per iniziare", style: TextStyle(color: Colors.white38)),
                          ),
                        ),

                      if (state is WeatherLoaded) ...[
                        _buildMainHeader(state,context),
                        _buildHourlyList(context, state),
                        
                        const SizedBox(height: 10),

                        SolarCycleCard(
                          sunrise: state.weather.sunrise,
                          sunset: state.weather.sunset,
                          currentTime: state.weather.currentTime,
                          isDay: state.weather.isDay,
                        ),

                        const SizedBox(height: 12),

                        // ALTRE CARD IN RIGHE DA DUE
                        Row(
                          children: [
                            Expanded(
                              child: AppleWeatherCard(
                                title: "HUMIDITY",
                                value: "${state.weather.humidity}%",
                                subTitle: "Umidità attuale",
                                icon: Icons.water_drop_rounded,
                                iconColor: Colors.blueAccent,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppleWeatherCard(
                                title: "RAIN PROB.",
                                value: "${state.weather.rainProbability}%",
                                subTitle: "Possibilità pioggia",
                                icon: Icons.umbrella_rounded,
                                iconColor: Colors.lightBlueAccent,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: AppleWeatherCard(
                                title: "UV INDEX",
                                value: "UV ${state.weather.uvIndex.toStringAsFixed(1)}",
                                subTitle: "Indice attuale",
                                icon: Icons.wb_sunny_rounded,
                                iconColor: Colors.orangeAccent,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppleWeatherCard(
                                title: "WIND",
                                value: "${state.weather.windSpeed.round()} km/h",
                                subTitle: "Velocità vento",
                                icon: Icons.air_rounded,
                                iconColor: Colors.tealAccent,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        AppleWeatherCard(
                          title: "YESTERDAY VS TODAY",
                          value: state.humanComparison,
                          subTitle: "Picco oggi: ${state.weather.todayMax.round()}°",
                          icon: Icons.compare_arrows_rounded,
                          iconColor: Colors.white,
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainHeader(WeatherLoaded state,BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              state.weather.cityName.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: Colors.white54,
                letterSpacing: 2.0,
              ),
              overflow: TextOverflow.ellipsis, // Se il nome è troppo lungo mette i puntini
            ),
          ),
          IconButton(
            onPressed: () {
              context.read<WeatherCubit>().toggleFavorite(state.weather.cityName);
            },
            icon: Icon(
              state.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: state.isFavorite ? Colors.redAccent : Colors.white38,
              size: 24,
            ),
          ),
        ],
      ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${state.weather.currentTemp.round()}°",
              style: GoogleFonts.inter(
                fontSize: 100,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -5,
              ),
            ),
            Icon(
              _getIcon(state.weather.weatherCode, state.weather.isDay),
              size: 80,
              color: state.weather.isDay ? Colors.orangeAccent : Colors.indigo[100],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHourlyList(BuildContext context, WeatherLoaded state) {
    return Container(
      height: 115,
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
        ),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: state.weather.hourlyTemp.length > 12 ? 12 : state.weather.hourlyTemp.length,
          itemBuilder: (context, index) {
            final slotTime = state.weather.currentTime.add(Duration(hours: index));
            bool isSlotDay = slotTime.isAfter(state.weather.sunrise) && 
                             slotTime.isBefore(state.weather.sunset);

            return Container(
              width: 75,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white10, width: 0.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    index == 0 ? "Ora" : "${slotTime.hour}:00",
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.white38),
                  ),
                  const SizedBox(height: 10),
                  Icon(
                    _getIcon(state.weather.hourlyCodes[index], isSlotDay),
                    size: 26,
                    color: isSlotDay ? Colors.orangeAccent : Colors.indigo[100],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${state.weather.hourlyTemp[index].round()}°",
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  IconData _getIcon(int code, bool isDay) {
    if (code <= 1) return isDay ? Icons.wb_sunny_rounded : Icons.brightness_3_rounded;
    if (code <= 3) return isDay ? Icons.wb_cloudy_rounded : Icons.nights_stay_rounded;
    if (code >= 51 && code <= 65) return Icons.umbrella_rounded;
    return isDay ? Icons.wb_cloudy_rounded : Icons.nights_stay_rounded;
  }
}


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
    double progress = 0.0;
    String labelSinistra;
    String labelDestra;
    DateTime oraSinistra;
    DateTime oraDestra;

    if (isDay) {
      // --- LOGICA GIORNO (Alba -> Tramonto) ---
      final totalMinutes = sunset.difference(sunrise).inMinutes;
      final passedMinutes = currentTime.difference(sunrise).inMinutes;
      
      progress = (passedMinutes / totalMinutes).clamp(0.0, 1.0);
      
      labelSinistra = "Alba";
      labelDestra = "Tramonto";
      oraSinistra = sunrise;
      oraDestra = sunset;
    } else {
      // --- LOGICA NOTTE (Tramonto -> Alba successiva) ---
      // Dobbiamo capire se siamo prima di mezzanotte o dopo
      DateTime inizioNotte;
      DateTime fineNotte;

      if (currentTime.isAfter(sunset)) {
        // Siamo tra il tramonto e mezzanotte
        inizioNotte = sunset;
        fineNotte = sunrise.add(const Duration(hours: 24));
      } else {
        // Siamo tra mezzanotte e l'alba
        inizioNotte = sunset.subtract(const Duration(hours: 24));
        fineNotte = sunrise;
      }

      final totalMinutes = fineNotte.difference(inizioNotte).inMinutes;
      final passedMinutes = currentTime.difference(inizioNotte).inMinutes;
      
      progress = (passedMinutes / totalMinutes).clamp(0.0, 1.0);

      // INVERTIAMO: La notte parte dal Tramonto e va verso l'Alba
      labelSinistra = "Tramonto";
      labelDestra = "Alba";
      oraSinistra = inizioNotte;
      oraDestra = fineNotte;
    }

    return Container(
      width: double.infinity,
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
                size: 16,
                color: isDay ? Colors.orangeAccent.withOpacity(0.5) : Colors.indigoAccent.withOpacity(0.5),
              ),
              const SizedBox(width: 8),
              Text(
                isDay ? "CICLO SOLARE" : "CICLO LUNARE",
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white38,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 35),
          // L'arco grafico
          SizedBox(
            height: 90,
            width: double.infinity,
            child: CustomPaint(
              painter: _SunMoonArcPainter(
                progress: progress,
                isDay: isDay,
              ),
            ),
          ),
          const SizedBox(height: 15),
          // Etichette dinamiche
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimeLabel(labelSinistra, oraSinistra, CrossAxisAlignment.start),
              _buildTimeLabel(labelDestra, oraDestra, CrossAxisAlignment.end),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeLabel(String label, DateTime time, CrossAxisAlignment align) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 2),
        Text(
          "${time.hour}:${time.minute.toString().padLeft(2, '0')}",
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
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
    final radius = size.width / 2.1;

    // 1. Disegno l'arco tratteggiato
    final Paint arcPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    double dashWidth = 4;
    double dashSpace = 4;
    double startAngle = pi;
    while (startAngle < 2 * pi) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashWidth / radius,
        false,
        arcPaint,
      );
      startAngle += (dashWidth + dashSpace) / radius;
    }

    // 2. Calcolo posizione della "pallina" (Sole o Luna)
    // L'angolo va da PI (sinistra) a 2*PI (destra)
    final angle = pi + (pi * progress);
    final iconPos = Offset(
      center.dx + radius * cos(angle),
      center.dy + radius * sin(angle),
    );

    // 3. Effetto Glow (Bagliore)
    final glowPaint = Paint()
      ..color = isDay ? Colors.orangeAccent.withOpacity(0.3) : Colors.indigoAccent.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(iconPos, 12, glowPaint);

    // 4. La pallina principale
    final mainPaint = Paint()
      ..color = isDay ? Colors.orangeAccent : Colors.indigoAccent;
    canvas.drawCircle(iconPos, 6, mainPaint);

    // 5. Punto luce centrale
    canvas.drawCircle(iconPos, 2.5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _SunMoonArcPainter oldDelegate) => 
      oldDelegate.progress != progress || oldDelegate.isDay != isDay;
}
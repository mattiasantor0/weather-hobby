import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_app/logic/weather_cubit.dart';
import 'package:weather_app/services/weather_repository.dart';
import 'package:weather_app/ui/home_page.dart';


void main() {
 final WeatherRepository weatherRepository = WeatherRepository();

  runApp(
    BlocProvider(
      create: (context) => WeatherCubit(weatherRepository)..initApp(),
      child: WeatherApp(),
    ),
  );
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      home:  WeatherHomePage(),
    );
  }
}

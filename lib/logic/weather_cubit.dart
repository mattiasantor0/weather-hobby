import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/weather_repository.dart';
import 'weather_state.dart';

class WeatherCubit extends Cubit<WeatherState> {
  final WeatherRepository repository;
  static const String _favKey = 'favorite_cities';

  WeatherCubit(this.repository) : super(WeatherInitial());

  Future<void> initApp() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favKey) ?? [];
    
    if (favorites.isNotEmpty) {
      fetchWeather(favorites.last);
    }
  }

  Future<void> fetchWeather(String cityName) async {
    emit(WeatherLoading());
    try {
      final weather = await repository.getFullWeather(cityName);
      
      // Controllo se la città è nei preferiti
      final prefs = await SharedPreferences.getInstance();
      final favorites = prefs.getStringList(_favKey) ?? [];
      bool isFavorite = favorites.contains(weather.cityName.toUpperCase());

      double diff = weather.todayMax - weather.yesterdayMax;
      String comparison = "Simile a ieri";
      if (diff >= 3) comparison = "Molto più caldo di ieri";
      if (diff <= -3) comparison = "Decisamente più freddo di ieri";

      emit(WeatherLoaded(weather, comparison, isFavorite: isFavorite));
    } catch (e) {
      emit(WeatherError(e.toString()));
    }
  }

  Future<void> toggleFavorite(String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList(_favKey) ?? [];

   String cityUpper = cityName.toUpperCase();

  if (favorites.contains(cityUpper)) {
    favorites.remove(cityUpper);
  } else {
    favorites.add(cityUpper);
  }

  await prefs.setStringList(_favKey, favorites);
  
  if (state is WeatherLoaded) {
    final currentState = state as WeatherLoaded;
    emit(WeatherInitial());
    emit(WeatherLoaded(
      currentState.weather,
      currentState.humanComparison,
      isFavorite: favorites.contains(cityUpper),
    ));
  }
  }

  void searchCities(String query) async {
    if (query.length < 3) return;
    try {
      await Dio().get(
        'https://geocoding-api.open-meteo.com/v1/search',
        queryParameters: {'name': query, 'count': 5, 'language': 'it'},
      );
    } catch (e) {
      print(e);
    }
  }
}
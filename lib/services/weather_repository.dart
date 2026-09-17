import 'package:dio/dio.dart';
import '../models/weather_model.dart';

class WeatherRepository {
  final Dio _dio = Dio();

  Future<WeatherData> getFullWeather(String cityName) async {
    try {
      final geoRes = await _dio.get(
        'https://geocoding-api.open-meteo.com/v1/search',
        queryParameters: {'name': cityName, 'count': 1, 'language': 'it'},
      );

      if (geoRes.data['results'] == null) throw "Città non trovata";
      final city = geoRes.data['results'][0];

      final weatherRes = await _dio.get(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': city['latitude'],
          'longitude': city['longitude'],
          'current': 'temperature_2m,weather_code,is_day,wind_speed_10m,relative_humidity_2m', 
          'hourly': 'temperature_2m,precipitation_probability,weather_code,uv_index',
          'daily': 'temperature_2m_max,sunrise,sunset',
          'timezone': 'auto',
          'forecast_days': 2,
        },
      );

      final current = weatherRes.data['current'];
      final hourly = weatherRes.data['hourly'];
      final daily = weatherRes.data['daily'];

      final DateTime cityTime = DateTime.parse(current['time']);

      int startIndex = cityTime.hour;

      return WeatherData(
        currentTemp: (current['temperature_2m'] as num).toDouble(), 
        cityName: city['name'].toString().toUpperCase(),
        yesterdayMax: (daily['temperature_2m_max'][0] as num).toDouble(),
        todayMax: (daily['temperature_2m_max'][0] as num).toDouble(),
        uvIndex: (hourly['uv_index'][startIndex] as num).toDouble(),
        humidity: (current['relative_humidity_2m'] as num).toInt(),
        sunrise: DateTime.parse(daily['sunrise'][0]), 
        sunset: DateTime.parse(daily['sunset'][0]),
        currentTime: cityTime,
        weatherCode: current['weather_code'] as int,
        isDay: current['is_day'] == 1,
        hourlyTemp: List<double>.from(hourly['temperature_2m'].sublist(startIndex, startIndex + 24)),
        hourlyCodes: List<int>.from(hourly['weather_code'].sublist(startIndex, startIndex + 24)),
        
        rainProbability: (hourly['precipitation_probability'][startIndex] as num).toInt(), 
        windSpeed: (current['wind_speed_10m'] ?? 0.0).toDouble(),
      );
    } catch (e) {
      rethrow;
    }
  }
}
class WeatherData {
  final double currentTemp;
  final String cityName;
  final double yesterdayMax;
  final double todayMax;
  final double uvIndex;
  final int humidity;
  final DateTime sunrise;
  final DateTime sunset;
  final int weatherCode;
  final bool isDay;
  final List<double> hourlyTemp;
  final List<int> hourlyCodes;
  final int rainProbability;
  final double windSpeed;
  final DateTime currentTime;

  WeatherData({
    required this.currentTemp,
    required this.cityName,
    required this.yesterdayMax,
    required this.todayMax,
    required this.uvIndex,
    required this.humidity,
    required this.sunrise,
    required this.sunset,
    required this.weatherCode,
    required this.isDay,
    required this.hourlyTemp,
    required this.hourlyCodes,
    required this.rainProbability,
    required this.windSpeed,
    required this.currentTime,
  });
}
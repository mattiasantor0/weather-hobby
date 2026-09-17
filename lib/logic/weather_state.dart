import 'package:equatable/equatable.dart';
import '../models/weather_model.dart';

abstract class WeatherState extends Equatable {
  @override
  List<Object?> get props => [];
}

class WeatherInitial extends WeatherState {}
class WeatherLoading extends WeatherState {}
class WeatherError extends WeatherState { final String message; WeatherError(this.message); }

class WeatherLoaded extends WeatherState {
  final WeatherData weather;
  final String humanComparison;
final bool isFavorite;

  WeatherLoaded(this.weather, this.humanComparison, {this.isFavorite = false});

  @override
  List<Object?> get props => [weather, humanComparison,isFavorite];
}
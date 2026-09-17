import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:weather_app/logic/weather_cubit.dart';


class PureSearchBar extends StatefulWidget {
  @override
  State<PureSearchBar> createState() => _PureSearchBarState();
}

class _PureSearchBarState extends State<PureSearchBar> {
  final SearchController _controller = SearchController();

  Future<Iterable<Widget>> _getSuggestions(String query) async {
    if (query.length < 3) return [];

    try {
      final res = await Dio().get(
        'https://geocoding-api.open-meteo.com/v1/search',
        queryParameters: {'name': query, 'count': 5, 'language': 'it'},
      );

      final List results = res.data['results'] ?? [];

      return results.map((city) => ListTile(
            leading: const Icon(Icons.location_on_outlined, color: Colors.white70),
            title: Text("${city['name']}, ${city['country']}", 
                style: GoogleFonts.inter(color: Colors.white)),
            subtitle: Text(city['admin1'] ?? "", 
                style: GoogleFonts.inter(color: Colors.white38, fontSize: 12)),
            onTap: () {
              _controller.closeView(city['name']); 
              context.read<WeatherCubit>().fetchWeather(city['name']);
              FocusScope.of(context).unfocus();
            },
          ));
    } catch (e) {
      return [const ListTile(title: Text("Errore durante la ricerca"))];
    }
  }

  @override
  Widget build(BuildContext context) {
    return SearchAnchor(
      searchController: _controller,
      viewBackgroundColor: const Color(0xFF1A1C1E),
      viewSurfaceTintColor: Colors.transparent,
      builder: (context, controller) {
        return SearchBar(
          controller: controller,
          padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16)),
          onTap: () => controller.openView(),
          onChanged: (_) => controller.openView(),
          leading: const Icon(Icons.search, color: Colors.white38),
          hintText: "Cerca una città...",
          hintStyle: WidgetStatePropertyAll(GoogleFonts.inter(color: Colors.white38)),
          textStyle: WidgetStatePropertyAll(GoogleFonts.inter(color: Colors.white)),
          backgroundColor: WidgetStatePropertyAll(Colors.white.withOpacity(0.05)),
          elevation: WidgetStatePropertyAll(0),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        );
      },
      suggestionsBuilder: (context, controller) async {
        return await _getSuggestions(controller.text);
      },
    );
  }
}
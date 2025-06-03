import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

const String apiKey = "a514471010e64c11ad0170636250206";

class WeatherApi {
  final String _baseUrl = "https://api.weatherapi.com/v1";

  Future<Map<String, dynamic>> getHourlyForecast(String location) async {
    final url = Uri.parse(
      "$_baseUrl/forecast.json?key=$apiKey&q=$location&days=7",
    );

    try {
      final res = await http.get(url).timeout(Duration(seconds: 10));

      if (res.statusCode != 200) {
        throw Exception("Failed to fetch data: ${res.body}");
      }

      final data = json.decode(res.body);

      if (data.containsKey('error')) {
        throw Exception(data['error']['message'] ?? 'Invalid location');
      }

      return data;
    } catch (e) {
      debugPrint("getHourlyForecast error: $e");
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getPastSevenDayWeather(
    String location,
  ) async {
    final List<Map<String, dynamic>> pastWeather = [];
    final today = DateTime.now();

    for (int i = 1; i <= 7; i++) {
      final date = today.subtract(Duration(days: i));
      final formattedDate =
          "${date.year}-${date.month.toString().padLeft(2, "0")}-${date.day.toString().padLeft(2, "0")}";

      final url = Uri.parse(
        "$_baseUrl/history.json?key=$apiKey&q=$location&dt=$formattedDate",
      );

      try {
        final res = await http.get(url).timeout(Duration(seconds: 10));
        if (res.statusCode == 200) {
          final data = json.decode(res.body);
          if (data.containsKey('error')) {
            throw Exception(data['error']['message'] ?? 'Invalid location');
          }
          if (data['forecast']?['forecastday'] != null) {
            pastWeather.add(data);
          }
        } else {
          debugPrint(
            "Failed to fetch past data for $formattedDate: ${res.body}",
          );
        }
      } catch (e) {
        debugPrint("Error fetching past data for $formattedDate: $e");
      }
    }

    return pastWeather;
  }
}

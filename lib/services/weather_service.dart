// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  // Your generated API Key
  final String apiKey = "aed6f7f4a807878a06bcf56b8d348de8";

  Future<Map<String, dynamic>?> fetchWeather(String city) async {
    // We use units=metric to get Celsius
    final url = Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Successful API call
        return jsonDecode(response.body);
      } else {
        print("Weather API Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Connection Error: $e");
      return null;
    }
  }
}
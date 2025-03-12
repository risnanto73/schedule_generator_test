import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ScheduleService {
  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? "";
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';


  static Future<String> generateSchedule(String scheduleName, String priority, String duration, String fromDate, String untilDate) async {
    if (_apiKey.isEmpty) {
      return "Error: API key tidak ditemukan!";
    }

    final String apiUrl = '$_baseUrl?key=$_apiKey';

    final Map<String, dynamic> requestBody = {
      "contents": [
        {
          "parts": [
            {
              "text":
              "Buatkan jadwal dengan nama $scheduleName, berdasarkan prioritas $priority, durasi $duration jam, dari $fromDate hingga $untilDate."
            }
          ]
        }
      ]
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        return "Error: ${response.body}";
      }
    } catch (e) {
      return "Terjadi kesalahan: $e";
    }
  }
}
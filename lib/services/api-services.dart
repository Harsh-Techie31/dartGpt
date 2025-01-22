import 'dart:convert';
import 'dart:developer';
import 'package:dartgpt/models/model-models.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static Future<List<ModelsModel>> getModels() async {
    final String apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

    if (apiKey.isEmpty) {
      log('Error: API key is missing or not configured.');
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse("https://api.openai.com/v1/models"),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json"
        },
      );

      if (response.statusCode == 200) {
        log("reached here1");
        // log("API KEY : $apiKey");
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        log("reached here2");

        final List<dynamic> data = jsonResponse['data'] ?? [];
        log("reached here3");

        
        // log('Response JSON: $jsonResponse');
        return ModelsModel.modelsFromApi(data);
        

      } else {
        log('Failed to fetch models. Status code: ${response.statusCode}');
        log('Response body: ${response.body}');
      }
    } catch (error) {
      log('Exception occurred while fetching models: $error');
    }
    return [];
  }
}

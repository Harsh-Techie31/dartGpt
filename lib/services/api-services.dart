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
          // "Content-Type": "application/json"
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

  //FOR SENDING THE MESSAGE

  static Future<String> sendMessage(
      {required String msg, required String modelid}) async {
    final String apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

    if (apiKey.isEmpty) {
      log('Error: API key is missing or not configured.');
      return "";
    }

    try {
      // print("[log]model :  $modelid  --  message : $msg");
      final response = await http.post(
        Uri.parse("https://api.openai.com/v1/chat/completions"),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json"
        },
        body: jsonEncode({"model": modelid, "messages": jsonDecode(msg)}),
      );

      if (response.statusCode == 200) {
        // log("RESPONSE : ${response.body}");
        Map jsonResponse = jsonDecode(response.body);

        if (jsonResponse["choices"].length > 0) {
          // print("[log]ANSWER : ${jsonResponse["choices"][0]["message"]["content"]}");
          return jsonResponse["choices"][0]["message"]["content"];
        }
      } else {
        log('Failed to fetch respone . Status code: ${response.statusCode}');
        log('Response body: ${response.body}');
      }
    } catch (error) {
      log('Exception occurred while fetching respone: $error');
    }
    return "";
  }

  //FOR SENDING MESSAGE WITH IMAGES
  static Future<String> sendMessageWithUrl(
      {required String msg, required String imgUrl}) async {
    final String apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

    if (apiKey.isEmpty) {
      log('Error: API key is missing or not configured.');
      return "";
    }

    try {
      // print("[log]model :  $modelid  --  message : $msg");
      final response = await http.post(
        Uri.parse("https://api.openai.com/v1/chat/completions"),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "model": "gpt-4o",
          "messages": [
            {
              "role": "user",
              "content": [
                {"type": "text", "text": msg},
                {
                  "type": "image_url",
                  "image_url": {"url": imgUrl}
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        // log("RESPONSE : ${response.body}");
        Map jsonResponse = jsonDecode(response.body);

        if (jsonResponse["choices"].length > 0) {
          // print("[log]ANSWER : ${jsonResponse["choices"][0]["message"]["content"]}");
          return jsonResponse["choices"][0]["message"]["content"];
        }
      } else {
        log('Failed to fetch respone . Status code: ${response.statusCode}');
        log('Response body: ${response.body}');
      }
    } catch (error) {
      log('Exception occurred while fetching respone: $error');
    }
    return "";
  }

  static Future<bool> saveConversation({
    required String convoId,
    required String convoTitle,
    required List<Map<String, dynamic>> messages,
  }) async {
    final String backendUrl = 'http://10.85.0.123:2000/post-data';

    try {
      print("[log] reached till localhost api");
      print("[log] sending data: ${jsonEncode({
            "convoId": convoId,
            "convoTitle": convoTitle,
            "messages": messages, // Don't jsonEncode messages here
          })}");

      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {
          "Content-Type": "application/json", // Ensure correct content type
        },
        body: jsonEncode({
          "convoId": convoId,
          "convoTitle": convoTitle,
          "messages": messages, // Don't jsonEncode messages here
        }),
      );

      if (response.statusCode == 200) {
        log('Conversation saved successfully!');
        return true;
      } else {
        log('Failed to save conversation. Status code: ${response.statusCode}');
        log('Response body: ${response.body}');
      }
    } catch (error) {
      log('Exception occurred while saving conversation: $error');
    }
    return false;
  }
}

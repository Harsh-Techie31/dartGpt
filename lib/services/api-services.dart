import 'dart:convert';
import 'dart:developer';
import 'package:dartgpt/models/message-model.dart';
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
  final String backendUrl = 'https://dart-gpt.vercel.app/post-data';

  if (messages.isEmpty) {
    log('Failed to save conversation: Messages cannot be empty');
    return false;
  }

  try {
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




  static Future<List<Map<String, dynamic>>> getAllConversations() async {
    final String backendUrl = 'https://dart-gpt.vercel.app/get-conversations';

    try {
      final response = await http.get(
        Uri.parse(backendUrl),
        headers: {
          "Content-Type": "application/json", // Ensure correct content type
        },
      );

      if (response.statusCode == 200) {
        // Parse the response body
        Map jsonResponse = jsonDecode(response.body);
        
        // Return the list of conversations
        if (jsonResponse['conversations'] != null) {
          return List<Map<String, dynamic>>.from(jsonResponse['conversations']);
        } else {
          log("No conversations found in the response.");
          return [];
        }
      } else {
        log('Failed to fetch conversations. Status code: ${response.statusCode}');
        log('Response body: ${response.body}');
      }
    } catch (error) {
      log('Exception occurred while fetching conversations: $error');
    }
    return [];
  }


  // Add this function in your ApiService class
static Future<List<Message>> getMessagesForConvoId(String convoId) async {
  final String backendUrl = 'https://dart-gpt.vercel.app/get-conversation/$convoId';

  try {
    final response = await http.get(
      Uri.parse(backendUrl),
      headers: {
        "Content-Type": "application/json", // Ensure correct content type
      },
    );

    if (response.statusCode == 200) {
      // Parse the response body
      Map jsonResponse = jsonDecode(response.body);
      
      // Check if the response contains messages
      if (jsonResponse['messages'] != null) {
        // Map the messages to a list of Message objects
        List<Message> messages = (jsonResponse['messages'] as List)
            .map((messageJson) => Message.fromJson(messageJson))
            .toList();
        return messages;
      } else {
        log("No messages found for this conversation.");
        return [];
      }
    } else {
      log('Failed to fetch messages. Status code: ${response.statusCode}');
      log('Response body: ${response.body}');
    }
  } catch (error) {
    log('Exception occurred while fetching messages for conversation: $error');
  }
  return [];
}

}



import 'package:dartgpt/models/message-model.dart';
import 'package:dartgpt/services/api-services.dart';

Future<List<Message>> fetchMessages(String convoId) async {
  List<Message> messages = await ApiService.getMessagesForConvoId(convoId);
  
  if (messages.isNotEmpty) {
    // Successfully fetched messages
    return messages;
  } else {
    List<Message> alt =[];
    return alt;
  }
}
import 'dart:convert';

import 'package:dartgpt/models/message-model.dart';

class Conversation {
  final String conversationId;
  final List<Message> messages;

  Conversation({
    required this.conversationId,
    required this.messages,
  });

  // Convert a Conversation to JSON for MongoDB
  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'messages': messages.map((msg) => msg.toJson()).toList(),
    };
  }

  // Create a Conversation object from JSON
  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      conversationId: json['conversationId'],
      messages: (json['messages'] as List<dynamic>)
          .map((msg) => Message.fromJson(msg))
          .toList(),
    );
  }


  String toApiJson() {
  return jsonEncode(messages.map((msg) => msg.toApiJson()).toList());
}
}
import 'dart:async';

import 'package:dartgpt/models/conversation-model.dart';
import 'package:dartgpt/models/message-model.dart';
import 'package:dartgpt/services/api-services.dart';
import 'package:flutter/material.dart';

class ConversationProvider with ChangeNotifier {
  late Conversation _conversation;
  final StreamController<List<Message>> _messageStreamController =
      StreamController<List<Message>>.broadcast();
  bool isTyping = false;

  // Initialize a conversation
  void initializeConversation(String conversationId) {
    _conversation = Conversation(conversationId: conversationId, messages: []);
    _messageStreamController.add(_conversation.messages);
    notifyListeners();
  }

  Conversation get conversation => _conversation;

  Stream<List<Message>> get messageStream => _messageStreamController.stream;

  // Add a user message
  Future<void> addUserMessage(String content, String currentModel) async {
    final message = Message(
      role: 'user',
      content: content,
      timestamp: DateTime.now(),
    );

    _conversation.messages.add(message);
    _messageStreamController.add(_conversation.messages);
    notifyListeners();
    isTyping = true;
    notifyListeners();

    await _getAssistantResponse(currentModel);
    logApiJson();
  }

  void logApiJson() {
    final apiJson = _conversation.toApiJson();
    print("Conversation [log] toApiJson: $apiJson");
  }

  // Get assistant response from API
  Future<void> _getAssistantResponse(String modelId) async {
  try {
    String reply = await ApiService.sendMessage(msg: _conversation.toApiJson(), modelid: modelId);

    // Simulate word-by-word typing effect
    isTyping = false;
    notifyListeners();
    await _simulateTypingEffect(reply);
  } catch (e) {
    print('Error fetching assistant response: $e');
  }finally{
    isTyping = false;
    notifyListeners();
  }
}

Future<void> _simulateTypingEffect(String fullReply) async {
  final words = fullReply.split(' '); // Split reply into words
  String displayedText = '';

  for (var word in words) {
    displayedText = '$displayedText $word'.trim(); // Append one word at a time
    final messageReply = Message(
      role: 'assistant',
      content: displayedText,
      timestamp: DateTime.now(),
    );

    // Replace the last message in the conversation to simulate typing
    if (_conversation.messages.isNotEmpty && 
        _conversation.messages.last.role == 'assistant') {
      _conversation.messages.removeLast();
    }
    _conversation.messages.add(messageReply);

    notifyListeners(); // Notify UI to update
    await Future.delayed(const Duration(milliseconds: 10)); // Delay for typing effect
  }
}

  // Reset the conversation
  void resetConversation(String conversationId) {
    _conversation = Conversation(conversationId: conversationId, messages: []);
    _messageStreamController.add(_conversation.messages);
    notifyListeners();
  }

  @override
  void dispose() {
    _messageStreamController.close();
    super.dispose();
  }
}

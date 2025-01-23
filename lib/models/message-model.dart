class Message {
  final String role; // "user" or "assistant"
  final String content;
  final DateTime timestamp;

  Message({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  // Convert a Message to JSON for MongoDB or local storage (includes timestamp)
  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Convert a Message to JSON for API requests (excludes timestamp)
  Map<String, dynamic> toApiJson() {
    return {
      'role': role,
      'content': content,
    };
  }

  // Create a Message object from JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      role: json['role'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

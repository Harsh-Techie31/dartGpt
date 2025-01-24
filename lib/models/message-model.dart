class Message {
  final String role; // "user" or "assistant"
  final String content; // The text content of the message
  final String? url; // Nullable URL field, used only if there's an image or external link
  final DateTime timestamp;

  Message({
    required this.role,
    required this.content,
    this.url, // Optional parameter for URLs
    required this.timestamp,
  });

  // Convert a Message to JSON for MongoDB or local storage (includes timestamp)
  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
      'url': url,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Convert a Message to JSON for API requests (excludes timestamp)
  Map<String, dynamic> toApiJson() {
    return {
      'role': role,
      'content': content,
      if (url != null) 'url': url, // Only include 'url' if it’s not null
    };
  }

  // Create a Message object from JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      role: json['role'],
      content: json['content'],
      url: json['url'], // Handle null URL
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

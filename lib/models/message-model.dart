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
    // Checking for the existence of timestamp, if it's in the expected format
    DateTime parsedTimestamp;
    if (json['timestamp'] is Map && json['timestamp']['\$date'] != null) {
      // Handling the case where timestamp is in the MongoDB format
      parsedTimestamp = DateTime.fromMillisecondsSinceEpoch(
          int.parse(json['timestamp']['\$date']['\$numberLong']));
    } else {
      // If the timestamp is in ISO format or regular DateTime
      parsedTimestamp = DateTime.parse(json['timestamp']);
    }

    return Message(
      role: json['role'],
      content: json['content'],
      url: json['url'], // Handle null URL
      timestamp: parsedTimestamp,
    );
  }
}

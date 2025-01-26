import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String msg;
  final String? imageUrl; // Add an optional imageUrl parameter
  final int index;

  const ChatBubble({
    super.key,
    required this.msg,
    this.imageUrl, // Initialize imageUrl
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment:
          index == 0 ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: index == 0
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (imageUrl != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl!,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(
                        Icons.broken_image,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 14),
                decoration: BoxDecoration(
                  color: index == 0
                      ? const Color.fromARGB(
                          255, 56, 56, 56) // User message background
                      : Colors.transparent, // Bot message background
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: index == 0
                        ? const Radius.circular(20)
                        : Radius.zero,
                    bottomRight: index == 0
                        ? const Radius.circular(20)
                        : Radius.zero,
                  ),
                ),
                child: SelectableText(
                  msg,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:dartgpt/constant/constants.dart';
import 'package:dartgpt/services/assets.dart';
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            index == 0 ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (index != 0) ...[
            Image.asset(
              assetholder.botpfp,
              height: 30,
              width: 30,
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Material(
              color: index == 0 ? scaffoldBackgroundColor : cardColor,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment:
                      index == 0 ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    // Display the image if imageUrl is provided
                    if (imageUrl != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            height: 100,width: 100,
                            imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                          ),
                        ),
                      ),
                    Text(
                      msg,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    if (index == 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Icons.thumb_up_alt_outlined,
                                color: Colors.white70, size: 18),
                            const SizedBox(width: 8),
                            Icon(Icons.thumb_down_alt_outlined,
                                color: Colors.white70, size: 18),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (index == 0) ...[
            const SizedBox(width: 10),
            Image.asset(
              assetholder.userpfp,
              height: 30,
              width: 30,
            ),
          ],
        ],
      ),
    );
  }
}

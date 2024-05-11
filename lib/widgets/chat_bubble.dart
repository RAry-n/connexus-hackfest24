import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.time,
    required this.text,
    required this.isCurrentUser,
  });
  final String text;
  final String time;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // asymmetric padding
      padding: EdgeInsets.fromLTRB(
        isCurrentUser ? 64.0 : 16.0,
        8,
        isCurrentUser ? 16.0 : 64.0,
        8,
      ),
      child: Align(
        // align the child within the container
        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
        child: DecoratedBox(
          // chat bubble decoration
          decoration: BoxDecoration(
            color: isCurrentUser ? Colors.blue : Colors.grey[300],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    text,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: isCurrentUser ? Colors.white : Colors.black87),
                  ),
                ),
                Container(
                    alignment: Alignment.centerRight,
                    child: Text(
                      time,

                      style: TextStyle(
                          fontSize: 12,
                          color: isCurrentUser ? Colors.white : Colors.black87
                      ),
                    )
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
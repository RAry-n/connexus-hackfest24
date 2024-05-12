import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    Key? key,
    required this.time,
    required this.text,
    required this.isCurrentUser,
  }) : super(key: key);

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
            // Adding triangle shape
            shape: BoxShape.rectangle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: TextStyle(
                        color: isCurrentUser? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Futura',
                      ),
                      // style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      //   color: isCurrentUser ? Colors.white : Colors.black87,
                      // ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 8,
                        fontFamily: 'Futura',
                        color: isCurrentUser ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                left: isCurrentUser ? null : 0,
                right: isCurrentUser ? 0 : null,
                child: CustomPaint(
                  size: const Size(20, 20),
                  painter: TrianglePainter(
                    color: isCurrentUser ? Colors.blue : Colors.grey[300]!,
                    direction: isCurrentUser ? TriangleDirection.right : TriangleDirection.left,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum TriangleDirection { left, right }

class TrianglePainter extends CustomPainter {
  final Color color;
  final TriangleDirection direction;

  TrianglePainter({required this.color, required this.direction});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = color;
    Path path = Path();
    if (direction == TriangleDirection.left) {
      path.moveTo(0, 0);
      path.lineTo(size.width, size.height / 2);
      path.lineTo(0, size.height);
      path.close();
    } else {
      path.moveTo(size.width, 0);
      path.lineTo(0, size.height / 2);
      path.lineTo(size.width, size.height);
      path.close();
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(TrianglePainter oldDelegate) {
    return color != oldDelegate.color || direction != oldDelegate.direction;
  }
}

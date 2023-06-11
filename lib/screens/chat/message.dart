import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:komuniti/constant/color.dart';

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isSentByMe;
  final String time;
  final bool isRead;
  final String imageUrl;

  const ChatMessage({
    required this.text,
    required this.isSentByMe,
    required this.time,
    required this.isRead,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final alignment = isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = isSentByMe ? Colors.white : Colors.grey.shade300;
    final textColor = isSentByMe ? Colors.black : Colors.black;
    final timeAlignment = isSentByMe ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          if (imageUrl.isNotEmpty)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullScreenImage(imageUrl: imageUrl),
                  ),
                );
              },
              child:CachedNetworkImage(
                imageUrl: imageUrl,
                width: 200, // Set the desired width of the image
                height: 200, // Set the desired height of the image
                placeholder: (context, url) => Container(
    alignment: Alignment.center,
    padding: EdgeInsets.all(16.0),
    child: SizedBox(
    width: 18,
    height: 18,
    child: CircularProgressIndicator(
    strokeWidth: 2, // Adjust the strokeWidth to change the size
    valueColor: AlwaysStoppedAnimation<Color>(
    Colors.black), // Set the color to black
    ),
    ),
    ), // Placeholder widget while loading
                errorWidget: (context, url, error) => Icon(Icons.error), // Error widget if image fails to load
              ),
            ),
          if (imageUrl.isNotEmpty) SizedBox(height: 8),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: isSentByMe ? Radius.circular(16) : Radius.circular(0),
                bottomRight: isSentByMe ? Radius.circular(0) : Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageUrl.isEmpty)
                  Text(
                    text,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Product Sans',
                    ),
                  ),
                SizedBox(height: 4),
                Align(
                  alignment: timeAlignment,
                  child: Row(
                    mainAxisAlignment: timeAlignment == Alignment.centerRight
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      if (isSentByMe) ...[
                        Icon(
                          Icons.done_all,
                          size: 16,
                          color: isRead ? Colors.blue : Colors.grey,
                        ),
                        SizedBox(width: 4),
                      ],
                      Text(
                        time,
                        style: TextStyle(color: Colors.black, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 200.ms).saturate();
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       backgroundColor: bgColor,
      ),
      body: Scaffold(backgroundColor: bgDarkColor,
        body: Center(
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
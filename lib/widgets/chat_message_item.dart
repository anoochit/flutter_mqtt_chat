// chat message item widget
import 'package:flutter/material.dart';
import 'package:mqtt_chat/const.dart';

class ChatMessageItem extends StatelessWidget {
  const ChatMessageItem({
    Key? key,
    required this.from,
    required this.content,
  }) : super(key: key);

  final String from;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: (from == userId) ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: (from == userId)
                ? const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(0),
                  )
                : const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(10),
                  ),
            color: (from == userId) ? Colors.blue.shade300 : Colors.grey.shade300,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(content),
          ),
        ),
      ),
    );
  }
}

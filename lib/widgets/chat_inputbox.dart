import 'package:flutter/material.dart';
import 'package:mqtt_chat/utils/mqtt.dart';

class ChatInputBox extends StatelessWidget {
  const ChatInputBox({
    Key? key,
    required this.textEditingController,
  }) : super(key: key);

  final TextEditingController textEditingController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(thickness: 1.0, height: 0.0),
        SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              controller: textEditingController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Type your message',
              ),
              onFieldSubmitted: (value) {
                mqttPublish(message: value);
                textEditingController.clear();
              },
            ),
          ),
        )
      ],
    );
  }
}

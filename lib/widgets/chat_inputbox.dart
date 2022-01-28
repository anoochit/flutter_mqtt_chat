import 'dart:developer';

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
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: textEditingController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Type your message',
                suffixIcon: IconButton(
                  onPressed: () {
                    log("send message");
                    if (textEditingController.text.trim().isNotEmpty) {
                      mqttPublish(message: textEditingController.text);
                      textEditingController.clear();
                    }
                  },
                  icon: const Icon(Icons.send),
                ),
              ),
              // maxLines: 1,
              // minLines: 1,
              //keyboardType: TextInputType.multiline,
              onFieldSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  mqttPublish(message: textEditingController.text);
                  textEditingController.clear();
                }
              },
            ),
          ),
        )
      ],
    );
  }
}

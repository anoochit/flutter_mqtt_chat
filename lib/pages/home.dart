import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mqtt_chat/const.dart';
import 'package:mqtt_chat/utils/mqtt.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Box box;

  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    box = Hive.box('messages');
    //box.clear();
    mqttSubscribe();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MQTT Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            // if offline, show offline message in hive, if online show message in broker
            child: OfflineBuilder(
              connectivityBuilder: (context, value, child) {
                return value == ConnectivityResult.none ? loadOffLineMessage() : child;
              },
              child: loadMessage(),
            ),
          ),
          ChatInputBox(textEditingController: textEditingController)
        ],
      ),
    );
  }

  Widget loadOffLineMessage() {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(4.0),
          color: Colors.red,
          child: const Center(
            child: Text('You are offline'),
          ),
        ),
        Expanded(
          child: loadMessage(),
        ),
      ],
    );
  }

  // show message item from hive
  loadMessage() {
    return ListView(
      reverse: true,
      children: box.values.toList().reversed.map((item) {
        final message = json.decode(item);
        final from = message['from'];
        final content = message['message'];
        return ChatMessageItem(from: from, content: content);
      }).toList(),
    );
  }
}

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

// chat message item widget
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

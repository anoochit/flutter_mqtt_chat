import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mqtt_chat/const.dart';
import 'package:mqtt_chat/utils/mqtt.dart';
import 'package:mqtt_client/mqtt_client.dart';

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
              child: loadOnlineMessage(),
            ),
          ),
          ChatInputBox(textEditingController: textEditingController)
        ],
      ),
    );
  }

  // show message item from broker
  StreamBuilder<List<MqttReceivedMessage<MqttMessage>>> loadOnlineMessage() {
    return StreamBuilder(
      stream: client.updates!,
      builder: (BuildContext context, AsyncSnapshot<List<MqttReceivedMessage<MqttMessage>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final recMess = snapshot.data![0].payload as MqttPublishMessage;
          final pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
          log("message payload => " + pt);

          var box = Hive.box('messages');
          var doc = json.decode(pt);
          // add to hivedb
          var message =
              '{"message" : "${utf8.decode(doc["message"].codeUnits)}", "from" : "${doc["from"]}" ,"timeStamp" : "${doc["timeStamp"]}" }';
          box.put(doc["timeStamp"], message);
          return loadOffLineMessage();
        }

        return Container();
      },
    );
  }

  // show message item from hive
  loadOffLineMessage() {
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

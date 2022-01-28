import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mqtt_chat/utils/mqtt.dart';
import 'package:mqtt_chat/widgets/chat_inputbox.dart';
import 'package:mqtt_chat/widgets/chat_message_item.dart';

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

  Widget loadOnlineMessage() {
    return StreamBuilder(
      stream: box.watch(),
      builder: (BuildContext context, AsyncSnapshot<BoxEvent> snapshot) {
        if (snapshot.hasData) {
          return loadMessage();
        }
        return Container();
      },
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

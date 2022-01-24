import 'dart:convert';

import 'package:flutter/material.dart';
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
            child: StreamBuilder(
              stream: box.watch(),
              builder: (BuildContext context, AsyncSnapshot<BoxEvent> snapshot) {
                if (snapshot.hasData) {
                  return ListView(
                    reverse: true,
                    children: box.values.toList().reversed.map((item) {
                      var message = json.decode(item);
                      return Align(
                        alignment: (message["from"] == userId) ? Alignment.centerRight : Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: (message["from"] == userId)
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
                              color: (message["from"] == userId) ? Colors.blue.shade300 : Colors.grey.shade300,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(message["message"]),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
          const Divider(thickness: 1.0, height: 0.0),
          SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Type your message',
                ),
                onFieldSubmitted: (value) {
                  mqttPublish(message: value);
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}

import 'dart:convert';
import 'dart:developer';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:mqtt_chat/const.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

late MqttServerClient client;

mqttSubscribe() async {
  client = MqttServerClient.withPort(mqttHost, mqttClientId, mqttPort);
  client.keepAlivePeriod = 30;
  client.autoReconnect = true;
  await client.connect().onError((error, stackTrace) {
    log("error -> " + error.toString());
  });

  client.onConnected = () {
    log('MQTT connected');
  };

  client.onDisconnected = () {
    log('MQTT disconnected');
  };

  client.onSubscribed = (String topic) {
    log('MQTT subscribed to $topic');
  };

  if (client.connectionStatus!.state == MqttConnectionState.connected) {
    client.subscribe("chat/#", MqttQos.atMostOnce);

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      log("message payload => " + pt);

      var box = Hive.box('messages');
      var doc = json.decode(utf8.decode(pt.codeUnits));
      // add to hivedb
      var message =
          '{"message" : "${doc["message"]}", "from" : "${doc["from"]}" ,"timeStamp" : "${doc["timeStamp"]}" }';
      box.put(doc["timeStamp"], message);
    });
  }
}

mqttPublish({required String message}) async {
  final builder = MqttClientPayloadBuilder();
  var timeStamp = DateTime.now().microsecondsSinceEpoch.toString();
  var messagsString = '{"message" : "$message", "from" : "$userId" ,"timeStamp" : "$timeStamp" }';
  builder.addUTF8String(messagsString);
  if (client.connectionStatus!.state == MqttConnectionState.connected) {
    client.publishMessage('chat/$timeStamp', MqttQos.exactlyOnce, builder.payload!, retain: true);
  }
}

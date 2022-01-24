const channelId = "28bfbcce-228a-42a0-8344-0720bd606db7";
const mqttHost = "192.168.1.39";
const mqttPort = 1883;
const mqttClientId = "client-bdf08da3x";
const userId = "user1";


/*

mosquitto_pub -h 192.168.1.39 -r  -t "chat" -m '{ "message" : "Hello 4", "from" : "user2" ,"timeStamp" : "1642951673699000" }'
*/
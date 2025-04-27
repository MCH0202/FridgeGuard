import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

// ➊ 新增一个温度记录类
class TempRecord {
  final double value;
  final DateTime time;

  TempRecord(this.value, this.time);
}

class TemperatureProvider extends ChangeNotifier {
  double currentTemp = 5.3;
  List<TempRecord> lastFiveTemps = [];

  final client = MqttServerClient('test.mosquitto.org', '');

  TemperatureProvider() {
    _initializeMQTT();
  }

  void _initializeMQTT() async {
    client.port = 1883;
    client.keepAlivePeriod = 20;
    client.onDisconnected = _onDisconnected;
    client.logging(on: false);

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('flutter_client_${DateTime.now().millisecondsSinceEpoch}')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    client.connectionMessage = connMessage;

    try {
      await client.connect();
    } catch (e) {
      if (kDebugMode) print('MQTT连接失败: $e');
      client.disconnect();
      return;
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      if (kDebugMode) print('✅ MQTT连接成功');

      client.subscribe('/fridgeguard/test/message', MqttQos.atLeastOnce);

      client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final recMess = c[0].payload as MqttPublishMessage;
        final payload =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        if (kDebugMode) print('📩 收到温度: $payload');

        final parsedTemp = double.tryParse(payload.trim());
        if (parsedTemp != null) {
          updateTemperature(parsedTemp);
        }
      });
    } else {
      if (kDebugMode) print('MQTT连接失败: ${client.connectionStatus}');
      client.disconnect();
    }
  }

  void _onDisconnected() {
    if (kDebugMode) print('MQTT已断开');
  }

  void updateTemperature(double newTemp) {
    currentTemp = newTemp;

    // ➔ 记录温度和时间
    lastFiveTemps.add(TempRecord(newTemp, DateTime.now()));
    if (lastFiveTemps.length > 5) {
      lastFiveTemps.removeAt(0);
    }

    notifyListeners(); // 通知 UI 刷新
  }
}

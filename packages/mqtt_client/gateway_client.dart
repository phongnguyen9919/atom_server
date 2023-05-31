// ignore_for_file: depend_on_referenced_packages, avoid_print

import 'dart:convert';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:rxdart/subjects.dart';
import 'package:typed_data/typed_buffers.dart';
import 'package:uuid/uuid.dart';

import '../models/models.dart';

/// {@template gateway_client}
/// The gateway client model that handles MQTT related requests.
/// {@endtemplate}
class GatewayClient {
  /// {@macro gateway_client}
  GatewayClient({
    required this.brokerID,
    required this.url,
    required this.port,
    required this.account,
    required this.password,
    FieldId? id,
    String? clientID,
  })  : assert(
          clientID == null || clientID.isNotEmpty,
          'clientID can not be null and should be empty',
        ),
        assert(
          id == null || id.isNotEmpty,
          'clientID can not be null and should be empty',
        ),
        id = id ?? const Uuid().v4(),
        _clientID = clientID ?? const Uuid().v4() {
    _client = MqttServerClient.withPort(url, _clientID, port)
      ..clientIdentifier = clientID ?? ''
      ..logging(on: false)
      ..keepAlivePeriod = 30
      ..onConnected = onConnected
      ..onDisconnected = onDisconnect
      ..onSubscribed = onSubscribe;

    if (account != null &&
        account!.isNotEmpty &&
        password != null &&
        password!.isNotEmpty) {
      _client.connectionMessage = MqttConnectMessage().startClean();
    } else {
      _client.connectionMessage =
          MqttConnectMessage().withClientIdentifier(_clientID).startClean();
    }
  }

  ///
  final FieldId id;

  ///
  final FieldId brokerID;

  ///
  final String url;

  ///
  final int port;

  ///
  final String? account;

  ///
  final String? password;

  /// The id of client
  final String _clientID;

  /// The Mqtt client instance
  late MqttServerClient _client;

  /// The controller of [Stream] of [ConnectionStatus]
  final _connectionStatusStreamController =
      BehaviorSubject<ConnectionStatus>.seeded(ConnectionStatus.disconnected);

  /// Connects to the broker
  Future<void> connect() async {
    if (!_connectionStatusStreamController.isClosed) {
      _connectionStatusStreamController.add(ConnectionStatus.connecting);
    }
    if (account != null &&
        account!.isNotEmpty &&
        password != null &&
        password!.isNotEmpty) {
      await _client.connect(account, password);
    } else {
      await _client.connect();
    }
  }

  /// Disconnects to broker
  void disconnect() {
    if (!_connectionStatusStreamController.isClosed) {
      _connectionStatusStreamController.add(ConnectionStatus.disconnecting);
    }
    _client.disconnect();
  }

  /// Gets the [Stream] of [ConnectionStatus]
  Stream<ConnectionStatus> getConnectionStatus() =>
      _connectionStatusStreamController.asBroadcastStream();

  /// Close connection status stream
  Future<void> closeConnectionStatusStream() async {
    if (!_connectionStatusStreamController.isClosed) {
      await _connectionStatusStreamController.close();
    }
  }

  /// Subscribes to given topic
  void subscribe({required String topic, required int qos}) {
    late MqttQos mqttQos;
    if (qos == 0) {
      mqttQos = MqttQos.atMostOnce;
    } else if (qos == 1) {
      mqttQos = MqttQos.atLeastOnce;
    } else if (qos == 2) {
      mqttQos = MqttQos.exactlyOnce;
    }
    _client.subscribe(topic, mqttQos);
    // because adafruit not have retain msg system
    // so we must publish topic/get to get retain msg
    if (url == 'io.adafruit.com') {
      published(payload: '', topic: '$topic/get', retain: false, qos: qos);
    }
  }

  /// Unsubscribes to given topic
  void unsubscribe(String topic) {
    _client.unsubscribe(topic);
  }

  /// Publishes message to given topic
  void published({
    required String payload,
    required String topic,
    required bool retain,
    required int qos,
  }) {
    late MqttQos mqttQos;
    if (qos == 0) {
      mqttQos = MqttQos.atMostOnce;
    } else if (qos == 1) {
      mqttQos = MqttQos.atLeastOnce;
    } else if (qos == 2) {
      mqttQos = MqttQos.exactlyOnce;
    }
    final encoded = Uint8Buffer()..addAll(utf8.encode(payload));
    _client.publishMessage(topic, mqttQos, encoded, retain: retain);
    print('::MQTT_CLIENT:: publish $payload to $topic $account $password');
  }

  /// Get a stream of published mes sages of given topics
  Stream<Map<String, String>> getPublishMessage() {
    return _client.published!.map((MqttPublishMessage message) {
      final topic = message.variableHeader!.topicName;
      final payload = utf8.decode(message.payload.message.toList());
      print('::MQTT_CLIENT:: Nhan tin nhan $topic: $payload');
      return {'broker_id': brokerID, 'topic': topic, 'payload': payload};
    });
  }

  /// Connection callback
  void onConnected() {
    print('::MQTT_CLIENT:: $url:$port Ket noi thanh cong...');
    _connectionStatusStreamController.add(ConnectionStatus.connected);
  }

  /// Subscribe callback
  void onSubscribe(dynamic whatever) {
    print(
      '::MQTT_CLIENT:: $url:$port'
      ' Subscribe thanh cong... $whatever',
    );
  }

  /// Disconnect callback
  void onDisconnect() {
    print('::MQTT_CLIENT::  $url:$port Ngat ket noi...');
    if (!_connectionStatusStreamController.isClosed) {
      _connectionStatusStreamController.add(ConnectionStatus.disconnected);
    }
  }
}

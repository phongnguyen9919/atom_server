import '../models/connection_status.dart';
import '../mqtt_client/gateway_client.dart';
import '../onesignal_client/onesignal_client.dart';
import '../supabase_client/supabase_client.dart';

class UserRepository {
  UserRepository({
    required DatabaseClient databaseClient,
    required OnesignalClient onesignalClient,
  })  : _databaseClient = databaseClient,
        _onesignalClient = onesignalClient;

  final DatabaseClient _databaseClient;
  final OnesignalClient _onesignalClient;

  // ================== ONESIGNAL ======================

  Future<void> sendPushNotification(Map<String, dynamic> payload) =>
      _onesignalClient.sendPushNotification(payload: payload);

  // ================== GATEWAY ======================

  /// Creates [GatewayClient]
  GatewayClient createClient({
    required String brokerID,
    required String url,
    required int port,
    required String? account,
    required String? password,
  }) {
    return GatewayClient(
      brokerID: brokerID,
      url: url,
      port: port,
      account: account,
      password: password,
    );
  }

  /// Gets a [Stream] of published msg from given [GatewayClient]
  Stream<Map<String, String>> getPublishMessage(GatewayClient client) {
    return client.getPublishMessage();
  }

  /// Publish payload given [GatewayClient]
  void publishMessage(
    GatewayClient client, {
    required String payload,
    required String topic,
    required int qos,
    bool retain = true,
  }) {
    client.published(payload: payload, topic: topic, retain: retain, qos: qos);
  }

  /// Gets a [Stream] of [ConnectionStatus] from given [GatewayClient]
  Stream<ConnectionStatus> getConnectionStatus(GatewayClient client) {
    return client.getConnectionStatus();
  }

  /// Close connection status stream
  Future<void> closeConnectionStatusStream(GatewayClient client) async =>
      client.closeConnectionStatusStream();

  // ===================================

  Future<List<dynamic>> getMembers(String domain) =>
      _databaseClient.getMembers(domain);

  Stream<dynamic> domain() => _databaseClient.domain();

  Stream<dynamic> broker(String domain) => _databaseClient.broker(domain);

  Stream<dynamic> device(String domain) => _databaseClient.device(domain);

  Stream<dynamic> alert(String domain) => _databaseClient.alert(domain);

  Future<void> saveRecord({
    required String domain,
    required String deviceId,
    required DateTime time,
    required String value,
    String? id,
  }) async =>
      _databaseClient.saveRecord(
        domain: domain,
        deviceId: deviceId,
        time: time,
        value: value,
        id: id,
      );

  Future<void> saveAlertRecord({
    required String domain,
    required String alertId,
    required DateTime time,
    required String value,
    String? id,
  }) async =>
      _databaseClient.saveAlertRecord(
        domain: domain,
        alertId: alertId,
        time: time,
        value: value,
        id: id,
      );
}

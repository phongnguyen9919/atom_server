import 'dart:convert';
import 'package:http/http.dart' as http;

class OnesignalClient {
  OnesignalClient({
    required http.Client httpClient,
    required this.onesignalKey,
    required this.appId,
  }) : _httpClient = httpClient;

  final http.Client _httpClient;
  final String onesignalKey;
  final String appId;

  Future<void> sendPushNotification({
    required Map<String, dynamic> payload,
  }) async {
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Basic $onesignalKey',
      'Content-Type': 'application/json'
    };
    final msg = Map<String, dynamic>.from(payload);
    msg['app_id'] = appId;
    await _httpClient.post(
      Uri.https('onesignal.com', 'api/v1/notifications'),
      headers: headers,
      body: jsonEncode(msg),
    );
  }
}

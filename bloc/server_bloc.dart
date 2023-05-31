import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:rfc_6901/rfc_6901.dart';

import '../middleware/provider.dart';
import '../packages/models/models.dart';
import '../packages/mqtt_client/gateway_client.dart';
import '../packages/user_repository/user_repository.dart';

part 'server_event.dart';
part 'server_state.dart';

class ServerBloc extends Bloc<ServerEvent, ServerState> {
  ServerBloc(this._userRepository) : super(const ServerState()) {
    on<Started>(_onStarted);
    on<GatewayStatusSubscriptionRequested>(
      _onGatewayStatusSubscribed,
      transformer: concurrent(),
    );
    on<GatewayStatusCloseSubscriptionRequested>(
      _onGatewayStatusCloseSubscribed,
      transformer: concurrent(),
    );
    on<BrokerConnectionRequested>(
      _onBrokerConnected,
      transformer: concurrent(),
    );
    on<GatewayListenRequested>(
      _onGatewayListened,
      transformer: concurrent(),
    );

    on<PushNotificationRequested>(
      _onPushNotificationRequested,
      transformer: concurrent(),
    );
    on<DomainChanged>(_onDomainChanged);
    on<BrokerChanged>(_onBrokerChanged);
    on<DeviceChanged>(_onDeviceChanged);
    on<AlertChanged>(_onAlertChanged);
    on<GatewayClientViewChanged>(_onGatewayClientViewChanged);
    on<BrokerTopicPayloadsChanged>(_onBrokerTopicPayloadsChanged);
  }

  final UserRepository _userRepository;
  StreamSubscription<dynamic>? _domainSubsription;
  late final Map<String, StreamSubscription<dynamic>> _brokerSubsriptionMap;
  late final Map<String, StreamSubscription<dynamic>> _deviceSubsriptionMap;
  late final Map<String, StreamSubscription<dynamic>> _alertSubsriptionMap;

  Future<void> _onPushNotificationRequested(
    PushNotificationRequested event,
    Emitter<ServerState> emit,
  ) async {
    final members = await userRepository.getMembers(event.domain);
    final payload = Map<String, dynamic>.from(event.payload);
    payload['include_external_user_ids'] = members
        .map((e) => (e as Map<String, dynamic>)['id'] as String)
        .toList();
    await userRepository.sendPushNotification(payload);
  }

  @override
  Future<void> close() {
    _domainSubsription?.cancel();
    for (final sub in _brokerSubsriptionMap.values) {
      sub.cancel();
    }
    for (final sub in _deviceSubsriptionMap.values) {
      sub.cancel();
    }
    for (final sub in _alertSubsriptionMap.values) {
      sub.cancel();
    }
    return super.close();
  }

  void _onStarted(Started event, Emitter<ServerState> emit) {
    _domainSubsription = _userRepository.domain().listen((data) {
      final domainNames = (data as List<dynamic>)
          .map((e) => (e as Map<String, dynamic>)['name'] as String)
          .toList();
      handleDomainChange(domainNames, state);
    });

    _brokerSubsriptionMap = {};
    _deviceSubsriptionMap = {};
    _alertSubsriptionMap = {};

    emit(state.copyWith(status: ServerStatus.normal));
  }

  void handleDomainChange(List<String> domainNames, ServerState state) {
    add(DomainChanged(domainNames: domainNames));
    // hanlde new domain
    final newDomainNames = domainNames.where(
      (domain) => !state.domainNames.contains(domain),
    );
    for (final domain in newDomainNames) {
      // create broker, device, alert subscription
      if (!_brokerSubsriptionMap.keys.contains(domain)) {
        _brokerSubsriptionMap[domain] =
            _userRepository.broker(domain).listen((data) {
          final brokers = (data as List<dynamic>)
              .map((e) => Broker.fromJson(e as Map<String, dynamic>))
              .toList();
          handleBrokerChange(domain, brokers, state);
        });
      }

      if (!_deviceSubsriptionMap.keys.contains(domain)) {
        _deviceSubsriptionMap[domain] =
            _userRepository.device(domain).listen((data) {
          final devices = (data as List<dynamic>)
              .map((e) => Device.fromJson(e as Map<String, dynamic>))
              .toList();
          handleDeviceChange(domain, devices, state);
        });
      }
      if (!_alertSubsriptionMap.keys.contains(domain)) {
        add(AlertChanged(domainName: domain, alerts: const []));
        _alertSubsriptionMap[domain] =
            _userRepository.alert(domain).listen((data) {
          final alerts = (data as List<dynamic>)
              .map((e) => Alert.fromJson(e as Map<String, dynamic>))
              .toList();
          add(AlertChanged(domainName: domain, alerts: alerts));
        });
      }
    }
    // TODO(me): handle deleted domain
    // final deletedDomains =
    //     state.domainNames.where((domain) => !domainNames.contains(domain));
    // for (final domain in deletedDomains) {
    //   // close broker, device, alert subscription
    // }
  }

  void handleBrokerChange(
    String domainName,
    List<Broker> brokers,
    ServerState state,
  ) {
    final brokerView = {for (final br in brokers) br.id: br};

    final gatewayClientView =
        Map<FieldId, GatewayClient>.from(state.gatewayClientView);
    final brokerTopicPayloads =
        Map<FieldId, Map<String, String?>>.from(state.brokerTopicPayloads);

    final brokerMap = Map<String, List<Broker>>.from(state.brokerMap);
    if (!brokerMap.containsKey(domainName)) {
      brokerMap[domainName] = [];
    }
    final stateBrokerView = <FieldId, Broker>{
      for (final br in brokerMap[domainName]!) br.id: br
    };

    // hanlde new broker
    final newBrokers = brokers.where(
      (br) => !stateBrokerView.keys.contains(br.id),
    );
    for (final br in newBrokers) {
      // create new gateway client
      final gatewayClient = _userRepository.createClient(
        brokerID: br.id,
        url: br.url,
        port: br.port,
        account: br.account,
        password: br.password,
      );
      gatewayClientView[br.id] = gatewayClient;
      brokerTopicPayloads[br.id] = <String, String?>{};
      add(GatewayStatusSubscriptionRequested(gatewayClient, domainName));
      add(BrokerConnectionRequested(gatewayClient, domainName));
    }
    // handle edited brokers
    final editedBrokers = brokers.where(
      (br) =>
          stateBrokerView.keys.contains(br.id) &&
          stateBrokerView[br.id] != brokerView[br.id],
    );
    for (final br in editedBrokers) {
      // only restart gateway client when either
      // url, port, account, password has changed
      if (stateBrokerView[br.id]!.url != brokerView[br.id]!.url ||
          stateBrokerView[br.id]!.port != brokerView[br.id]!.port ||
          stateBrokerView[br.id]!.account != brokerView[br.id]!.account ||
          stateBrokerView[br.id]!.password != brokerView[br.id]!.password) {
        // disconnect old gwCl
        final oldGatewayClient = gatewayClientView[br.id];
        if (oldGatewayClient != null) {
          oldGatewayClient.disconnect();
        }
        // create new gateway client
        final gatewayClient = _userRepository.createClient(
          brokerID: br.id,
          url: br.url,
          port: br.port,
          account: br.account,
          password: br.password,
        );
        gatewayClientView[br.id] = gatewayClient;
        add(GatewayStatusSubscriptionRequested(gatewayClient, domainName));
        add(BrokerConnectionRequested(gatewayClient, domainName));
      }
    }
    // handle deleted brokers
    final deletedBrokers =
        brokerMap[domainName]!.where((br) => !brokerView.keys.contains(br.id));
    for (final br in deletedBrokers) {
      // close its status stream
      final gatewayClient = gatewayClientView[br.id];
      if (gatewayClient != null) {
        add(GatewayStatusCloseSubscriptionRequested(gatewayClient));
        // remove it from brTpPl
        brokerTopicPayloads.remove(br.id);
        // disconnect old gwCl
        gatewayClient.disconnect();
      }
      // remove it from gwClView
      gatewayClientView.remove(br.id);
    }
    add(BrokerChanged(domainName: domainName, brokers: brokers));
    add(GatewayClientViewChanged(gatewayClientView: gatewayClientView));
    add(BrokerTopicPayloadsChanged(brokerTopicPayloads: brokerTopicPayloads));
  }

  void handleDeviceChange(
    String domainName,
    List<Device> devices,
    ServerState state,
  ) {
    final deviceView = {for (final dv in devices) dv.id: dv};
    // clone
    final brokerTopicPayloads =
        Map<FieldId, Map<String, String?>>.from(state.brokerTopicPayloads);

    final deviceMap = Map<String, List<Device>>.from(state.deviceMap);
    if (!deviceMap.containsKey(domainName)) {
      deviceMap[domainName] = [];
    }

    final stateDeviceView = <FieldId, Device>{
      for (final dv in deviceMap[domainName]!) dv.id: dv
    };

    // handle new device
    final newDevices = devices.where(
      (dv) => !stateDeviceView.keys.contains(dv.id),
    );
    for (final dv in newDevices) {
      if (brokerTopicPayloads.containsKey(dv.brokerID)) {
        final brokerTopic = brokerTopicPayloads[dv.brokerID]!;
        if (!brokerTopic.containsKey(dv.topic)) {
          brokerTopic[dv.topic] = null;
          final brokerStatus = state.brokerStatusView[dv.brokerID];
          final gatewayClient = state.gatewayClientView[dv.brokerID];
          if (gatewayClient != null &&
              brokerStatus != null &&
              brokerStatus.isConnected) {
            gatewayClient.subscribe(topic: dv.topic, qos: dv.qos);
          }
          brokerTopicPayloads[dv.brokerID] = brokerTopic;
        }
      }
    }
    // handle edited devices
    final editedDevices = devices.where(
      (dv) =>
          stateDeviceView.keys.contains(dv.id) &&
          stateDeviceView[dv.id] != deviceView[dv.id],
    );
    for (final dv in editedDevices) {
      final oldDevice = stateDeviceView[dv.id]!;
      // only handle when device changed broker or topic

      if (oldDevice.brokerID != dv.brokerID || oldDevice.topic != dv.topic) {
        // delete old topic from old brokerTopic
        if (brokerTopicPayloads.containsKey(oldDevice.brokerID)) {
          final oldBrokerTopic = brokerTopicPayloads[oldDevice.brokerID]!;
          if (oldBrokerTopic.containsKey(oldDevice.topic)) {
            oldBrokerTopic.remove(oldDevice.topic);
            final brokerStatus = state.brokerStatusView[oldDevice.brokerID];
            final oldGatewayClient =
                state.gatewayClientView[oldDevice.brokerID];
            if (oldGatewayClient != null &&
                brokerStatus != null &&
                brokerStatus.isConnected) {
              // unsubscribe old topic
              oldGatewayClient.unsubscribe(oldDevice.topic);
            }
            brokerTopicPayloads[oldDevice.brokerID] = oldBrokerTopic;
          }
        }
        // add new topic to brokerTopic
        if (brokerTopicPayloads.containsKey(oldDevice.brokerID)) {
          final newBrokerTopic = brokerTopicPayloads[dv.brokerID]!;
          if (!newBrokerTopic.containsKey(dv.topic)) {
            newBrokerTopic[dv.topic] = null;
            final brokerStatus = state.brokerStatusView[dv.brokerID];
            final gatewayClient = state.gatewayClientView[dv.brokerID];
            if (gatewayClient != null &&
                brokerStatus != null &&
                brokerStatus.isConnected) {
              gatewayClient.subscribe(topic: dv.topic, qos: dv.qos);
            }
            brokerTopicPayloads[dv.brokerID] = newBrokerTopic;
          }
        }
      }
    }
    // handle deleted devices
    final deleteDevices =
        deviceMap[domainName]!.where((dv) => !deviceView.keys.contains(dv.id));
    for (final dv in deleteDevices) {
      if (brokerTopicPayloads.containsKey(dv.brokerID)) {
        final brokerTopic = brokerTopicPayloads[dv.brokerID]!;
        if (brokerTopic.containsKey(dv.topic)) {
          brokerTopic.remove(dv.topic);
          final brokerStatus = state.brokerStatusView[dv.brokerID];
          final gatewayClient = state.gatewayClientView[dv.brokerID];
          if (gatewayClient != null &&
              brokerStatus != null &&
              brokerStatus.isConnected) {
            // unsubscribe old topic
            gatewayClient.unsubscribe(dv.topic);
          }
          brokerTopicPayloads[dv.brokerID] = brokerTopic;
        }
      }
    }

    add(DeviceChanged(domainName: domainName, devices: devices));
    add(BrokerTopicPayloadsChanged(brokerTopicPayloads: brokerTopicPayloads));
  }

  Future<void> _onGatewayStatusSubscribed(
    GatewayStatusSubscriptionRequested event,
    Emitter<ServerState> emit,
  ) async {
    await emit.forEach<ConnectionStatus>(
      _userRepository.getConnectionStatus(event.gatewayClient),
      onData: (status) {
        final brokerStatusView =
            Map<FieldId, ConnectionStatus>.from(state.brokerStatusView);
        brokerStatusView[event.gatewayClient.brokerID] = status;
        if (status.isDisconnected) {
          final gwClExist =
              state.gatewayClientView.containsKey(event.gatewayClient.brokerID);
          final brTopicExist = state.brokerTopicPayloads
              .containsKey(event.gatewayClient.brokerID);
          final brStExist =
              state.brokerStatusView.containsKey(event.gatewayClient.brokerID);
          // if it disconnected because mqtt broker error
          if (gwClExist && brTopicExist && brStExist) {
            add(
              BrokerConnectionRequested(
                event.gatewayClient,
                event.domainName,
              ),
            );
          }
        }
        return state.copyWith(brokerStatusView: brokerStatusView);
      },
    );
  }

  Future<void> _onGatewayStatusCloseSubscribed(
    GatewayStatusCloseSubscriptionRequested event,
    Emitter<ServerState> emit,
  ) async {
    await _userRepository.closeConnectionStatusStream(event.gatewayClient);
    final brokerStatusView =
        Map<FieldId, ConnectionStatus>.from(state.brokerStatusView)
          ..remove(event.gatewayClient.brokerID);
    emit(state.copyWith(brokerStatusView: brokerStatusView));
  }

  Future<void> _onBrokerConnected(
    BrokerConnectionRequested event,
    Emitter<ServerState> emit,
  ) async {
    try {
      await event.gatewayClient.connect();
      // clone and update brokerTopicPayloads
      final brokerTopicPayloads =
          Map<FieldId, Map<String, String?>>.from(state.brokerTopicPayloads);
      final brokerTopic = brokerTopicPayloads[event.gatewayClient.brokerID] ??
          <String, String?>{};
      for (final dv in state.deviceMap[event.domainName]!) {
        if (dv.brokerID == event.gatewayClient.brokerID) {
          event.gatewayClient.subscribe(topic: dv.topic, qos: dv.qos);
          brokerTopic[dv.topic] = null;
        }
      }
      brokerTopicPayloads[event.gatewayClient.brokerID] = brokerTopic;
      add(GatewayListenRequested(event.gatewayClient, event.domainName));
      emit(state.copyWith(brokerTopicPayloads: brokerTopicPayloads));
    } catch (e) {
      Future.delayed(
        const Duration(seconds: 6),
        () => add(
          BrokerConnectionRequested(event.gatewayClient, event.domainName),
        ),
      );
    }
  }

  Future<void> _onGatewayListened(
    GatewayListenRequested event,
    Emitter<ServerState> emit,
  ) async {
    await emit.forEach<Map<String, String>>(
      event.gatewayClient.getPublishMessage(),
      onData: (message) {
        final brokerID = message['broker_id']!;
        final topic = message['topic']!;
        final payload = message['payload']!;
        // clone
        final brokerTopicPayloads =
            Map<FieldId, Map<String, String?>>.from(state.brokerTopicPayloads);
        final brokerTopic = brokerTopicPayloads[event.gatewayClient.brokerID] ??
            <String, String?>{};
        // update brokerTopicPayloads
        brokerTopic[topic] = payload;
        brokerTopicPayloads[brokerID] = brokerTopic;

        // scan alert
        for (final alert in state.alertMap[event.domainName]!) {
          final dv = state.deviceMap[event.domainName]!
              .firstWhere((element) => element.id == alert.deviceID);
          // update tile value view if device's broker and topic match
          // with payload's broker and topic
          if (dv.brokerID == brokerID && dv.topic == topic) {
            bool? lcompare;
            bool? rcompare;
            late var activeValue = payload;
            if (dv.jsonPath != '') {
              final value = readJson(
                expression: dv.jsonPath,
                payload: payload,
              );
              if (value != '?' && double.tryParse(value) != null) {
                activeValue = value;
                lcompare = double.parse(value) < double.parse(alert.lvalue);
                rcompare = double.parse(value) > double.parse(alert.rvalue);
              }
            } else {
              lcompare = double.parse(payload) < double.parse(alert.lvalue);
              rcompare = double.parse(payload) > double.parse(alert.rvalue);
            }
            if (lcompare != null && rcompare != null) {
              // AND
              if (alert.relate && lcompare && rcompare) {
                _userRepository.saveAlertRecord(
                  domain: event.domainName,
                  alertId: alert.id,
                  time: DateTime.now(),
                  value: activeValue,
                );
                final payload = {
                  'headings': {'en': 'Alert ${alert.name} has actived'},
                  'en': 'Alert ${alert.name} has actived with'
                      ' value $activeValue'
                };
                add(
                  PushNotificationRequested(
                    domain: event.domainName,
                    payload: payload,
                  ),
                );
              }
              // OR
              else if (!alert.relate && (lcompare || rcompare)) {
                _userRepository.saveAlertRecord(
                  domain: event.domainName,
                  alertId: alert.id,
                  time: DateTime.now(),
                  value: activeValue,
                );
                final payload = {
                  'headings': {'en': 'Alert ${alert.name} has actived'},
                  'contents': {
                    'en': 'Alert ${alert.name} has actived with'
                        ' value $activeValue'
                  },
                };
                add(
                  PushNotificationRequested(
                    domain: event.domainName,
                    payload: payload,
                  ),
                );
              }
            }
          }
        }

        // scan device
        for (final dv in state.deviceMap[event.domainName]!) {
          if (dv.brokerID == brokerID && dv.topic == topic) {
            if (dv.jsonPath != '') {
              final value = readJson(
                expression: dv.jsonPath,
                payload: payload,
              );
              if (value == '?') {
                _userRepository.saveRecord(
                  domain: event.domainName,
                  deviceId: dv.id,
                  time: DateTime.now(),
                  value: payload,
                );
              } else {
                _userRepository.saveRecord(
                  domain: event.domainName,
                  deviceId: dv.id,
                  time: DateTime.now(),
                  value: value,
                );
              }
            } else {
              _userRepository.saveRecord(
                domain: event.domainName,
                deviceId: dv.id,
                time: DateTime.now(),
                value: payload,
              );
            }
          }
        }

        return state.copyWith(
          brokerTopicPayloads: brokerTopicPayloads,
        );
      },
    );
  }

  void _onDomainChanged(DomainChanged event, Emitter<ServerState> emit) {
    emit(state.copyWith(domainNames: event.domainNames));
  }

  void _onBrokerChanged(BrokerChanged event, Emitter<ServerState> emit) {
    final brokerMap = Map<String, List<Broker>>.from(state.brokerMap);
    brokerMap[event.domainName] = event.brokers;
    emit(state.copyWith(brokerMap: brokerMap));
  }

  void _onDeviceChanged(DeviceChanged event, Emitter<ServerState> emit) {
    final deviceMap = Map<String, List<Device>>.from(state.deviceMap);
    deviceMap[event.domainName] = event.devices;
    emit(state.copyWith(deviceMap: deviceMap));
  }

  void _onAlertChanged(AlertChanged event, Emitter<ServerState> emit) {
    final alertMap = Map<String, List<Alert>>.from(state.alertMap);
    alertMap[event.domainName] = event.alerts;
    emit(state.copyWith(alertMap: alertMap));
  }

  void _onGatewayClientViewChanged(
    GatewayClientViewChanged event,
    Emitter<ServerState> emit,
  ) {
    emit(state.copyWith(gatewayClientView: event.gatewayClientView));
  }

  void _onBrokerTopicPayloadsChanged(
    BrokerTopicPayloadsChanged event,
    Emitter<ServerState> emit,
  ) {
    emit(state.copyWith(brokerTopicPayloads: event.brokerTopicPayloads));
  }

  /// get value in json by expression
  String readJson({required String expression, required String payload}) {
    try {
      final decoded = jsonDecode(payload);
      final pointer = JsonPointer(expression);
      final value = pointer.read(decoded);
      if (value == null) {
        return '?';
      }
      switch (value.runtimeType) {
        case String:
          return value as String;
        default:
          return value.toString();
      }
    } catch (e) {
      return '?';
    }
  }

  /// write value to json by expression
  String writeJson({required String expression, required String value}) {
    try {
      if (expression == '') {
        return value;
      } else {
        final pointer = JsonPointer(expression);
        final payload = pointer.write({}, value);
        return jsonEncode(payload);
      }
    } catch (e) {
      throw Exception();
    }
  }
}

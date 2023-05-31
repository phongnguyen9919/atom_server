part of 'server_bloc.dart';

enum ServerStatus {
  normal,
  waiting,
  success,
  failure,
}

extension ServerStatusX on ServerStatus {
  bool isWaiting() => this == ServerStatus.waiting;
  bool isSuccess() => this == ServerStatus.success;
  bool isFailure() => this == ServerStatus.failure;
}

class ServerState extends Equatable {
  const ServerState({
    this.status = ServerStatus.waiting,
    this.domainNames = const [],
    this.brokerMap = const {},
    this.deviceMap = const {},
    this.alertMap = const {},
    this.gatewayClientView = const {},
    this.brokerTopicPayloads = const {},
    this.brokerStatusView = const {},
  });

  // mutable
  final List<String> domainNames;
  final Map<String, List<Broker>> brokerMap;
  final Map<String, List<Device>> deviceMap;
  final Map<String, List<Alert>> alertMap;

  final ServerStatus status;

  /// <BrokerID, GatewayClient>
  final Map<FieldId, ConnectionStatus> brokerStatusView;

  /// <BrokerID, GatewayClient>
  final Map<FieldId, GatewayClient> gatewayClientView;

  /// <BrokerID, <Topic, Payload>>
  final Map<FieldId, Map<String, String?>> brokerTopicPayloads;

  @override
  List<Object?> get props => [
        status,
        domainNames,
        brokerMap,
        deviceMap,
        alertMap,
        brokerStatusView,
        gatewayClientView,
        brokerTopicPayloads,
      ];

  ServerState copyWith({
    ServerStatus? status,
    List<String>? domainNames,
    Map<String, List<Broker>>? brokerMap,
    Map<String, List<Device>>? deviceMap,
    Map<String, List<Alert>>? alertMap,
    Map<FieldId, GatewayClient>? gatewayClientView,
    Map<FieldId, Map<String, String?>>? brokerTopicPayloads,
    Map<FieldId, ConnectionStatus>? brokerStatusView,
  }) {
    return ServerState(
      status: status ?? this.status,
      domainNames: domainNames ?? this.domainNames,
      brokerMap: brokerMap ?? this.brokerMap,
      deviceMap: deviceMap ?? this.deviceMap,
      alertMap: alertMap ?? this.alertMap,
      gatewayClientView: gatewayClientView ?? this.gatewayClientView,
      brokerTopicPayloads: brokerTopicPayloads ?? this.brokerTopicPayloads,
      brokerStatusView: brokerStatusView ?? this.brokerStatusView,
    );
  }
}

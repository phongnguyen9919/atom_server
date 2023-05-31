part of 'server_bloc.dart';

abstract class ServerEvent extends Equatable {
  const ServerEvent();

  @override
  List<Object?> get props => [];
}

class Started extends ServerEvent {
  const Started();

  @override
  List<Object> get props => [];
}

class BrokerConnectionRequested extends ServerEvent {
  const BrokerConnectionRequested(this.gatewayClient, this.domainName);

  final String domainName;
  final GatewayClient gatewayClient;

  @override
  List<Object?> get props => [domainName, gatewayClient];
}

class GatewayStatusSubscriptionRequested extends ServerEvent {
  const GatewayStatusSubscriptionRequested(this.gatewayClient, this.domainName);

  final String domainName;
  final GatewayClient gatewayClient;

  @override
  List<Object?> get props => [gatewayClient, domainName];
}

class GatewayStatusCloseSubscriptionRequested extends ServerEvent {
  const GatewayStatusCloseSubscriptionRequested(this.gatewayClient);

  final GatewayClient gatewayClient;

  @override
  List<Object?> get props => [gatewayClient];
}

class GatewayListenRequested extends ServerEvent {
  const GatewayListenRequested(this.gatewayClient, this.domainName);

  final String domainName;
  final GatewayClient gatewayClient;

  @override
  List<Object?> get props => [gatewayClient, domainName];
}

class DomainChanged extends ServerEvent {
  const DomainChanged({required this.domainNames});

  final List<String> domainNames;

  @override
  List<Object> get props => [domainNames];
}

class BrokerChanged extends ServerEvent {
  const BrokerChanged({required this.domainName, required this.brokers});

  final String domainName;
  final List<Broker> brokers;

  @override
  List<Object> get props => [domainName, brokers];
}

class DeviceChanged extends ServerEvent {
  const DeviceChanged({required this.domainName, required this.devices});

  final String domainName;
  final List<Device> devices;

  @override
  List<Object> get props => [domainName, devices];
}

class AlertChanged extends ServerEvent {
  const AlertChanged({required this.domainName, required this.alerts});

  final String domainName;
  final List<Alert> alerts;

  @override
  List<Object> get props => [domainName, alerts];
}

class GatewayClientViewChanged extends ServerEvent {
  const GatewayClientViewChanged({required this.gatewayClientView});

  final Map<FieldId, GatewayClient> gatewayClientView;

  @override
  List<Object> get props => [gatewayClientView];
}

class BrokerTopicPayloadsChanged extends ServerEvent {
  const BrokerTopicPayloadsChanged({required this.brokerTopicPayloads});

  final Map<FieldId, Map<String, String?>> brokerTopicPayloads;

  @override
  List<Object> get props => [brokerTopicPayloads];
}

class PushNotificationRequested extends ServerEvent {
  const PushNotificationRequested({
    required this.domain,
    required this.payload,
  });

  final String domain;
  final Map<String, dynamic> payload;

  @override
  List<Object?> get props => [domain, payload];
}

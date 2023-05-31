import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';

import '../bloc/server_bloc.dart';

Future<Response> onRequest(RequestContext context) async {
  final bloc = context.read<ServerBloc>();

  return Response(
    body: jsonEncode({
      'domain': bloc.state.domainNames,
      'brokerMap': bloc.state.brokerMap,
      'deviceMap': bloc.state.deviceMap,
      'alertMap': bloc.state.alertMap,
    }),
  );
}

import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';

import '../bloc/server_bloc.dart';

Future<Response> onRequest(RequestContext context) async {
  context.read<ServerBloc>().add(const Started());

  return Response(
    body: jsonEncode({
      'status': 'success',
    }),
  );
}

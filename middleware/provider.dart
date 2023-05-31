// ignore_for_file: lines_longer_than_80_chars

import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;

import '../bloc/server_bloc.dart';
import '../packages/onesignal_client/onesignal_client.dart';
import '../packages/supabase_client/supabase_client.dart';
import '../packages/user_repository/user_repository.dart';

const url = 'https://wxewqtcnxxcrtiruydky.supabase.co';
const key =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind4ZXdxdGNueHhjcnRpcnV5ZGt5Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTY4MzIwMTUzMywiZXhwIjoxOTk4Nzc3NTMzfQ.RHmLq5dWkPSLnC5O7FZ-xcF1Y14mmX5qjCj2j4NBHic';
final databaseClient = DatabaseClient(url: url, key: key);

const onesignalKey = 'OWMzNTJlM2ItYTkzYS00NjljLTgzZmMtNWZhMzYxNWQ5Y2Jh';
const appId = '91c3fd9f-b02c-4b09-a1ae-eeb36769841b';
final onesignalClient = OnesignalClient(
  httpClient: http.Client(),
  onesignalKey: onesignalKey,
  appId: appId,
);

final userRepository = UserRepository(
  databaseClient: databaseClient,
  onesignalClient: onesignalClient,
);

final _serverBloc = ServerBloc(userRepository);
final serverProvider = provider<ServerBloc>((_) => _serverBloc);

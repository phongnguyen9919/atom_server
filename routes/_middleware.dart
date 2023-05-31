import 'package:dart_frog/dart_frog.dart';

import '../middleware/provider.dart';

Handler middleware(Handler handler) =>
    handler.use(serverProvider).use(requestLogger());

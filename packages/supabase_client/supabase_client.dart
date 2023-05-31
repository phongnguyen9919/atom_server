// ignore_for_file: inference_failure_on_function_invocation, avoid_print

import 'dart:developer';

import 'package:supabase/supabase.dart';

class DatabaseClient {
  DatabaseClient({required this.url, required this.key});

  final String url;
  final String key;

  /// check and create domain client
  Future<void> signup({
    required String domain,
    required String username,
    required String password,
  }) async {
    final supabaseClient = SupabaseClient(url, key);
    final resGetDomains =
        await supabaseClient.from('domain').select('name') as List<dynamic>;
    final allDomains =
        resGetDomains.map((ele) => (ele as Map<String, dynamic>)['name']);

    try {
      if (allDomains.contains(domain)) {
        throw Exception('This domain name has been used!');
      }
    } catch (e) {
      rethrow;
    }

    try {
      await supabaseClient.rpc('create_schema', params: {'s_name': domain});
      await supabaseClient.rpc(
        'expose_schema',
        params: {
          'schemas': ['public', 'storage', ...allDomains, domain].join(', ')
        },
      );

      await supabaseClient.from('domain').insert({'name': domain});

      await supabaseClient.rpc('create_member', params: {'s_name': domain});
      await supabaseClient.rpc('create_broker', params: {'s_name': domain});
      await supabaseClient.rpc('create_dashboard', params: {'s_name': domain});
      await supabaseClient.rpc('create_group', params: {'s_name': domain});
      await supabaseClient.rpc('create_device', params: {'s_name': domain});
      await supabaseClient.rpc('create_tile', params: {'s_name': domain});
      await supabaseClient.rpc('create_alert', params: {'s_name': domain});
      await supabaseClient
          .rpc('create_alert_record', params: {'s_name': domain});
      await supabaseClient.rpc('create_record', params: {'s_name': domain});

      final domainClient = createSupabaseClient(domain);
      await domainClient.from('member').insert(
        {'username': username, 'password': password, 'is_admin': true},
      );
    } catch (e) {
      log(e.toString());
      throw Exception('Something has been wrong!');
    }
  }

  Future<Map<String, dynamic>> login({
    required String domain,
    required String username,
    required String password,
  }) async {
    try {
      final domainClient = await getSupabaseClient(domain);
      final res = await domainClient
          .from('member')
          .select('is_admin')
          .eq('username', username)
          .eq('password', password)
          .single();
      return res as Map<String, dynamic>;
    } catch (e) {
      log(e.toString());
      throw Exception('Usename or password is not correct');
    }
  }

  Future<SupabaseClient> getSupabaseClient(String domain) async {
    final supabaseClient = SupabaseClient(url, key);
    final resGetDomains =
        await supabaseClient.from('domain').select('name') as List<dynamic>;
    final allDomains =
        resGetDomains.map((ele) => (ele as Map<String, dynamic>)['name']);

    try {
      if (!allDomains.contains(domain)) {
        throw Exception('This domain name not exist!');
      }
    } catch (e) {
      rethrow;
    }
    return createSupabaseClient(domain);
  }

  SupabaseClient createSupabaseClient(String schema) {
    return SupabaseClient(url, key, schema: schema);
  }

  Stream<dynamic> member(String domain) {
    final domainClient = createSupabaseClient(domain);
    return domainClient.from('member').stream(primaryKey: ['id']);
  }

  Future<List<dynamic>> getMembers(String domain) async {
    try {
      final domainClient = await getSupabaseClient(domain);
      final res = await domainClient.from('member').select();
      return res as List<dynamic>;
    } catch (e) {
      log(e.toString());
      throw Exception('Something has been wrong!');
    }
  }

  Stream<dynamic> domain() {
    final supabaseClient = SupabaseClient(url, key);
    return supabaseClient.from('domain').stream(primaryKey: ['name']);
  }

  Stream<dynamic> broker(String domain) {
    final domainClient = createSupabaseClient(domain);
    return domainClient.from('broker').stream(primaryKey: ['id']);
  }

  Future<List<dynamic>> getBrokers({required String domain}) async {
    try {
      final domainClient = await getSupabaseClient(domain);
      final res = await domainClient
          .from('broker')
          .select('id, name, url, port, account, password');
      return res as List<dynamic>;
    } catch (e) {
      log(e.toString());
      throw Exception('Something has been wrong!');
    }
  }

  Future<void> saveBroker({
    required String domain,
    required String name,
    required String url,
    required int port,
    required String? account,
    required String? password,
    String? id,
  }) async {
    try {
      final domainClient = await getSupabaseClient(domain);
      if (id != null) {
        await domainClient.from('broker').update({
          'name': name,
          'url': url,
          'port': port,
          'account': account,
          'password': password,
        }).match({'id': id});
      } else {
        await domainClient.from('broker').insert({
          'name': name,
          'url': url,
          'port': port,
          'account': account,
          'password': password,
        });
      }
    } catch (e) {
      log(e.toString());
      throw Exception('Something has been wrong!');
    }
  }

  Future<void> deleteBroker({
    required String domain,
    required String id,
  }) async {
    try {
      final domainClient = await getSupabaseClient(domain);
      await domainClient.from('broker').delete().match({'id': id});
    } catch (e) {
      log(e.toString());
      throw Exception('Something has been wrong!');
    }
  }

  Stream<dynamic> group(String domain) {
    final domainClient = createSupabaseClient(domain);
    return domainClient.from('group').stream(primaryKey: ['id']);
  }

  Future<void> saveGroup({
    required String domain,
    required String name,
    required String? parentId,
    required String? id,
  }) async {
    try {
      final domainClient = await getSupabaseClient(domain);
      if (id != null) {
        await domainClient
            .from('group')
            .update({'name': name}).match({'id': id});
      } else {
        await domainClient
            .from('group')
            .insert({'name': name, 'group_id': parentId});
      }
    } catch (e) {
      log(e.toString());
      throw Exception('Something has been wrong!');
    }
  }

  Future<void> deleteGroup({
    required String domain,
    required String id,
  }) async {
    try {
      final domainClient = await getSupabaseClient(domain);
      await domainClient.from('group').delete().match({'id': id});
    } catch (e) {
      log(e.toString());
      throw Exception('Something has been wrong!');
    }
  }

  Stream<dynamic> device(String domain) {
    final domainClient = createSupabaseClient(domain);
    return domainClient.from('device').stream(primaryKey: ['id']);
  }

  Future<List<dynamic>> getDevices({required String domain}) async {
    try {
      final domainClient = await getSupabaseClient(domain);
      final res = await domainClient.from('device').select();
      return res as List<dynamic>;
    } catch (e) {
      log(e.toString());
      throw Exception('Something has been wrong!');
    }
  }

  Future<void> saveDevice({
    required String domain,
    required String name,
    required String brokerId,
    required String? groupId,
    required String topic,
    required int qos,
    required String jsonPath,
    required String? unit,
    String? id,
  }) async {
    try {
      final domainClient = await getSupabaseClient(domain);
      if (id != null) {
        await domainClient.from('device').update({
          'name': name,
          'group_id': groupId,
          'broker_id': brokerId,
          'topic': topic,
          'qos': qos,
          'json_path': jsonPath,
          'unit': unit,
        }).match({'id': id});
      } else {
        await domainClient.from('device').insert({
          'name': name,
          'group_id': groupId,
          'broker_id': brokerId,
          'topic': topic,
          'qos': qos,
          'json_path': jsonPath,
          'unit': unit,
        });
      }
    } catch (e) {
      log(e.toString());
      throw Exception('Something has been wrong!');
    }
  }

  Future<void> deleteDevice({
    required String domain,
    required String id,
  }) async {
    try {
      final domainClient = await getSupabaseClient(domain);
      await domainClient.from('device').delete().match({'id': id});
    } catch (e) {
      log(e.toString());
      throw Exception('Something has been wrong!');
    }
  }

  Stream<dynamic> dashboard(String domain) {
    final domainClient = createSupabaseClient(domain);
    return domainClient.from('dashboard').stream(primaryKey: ['id']);
  }

  Future<void> saveDashboard({
    required String domain,
    required String name,
    required String? id,
  }) async {
    try {
      final domainClient = await getSupabaseClient(domain);
      if (id != null) {
        await domainClient
            .from('dashboard')
            .update({'name': name}).match({'id': id});
      } else {
        await domainClient.from('dashboard').insert({'name': name});
      }
    } catch (e) {
      log(e.toString());
      throw Exception('Something has been wrong!');
    }
  }

  Future<void> deleteDashboard({
    required String domain,
    required String id,
  }) async {
    try {
      final domainClient = await getSupabaseClient(domain);
      await domainClient.from('dashboard').delete().match({'id': id});
    } catch (e) {
      log(e.toString());
      throw Exception('Something has been wrong!');
    }
  }

  Stream<dynamic> tile(String domain) {
    final domainClient = createSupabaseClient(domain);
    return domainClient.from('tile').stream(primaryKey: ['id']);
  }

  Future<void> saveTile({
    required String domain,
    required String name,
    required String dashboardId,
    required String deviceId,
    required String type,
    required String lob,
    String? id,
  }) async {
    try {
      final domainClient = await getSupabaseClient(domain);
      if (id != null) {
        await domainClient.from('tile').update({
          'name': name,
          'dashboard_id': dashboardId,
          'device_id': deviceId,
          'type': type,
          'lob': lob,
        }).match({'id': id});
      } else {
        await domainClient.from('tile').insert({
          'name': name,
          'dashboard_id': dashboardId,
          'device_id': deviceId,
          'type': type,
          'lob': lob,
        });
      }
    } catch (e) {
      log(e.toString());
      throw Exception('Something has been wrong!');
    }
  }

  Future<void> deleteTile({
    required String domain,
    required String id,
  }) async {
    try {
      final domainClient = await getSupabaseClient(domain);
      await domainClient.from('tile').delete().match({'id': id});
    } catch (e) {
      log(e.toString());
      throw Exception('Something has been wrong!');
    }
  }

  Stream<dynamic> alert(String domain) {
    final domainClient = createSupabaseClient(domain);
    return domainClient.from('alert').stream(primaryKey: ['id']);
  }

  Future<void> saveAlert({
    required String domain,
    required String name,
    required String deviceId,
    required bool relate,
    required String lvalue,
    required String rvalue,
    String? id,
  }) async {
    try {
      final domainClient = await getSupabaseClient(domain);
      if (id != null) {
        await domainClient.from('alert').update({
          'name': name,
          'device_id': deviceId,
          'relate': relate,
          'lvalue': lvalue,
          'rvalue': rvalue,
        }).match({'id': id});
      } else {
        await domainClient.from('alert').insert({
          'name': name,
          'device_id': deviceId,
          'relate': relate,
          'lvalue': lvalue,
          'rvalue': rvalue,
        });
      }
    } catch (e) {
      log(e.toString());
      throw Exception('Something has been wrong!');
    }
  }

  Future<void> deleteAlert({
    required String domain,
    required String id,
  }) async {
    try {
      final domainClient = await getSupabaseClient(domain);
      await domainClient.from('alert').delete().match({'id': id});
    } catch (e) {
      log(e.toString());
      throw Exception('Something has been wrong!');
    }
  }

  Stream<dynamic> alertRecord(String domain) {
    final domainClient = createSupabaseClient(domain);
    return domainClient.from('alert_record').stream(primaryKey: ['id']);
  }

  Future<void> saveAlertRecord({
    required String domain,
    required String alertId,
    required DateTime time,
    required String value,
    String? id,
  }) async {
    try {
      final domainClient = await getSupabaseClient(domain);
      if (id != null) {
        await domainClient.from('alert_record').update({
          'alert_id': alertId,
          'time': time.toIso8601String(),
          'value': value,
        }).match({'id': id});
      } else {
        await domainClient.from('alert_record').insert({
          'alert_id': alertId,
          'time': time.toIso8601String(),
          'value': value,
        });
      }
      print('save alert record successful');
    } catch (e) {
      log(e.toString());
      throw Exception('Something has been wrong!');
    }
  }

  Stream<dynamic> record(String domain) {
    final domainClient = createSupabaseClient(domain);
    return domainClient.from('record').stream(primaryKey: ['id']);
  }

  Future<void> saveRecord({
    required String domain,
    required String deviceId,
    required DateTime time,
    required String value,
    String? id,
  }) async {
    try {
      final domainClient = await getSupabaseClient(domain);
      if (id != null) {
        await domainClient.from('record').update({
          'device_id': deviceId,
          'time': time.toIso8601String(),
          'value': value,
        }).match({'id': id});
      } else {
        await domainClient.from('record').insert({
          'device_id': deviceId,
          'time': time.toIso8601String(),
          'value': value,
        });
      }
      print('save record successful');
    } catch (e) {
      log(e.toString());
      throw Exception('Something has been wrong!');
    }
  }
}

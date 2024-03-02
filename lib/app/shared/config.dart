import 'package:credible/app/interop/didkit/didkit.dart';
import 'package:credible/app/interop/secure_storage/secure_storage.dart';
import 'package:credible/app/pages/profile/models/config.dart';
import 'package:credible/app/shared/constants.dart';

class FFIConfig {
  Future<int> get_root_event_time() async {
    final rootEventTime = (await SecureStorageProvider.instance
        .get(ConfigModel.rootEventTimeKey))!;
    try {
      return int.parse(rootEventTime);
    } on FormatException {
      throw StateError('Please set the root event date on the Settings page.');
    }
  }

  Future<String> get_trustchain_endpoint() async {
    return (await SecureStorageProvider.instance
        .get(ConfigModel.trustchainEndpointKey))!;
  }

  Future<String> get_did() async {
    final didIonMethod =
        await SecureStorageProvider.instance.get(ConfigModel.didIonMethodKey) ??
            'false';
    final didKey =
        await SecureStorageProvider.instance.get(ConfigModel.didKeyKey) ?? '';
    final didIon =
        await SecureStorageProvider.instance.get(ConfigModel.didIonKey) ?? '';
    return didIonMethod == 'false' ? didKey : didIon;
  }

  Future<Map<String, Map<dynamic, dynamic>>> get_ffi_config() async {
    var ffiConfig = Constants.ffiConfig;
    ffiConfig['trustchainOptions']!['rootEventTime'] =
        await get_root_event_time();
    final trustchainEndpoint = await get_trustchain_endpoint();
    try {
      final trustchainEndpointUri = Uri.parse(trustchainEndpoint);
      // Ensure scheme is HTTP or HTTPS
      assert(trustchainEndpointUri.isScheme('HTTP') ||
          trustchainEndpointUri.isScheme('HTTPS'));
      ffiConfig['endpointOptions']!['trustchainEndpoint']!['host'] =
          trustchainEndpointUri.scheme + '://' + trustchainEndpointUri.host;
      ffiConfig['endpointOptions']!['trustchainEndpoint']!['port'] =
          trustchainEndpointUri.port;
      return ffiConfig;
    } catch (e) {
      throw StateError('''Invalid Trustchain endpoint:\n\n$trustchainEndpoint
      \nPlease update on the Settings page.''');
    }
  }
}

var ffi_config_instance = FFIConfig();

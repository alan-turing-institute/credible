import 'package:credible/app/pages/profile/models/root.dart';

class ConfigModel {
  static const String didIonMethodKey = 'config/didIonMethod';
  final String didIonMethod;

  static const String didKeyKey = 'config/didKey';
  final String didKey;

  static const String didIonKey = 'config/didIon';
  final String didIon;

  static const String trustchainEndpointKey = 'config/trustchainEndpoint';
  final String trustchainEndpoint;

  static const String rootEventDateKey = 'config/rootEventDate';
  final String rootEventDate; // TODO: should be DateTime?

  static const String confirmationCodeKey = 'config/confirmationCode';
  final String confirmationCode;

  static const String rootDidKey = 'config/rootDid';
  final String rootDid;

  static const String rootTxidKey = 'config/rootTxid';
  final String rootTxid;

  static const String rootBlockHeightKey = 'config/rootBlockHeight';
  final String rootBlockHeight; // TODO: should be int?

  static const String rootEventTimeKey = 'config/rootEventTime';
  final String rootEventTime; // TODO: should be int?

  const ConfigModel({
    this.didIon = '',
    this.didKey = '',
    this.didIonMethod = 'false',
    this.trustchainEndpoint = '',
    this.rootEventDate = '',
    this.confirmationCode = '',
    this.rootDid = '',
    this.rootTxid = '',
    this.rootBlockHeight = '',
    this.rootEventTime = '',
  });

  String did() {
    return didIonMethod == 'false' ? didKey : didIon;
  }
}

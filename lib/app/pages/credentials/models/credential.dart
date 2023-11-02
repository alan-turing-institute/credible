import 'dart:io';
import 'dart:convert';

import 'package:credible/app/interop/secure_storage/secure_storage.dart';
import 'package:credible/app/interop/trustchain/trustchain.dart';
import 'package:credible/app/pages/credentials/models/credential_status.dart';
import 'package:credible/app/shared/config.dart';
import 'package:credible/app/shared/constants.dart';
import 'package:credible/app/shared/globals.dart';
import 'package:uuid/uuid.dart';

class CredentialModel {
  final String id;
  final String? alias;
  final String? image;
  final Map<String, dynamic> data;

  String get issuer => data['issuer']!;

  DateTime? get expirationDate => (data['expirationDate'] != null)
      ? DateTime.parse(data['expirationDate'])
      : null;

  CredentialStatus get status {
    if (expirationDate == null) {
      return CredentialStatus.active;
    }

    return expirationDate!.isAfter(DateTime.now())
        ? CredentialStatus.active
        : CredentialStatus.expired;
  }

  Map<String, dynamic> get details {
    // Remove the jsonld context to avoid overcomplicating things for human viewers
    return stripContext(data);
  }

  const CredentialModel({
    required this.id,
    required this.alias,
    required this.image,
    required this.data,
  });

  factory CredentialModel.fromMap(Map<String, dynamic> m) {
    assert(m.containsKey('data'));

    final data = m['data'] as Map<String, dynamic>;
    assert(data.containsKey('issuer'));

    assert(data.containsKey('credentialSubject'));
    assert(data['credentialSubject'].containsKey('id'));

    return CredentialModel(
      id: m['id'] ?? Uuid().v4(),
      alias: m['alias'],
      image: m['image'],
      data: data,
    );
  }

  Map<String, dynamic> toMap() =>
      {'id': id, 'alias': alias, 'image': image, 'data': data};

  String subjectDid() {
    return data['credentialSubject']['id'];
  }

  String asPresentation() {
    return jsonEncode({
      '@context': ['https://www.w3.org/2018/credentials/v1'],
      'type': ['VerifiablePresentation'],
      'holder': subjectDid(),
      'verifiableCredential': data
    });
  }

  Future<String> asVP() async {
    final ffiConfig = await ffi_config_instance.get_ffi_config();
    // TODO: replace 'key' with constant
    final key = (await SecureStorageProvider.instance.get('key'))!;
    final presentation = await trustchain_ffi.vpIssuePresentation(
        presentation: asPresentation(),
        opts: jsonEncode(ffiConfig),
        jwkJson: key);
    return presentation;
  }

  // Converts the credential to TinyVP format by serializing as JSON,
  // gzipping and then base64 encoding.
  Future<String> asTinyVP() async {
    final vp = await asVP();
    final utf8_encoded = utf8.encode(vp);
    final gzipped = gzip.encode(utf8_encoded);
    final jsonStr = {'type': Constants.tinyVP, 'data': base64.encode(gzipped)};
    return jsonStr.toString();
  }

  factory CredentialModel.fromTinyVP(dynamic data) {
    final gzipped = base64.decode(data);
    final utf8_encoded = gzip.decode(gzipped);
    final json = utf8.decode(utf8_encoded);
    // return json;
    final m = {'data': json};
    return CredentialModel.fromMap(m);
  }
}

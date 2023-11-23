import 'dart:developer';
import 'dart:io';
import 'dart:convert';

import 'package:credible/app/interop/secure_storage/secure_storage.dart';
import 'package:credible/app/interop/trustchain/trustchain.dart';
import 'package:credible/app/pages/credentials/models/credential_status.dart';
import 'package:credible/app/shared/config.dart';
import 'package:credible/app/shared/constants.dart';
import 'package:credible/app/shared/globals.dart';
import 'package:uuid/uuid.dart';
import 'package:canonical_json/canonical_json.dart';

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

  Future<String> asVp() async {
    final ffiConfig = await ffi_config_instance.get_ffi_config();
    // TODO: replace 'key' with constant
    final key = (await SecureStorageProvider.instance.get('key'))!;
    final vp = await trustchain_ffi.vpIssuePresentation(
        presentation: asPresentation(),
        opts: jsonEncode(ffiConfig),
        jwkJson: key);
    final bytes = canonicalJson.encode(vp);
    final canonical_vp = canonicalJson.decode(bytes).toString();
    // print('-----------asVP-----------');
    // log(canonical_vp);
    // print('-----------asVP-----------');
    // print('Length in bytes:');
    // print(canonical_vp.codeUnits.length);
    return canonical_vp;
  }

  factory CredentialModel.fromVp(String vp) {
    final map = jsonDecode(vp);
    assert(map.containsKey('verifiableCredential'));
    final data = map['verifiableCredential'];
    assert(data.containsKey('id'));
    final id = data['id'];
    return CredentialModel.fromMap({'data': data, 'id': id});
  }

  // Converts the credential to TinyVP format by serializing as
  // canonical JSON, gzipping, base64 encoding & then placing the
  // result as data in a map with standardized keys.
  Future<String> asTinyVp() async {
    final vp = await asVp();
    final bytes = canonicalJson.encode(vp);
    final gzipped = gzip.encode(bytes);
    final data = base64.encode(gzipped);
    final map = {'type': Constants.tinyVP, 'data': data};
    final jsonStr = jsonEncode(map);
    // print('-----------asTinyVP-----------');
    // log(jsonStr.toString());
    // print('-----------asTinyVP-----------');
    // print('Length in bytes:');
    // print(jsonStr.toString().codeUnits.length);
    return jsonStr.toString();
  }

  // Deserializes a credential from TinyVP format by extracting data
  // from a map with standardized keys, base64 decoding, gzip decoding
  // & then decoding the resulting canonical JSON.
  factory CredentialModel.fromTinyVp(String tinyVp) {
    final map = jsonDecode(tinyVp);
    assert(map.containsKey('type'));
    assert(map['type'].toString() == Constants.tinyVP);
    assert(map.containsKey('data'));
    final data = map['data'];
    final gzipped = base64.decode(data);
    final bytes = gzip.decode(gzipped);
    final json = canonicalJson.decode(bytes);
    return CredentialModel.fromVp(json.toString());
  }
}

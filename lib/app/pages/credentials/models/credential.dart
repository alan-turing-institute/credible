import 'dart:io';
import 'dart:convert';

import 'package:credible/app/pages/credentials/models/credential_status.dart';
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

    return CredentialModel(
      id: m['id'] ?? Uuid().v4(),
      alias: m['alias'],
      image: m['image'],
      data: data,
    );
  }

  Map<String, dynamic> toMap() =>
      {'id': id, 'alias': alias, 'image': image, 'data': data};

  // Converts the credential to TinyVP format by serializing as JSON,
  // gzipping and then base64 encoding.
  String asTinyVP() {
    final json = jsonEncode(data);
    final utf8_encoded = utf8.encode(json);
    final gzipped = gzip.encode(utf8_encoded);
    return base64.encode(gzipped);
  }
}

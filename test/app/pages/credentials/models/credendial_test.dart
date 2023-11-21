import 'dart:io';

import 'package:credible/app/pages/credentials/models/credential.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CredentialModel', () {
    test('.toMap() encodes to map', () {
      final credential = CredentialModel(
          id: 'uuid', alias: null, image: 'image', data: {'issuer': 'did:...'});
      final m = credential.toMap();

      expect(
          m,
          equals({
            'id': 'uuid',
            'alias': null,
            'image': 'image',
            'data': {'issuer': 'did:...'}
          }));
    });

    test('.fromMap() with only data field should generate an id', () {
      final m = {
        'data': {
          'issuer': 'did:...',
          'credentialSubject': {'id': 'did:...'}
        }
      };
      final credential = CredentialModel.fromMap(m);
      expect(credential.id, isNotEmpty);
      expect(credential.data, equals(m['data']));
    });

    test('.fromMap() with id should not generate a new id', () {
      final m = {
        'id': 'uuid',
        'data': {
          'issuer': 'did:...',
          'credentialSubject': {'id': 'did:...'}
        }
      };
      final credential = CredentialModel.fromMap(m);
      expect(credential.id, equals('uuid'));
    });

    test('.fromVp() decodes a VP JSON', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final str = File('test/data/vp_example.json').readAsStringSync();
      final credential = CredentialModel.fromVp(str);
      expect(credential.subjectDid(),
          equals('did:key:z6MkexqqxoDx6TcAfzL3AK66Xgej9H71wug6fY3dH1jgfFyM'));
      expect(credential.id,
          equals('urn:uuid:481935de-f93d-11ed-a309-d7ec1d02e89c'));
    });

    test('.fromTinyVp() decodes a TinyVP JSON', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final str = File('test/data/tinyvp_example.json').readAsStringSync();
      final credential = CredentialModel.fromTinyVp(str);
      expect(credential.subjectDid(),
          equals('did:key:z6MkexqqxoDx6TcAfzL3AK66Xgej9H71wug6fY3dH1jgfFyM'));
      expect(credential.id,
          equals('urn:uuid:481935de-f93d-11ed-a309-d7ec1d02e89c'));
    });
  });
}

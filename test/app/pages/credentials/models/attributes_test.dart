import 'dart:io';
import 'dart:convert';
import 'package:credible/app/pages/attributes/models/attributes.dart';
import 'package:flutter_test/flutter_test.dart';

final attributesExample =
    jsonDecode(File('test/data/attributes_example.json').readAsStringSync());

void main() {
  group('AttributesModel', () {
    test('.fromMap() constructor works', () {
      final model = AttributesModel.fromMap(attributesExample, sep: '|');

      expect(model.attributes.length, equals(7));
      expect(model.attributes[0],
          equals(AttributeModel('degree|college', 'University of Oxbridge')));
      expect(model.attributes[1],
          equals(AttributeModel('degree|name', 'Bachelor of Arts')));
      expect(model.attributes[2],
          equals(AttributeModel('degree|type', 'BachelorDegree')));
      expect(model.attributes[3],
          equals(AttributeModel('degree|fellowships|royalSociety', 'junior')));
      expect(
          model.attributes[4],
          equals(AttributeModel(
              'degree|fellowships|nationalMuseum', 'associate')));
      expect(
          model.attributes[5], equals(AttributeModel('familyName', 'Bloggs')));
      expect(model.attributes[6], equals(AttributeModel('givenName', 'Jane')));
    });

    test('.topLevelKeys() extracts the right prefix', () {
      const sep = '|';
      final model = AttributesModel.fromMap(attributesExample, sep: sep);
      var prefix = '';
      var result = model.topLevelKeys(prefix);
      expect(result, equals({'degree', 'familyName', 'givenName'}));

      prefix = 'degree' + sep;
      result = model.topLevelKeys(prefix);
      expect(result, equals({'college', 'name', 'type', 'fellowships'}));

      prefix = 'degree' + sep + 'fellowships' + sep;
      result = model.topLevelKeys(prefix);
      expect(result, equals({'royalSociety', 'nationalMuseum'}));
    });

    test('.isSubMapKey() determines whether a key represents a submap', () {
      const sep = '|';
      final model = AttributesModel.fromMap(attributesExample, sep: sep);
      var prefix = '';
      var result = model.isSubMapKey('degree', prefix);
      expect(result, equals(true));
      result = model.isSubMapKey('familyName', prefix);
      expect(result, equals(false));
      result = model.isSubMapKey('givenName', prefix);
      expect(result, equals(false));
      result = model.isSubMapKey('xyz', prefix);
      expect(result, equals(false));

      prefix = 'degree' + sep;
      result = model.isSubMapKey('college', prefix);
      expect(result, equals(false));
      result = model.isSubMapKey('name', prefix);
      expect(result, equals(false));
      result = model.isSubMapKey('type', prefix);
      expect(result, equals(false));
      result = model.isSubMapKey('fellowships', prefix);
      expect(result, equals(true));

      prefix = 'degree' + sep + 'fellowships' + sep;
      result = model.isSubMapKey('royalSociety', prefix);
      expect(result, equals(false));
      result = model.isSubMapKey('nationalMuseum', prefix);
      expect(result, equals(false));
    });

    test('.toMap() inverts fromMap()', () {
      final model = AttributesModel.fromMap(attributesExample, sep: '|');
      var result = model.toMap();
      expect(result, equals(attributesExample));
    });
  });
}

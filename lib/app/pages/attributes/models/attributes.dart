import 'dart:collection';
import 'dart:math';

// typedef AttributeModel = MapEntry<String, String>;

class AttributeModel implements MapEntry<String, String?> {
  @override
  final String key;
  @override
  final String? value;

  const AttributeModel(this.key, this.value);

  @override
  bool operator ==(Object other) =>
      other is AttributeModel && other.key == key && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

// Encodes a map of attributes as a list of key-value pairs in which
// submap structure is encoded by concatenating the keys.
class AttributesModel {
  final List<AttributeModel> attributes;
  final String sep;

  // Private constructor ensures all construction is via fromMap().
  AttributesModel._(this.attributes, this.sep);

  factory AttributesModel.fromMap(Map<String, dynamic> m, {sep = '|'}) {
    var attributes =
        _append(m, '', List<AttributeModel>.empty(growable: true), sep);
    return AttributesModel._(attributes, sep);
  }

  int length() {
    return attributes.length;
  }

  static List<AttributeModel> _append(Map<String, dynamic> m, String prefix,
      List<AttributeModel> list, String sep) {
    for (var k in m.keys) {
      if (k.contains(sep)) {
        throw ArgumentError(
            'attribute key must not contain separator character');
      }
      if (!(m[k] is Map)) {
        list.add(AttributeModel(prefix + k, m[k].toString()));
      } else {
        list = _append(m[k], prefix + k + sep, list, sep);
      }
    }
    return list;
  }

  // Extracts the set of keys at the top level after the prefix.
  Set<String> topLevelKeys(String prefix) {
    return attributes
        .where((attrModel) => attrModel.key.startsWith(prefix))
        .map(
            (attrModel) => attrModel.key.replaceFirst(prefix, '').split(sep)[0])
        .toSet();
  }

  // Determines whether the top level key, after the prefix, represents a submap.
  bool isSubMapKey(String k, String prefix) {
    return attributes
            .where((attrModel) => attrModel.key.startsWith(prefix + k))
            .length >
        1;
  }

  // Assumes at most one matching element, which will always be true when
  // the AtributesModel is constructed using fromMap(), because nested structure
  // is represented by concatenated keys (plus separators).
  // Throws StateError if there is no attribute with matching key.
  // Throws runtime exception if the value is null.
  String? _getValue(String key, String prefix) {
    return attributes
        .firstWhere((attrModel) => attrModel.key == prefix + key)
        .value;
  }

  HashMap<String, dynamic> _toMap(String prefix) {
    var map = HashMap<String, dynamic>();
    var topLevel = topLevelKeys(prefix);
    for (var k in topLevel) {
      if (isSubMapKey(k, prefix)) {
        // Add the key to the map and recurse on the substructure.
        map[k] = _toMap(prefix + k + sep);
      } else {
        // Add the key to the map, with the value in the corresponding attribute.
        map[k] = _getValue(k, prefix);
      }
    }
    return map;
  }

  HashMap<String, dynamic> toMap() {
    return _toMap('');
  }

  // Constructs a new AttributesModel with all values masked (null) except
  // those at the selected indices.
  AttributesModel mask(Set<int> selection) {
    var list = List<AttributeModel>.from(attributes, growable: false);
    if (selection.reduce(min) < 0 || selection.reduce(max) >= list.length) {
      throw ArgumentError('Selection out of range');
    }
    var indices = [for (var i = 0; i < list.length; i++) i];
    for (var index in indices.toSet().difference(selection)) {
      list[index] = AttributeModel(list[index].key, null);
    }
    return AttributesModel._(list, sep);
  }
}

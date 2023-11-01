import 'dart:convert';
import 'dart:io';
import 'package:credible/app/shared/config.dart';
import 'package:credible/app/interop/trustchain/trustchain.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:path_provider/path_provider.dart';

void initializeSpv(String path) async {
  try {
    await trustchain_ffi.spvInitialize(
      path: path,
      testnet: true,
      logLevel: 'Info',
    );
  } on FfiException catch (err) {
    // TODO [#39]: Handle specific error cases
    print(err);
  }
}

Future<int?> getTipSpv(String path) async {
  try {
    var tip = await trustchain_ffi.spvGetTip(
      path: path,
      testnet: true,
    );
    print('tip: ' + tip);
    return int.tryParse(tip);
  } on FfiException catch (err) {
    print(err);
    return null;
  }
}

Future<String?> getBlockHeader(String hash, String path) async {
  try {
    var header = await trustchain_ffi.spvGetBlockHeader(
      hash: hash,
      path: path,
      testnet: true,
    );
    print('header: ' + header);
    return header;
  } on FfiException catch (err) {
    print(err);
    return null;
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:canonical_json/canonical_json.dart';
import 'package:credible/app/interop/trustchain/trustchain.dart';
import 'package:credible/app/pages/credentials/blocs/scan.dart';
import 'package:credible/app/shared/config.dart';
import 'package:credible/app/shared/constants.dart';
import 'package:credible/app/shared/globals.dart';
import 'package:credible/app/shared/model/message.dart';
import 'package:credible/app/shared/widget/info_dialog.dart';
import 'package:credible/app/shared/widget/json_info_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:logging/logging.dart';

abstract class QRCodeEvent {}

class QRCodeEventHost extends QRCodeEvent {
  final String data;

  QRCodeEventHost(this.data);
}

class QRCodeEventAccept extends QRCodeEvent {
  final Uri uri;

  QRCodeEventAccept(this.uri);
}

abstract class QRCodeState {}

class QRCodeStateWorking extends QRCodeState {}

class QRCodeStateHost extends QRCodeState {
  final Uri uri;
  final bool verified;

  QRCodeStateHost(this.uri, this.verified);
}

class QRCodeStateSuccessTinyVP extends QRCodeState {
  final String presentation;
  QRCodeStateSuccessTinyVP(this.presentation);
}

class QRCodeStateSuccess extends QRCodeState {
  final String route;
  final Uri uri;

  QRCodeStateSuccess(this.route, this.uri);
}

class QRCodeStateUnknown extends QRCodeState {}

class QRCodeStateMessage extends QRCodeState {
  final StateMessage message;

  QRCodeStateMessage(this.message);
}

class QRCodeBloc extends Bloc<QRCodeEvent, QRCodeState> {
  final Dio client;
  final ScanBloc scanBloc;

  QRCodeBloc(
    this.client,
    this.scanBloc,
  ) : super(QRCodeStateWorking()) {
    on<QRCodeEventHost>((event, emit) => _host(event).forEach(emit));
    on<QRCodeEventAccept>((event, emit) => _accept(event).forEach(emit));
  }

  Stream<QRCodeState> _host(
    QRCodeEventHost event,
  ) async* {
    late final uri;

    try {
      // Decode JSON string
      final qrcodeJson = jsonDecode(event.data);
      // final pres_mock =
      //     '''{"type":"TinyVP","data":"H4sIAAAAAAAAA6VVXXOiSBR9n1+Rcl6jofkUn1bxCzUq0ZjoZotqoJVWaEx3gyFT+e8LSiIms1O7s1VUid3nnnv7ntOXyo9vV1dPlT/ciHD0wp8qjas/s5V8zed8zxo3N4fDoXaQahHd3IgCqN+4FHmIcAwDdpOAp0oG/+v6yMLTPSozLBDFawydAE0pYlkM5Dgi5YjkA2F8sOYMPwqGr3X9l8quv0ZI2DviEy94L74o5usBLo9QLvBMbLII1AUgtSnOzsJG2EWEoc+858JmsbNFLj+fMd/GXv7/qeJhr7FDaeNVvd3txFufLEekfwvCg1sfrJKHoX/gjztjDJnWXSydJhgBGj/Kjv5vCjrny1HkqAQMME9PqVsUc8z8M1OO2mQUxCYwRCfQABJ0iVjDEAdpCdIKos2GXYIwYzEmG9uNYsJpkfB+eAlyMOW+7UFeEAFdqVcFrQq0SxzcIBsTO0WQshypKp93T0w5IN/Peb7m2QfQLRKNIuLlpiyDvMiNw0wwm8Shg048oiQrqlbXy7jM1TgX1nY/Gvkzug8Y9LzsnZWR11d5Jwrw2/H37d02eeNO2U/eyCRrcMR4o4Pbs44YdG5VhSxp53mRWBPFkJi79HcJGIar12dhJuBVOB6ugfVezIkQEhe1P9osCqJUBaAqSHMgNxQhe2p1SVMAEHRxdY7c0yhaX7r2/bI8VTqux+AMuXtRUXdghjeZvWKKsjt5Yc0jxzSm+4gVgZAxRHMn3iLuR14ZfJoMLizv/s8+fAePB4Po3eHsGfY786nW5gK5H5kecnoP/eZ4ofemQm853RqgWS4lu71Zv7xfN0zTJF1alcO2h0JolA58p+fiCR50719NMN4xPDIGWzcMBHO7d8zQFMfGwMvW8Hhr4Um48p3+OFhbtZrTnT1I91YcI6g838EBfxlVm4K9MLS0J93PnkHVngO/iqIk2tB2d7qWjO2caIn8MFFkfW0H7eiAvbv9Y2sNLV2eOPKml1iF4XK7vZ0G8Sd9L9T1REUBelnW+idjXIoacz8fdm4x7d+Rv1L0d6be998dk/+gKNDmQG0oYkNWa5IsAFmS1HrpCvxUz1Xnbm7NTGaG4xQ+ZtoFDC+3S8EMBHbS1VRXYZe54kKv1Zjekgew158RPkKDVE9iPukuFWqlavIitFxxUKVDK9pBmIZ9a1LV11aT1k1qRL1FG/F1UzaWE1WltlCn+zhIfcKk1uaoZqGjHwVeeWT83ufk21vlb80unFAZCAAA"}''';
      // final qrcodeJson = jsonDecode(pres_mock);
      // Check for TinyVP case
      try {
        assert(qrcodeJson.containsKey('type'));
        final type = qrcodeJson['type'];
        if (type == Constants.tinyVP) {
          assert(qrcodeJson.containsKey('data'));
          // TODO: move to proper place.
          // Deserialize presentation:
          final tinyVP = qrcodeJson['data'];
          final gzipped = base64.decode(tinyVP);
          final bytes = gzip.decode(gzipped);
          final presentation = canonicalJson.decode(bytes).toString();

          // // TODO: check holder field
          // final did = jsonDecode(presentation.toString())['holder'];
          // final opts = jsonEncode(await ffi_config_instance.get_ffi_config());

          // Modulear
          yield QRCodeStateSuccessTinyVP(presentation);

          // try {
          //   await trustchain_ffi.vpVerifyPresentation(
          //       presentation: presentation.toString(), opts: opts);
          //   print(presentation);
          //   // TODO: create new page to display verification outcome & attributes.
          //   print('verified TINY VP!');
          //   yield QRCodeStateMessage(StateMessage.success('VERIFIED TINY VP!'));
          // } on FfiException {
          //   yield QRCodeStateMessage(
          //       StateMessage.error('Failed verification of $did'));
          // }
        }
      } catch (err) {
        final String did = qrcodeJson['did'];
        final String route = qrcodeJson['route'];
        final String uuid = qrcodeJson['id'];
        // Verify DID first with FFI call
        final ffiConfig = await ffi_config_instance.get_ffi_config();
        try {
          await trustchain_ffi.didVerify(did: did, opts: jsonEncode(ffiConfig));
        } on FfiException {
          yield QRCodeStateMessage(
              StateMessage.error('Failed verification of $did'));
        }
        // Resolve DID
        final didModel = await resolveDid(did);
        final endpoint =
            extractEndpoint(didModel.data['didDocument'], '#TrustchainHTTP')!;
        uri = Uri.parse(endpoint + route + uuid);
        yield QRCodeStateHost(uri, true);
      }
    } on FormatException catch (e) {
      try {
        print(e.message);
        uri = Uri.parse(event.data);
        yield QRCodeStateHost(uri, false);
      } on FormatException catch (e) {
        print(e.message);
        yield QRCodeStateMessage(StateMessage.error(
            'This QRCode does not contain a valid message.'));
      }
    } catch (e) {
      print(e);
      yield QRCodeStateMessage(
          StateMessage.error('This QRCode does not contain a valid message.'));
    }
  }

  Stream<QRCodeState> _accept(
    QRCodeEventAccept event,
  ) async* {
    final log = Logger('credible/qrcode/accept');

    late final data;

    try {
      final url = event.uri.toString();
      final response = await client.get(url);
      data =
          response.data is String ? jsonDecode(response.data) : response.data;
    } on DioError catch (e) {
      log.severe('An error occurred while connecting to the server.', e);

      yield QRCodeStateMessage(StateMessage.error(
          'An error occurred while connecting to the server. '
          'Check the logs for more information.'));
    }

    scanBloc.add(ScanEventShowPreview(data));

    switch (data['type']) {
      case 'CredentialOffer':
        yield QRCodeStateSuccess('/credentials/receive', event.uri);
        break;

      case 'VerifiablePresentationRequest':
        yield QRCodeStateSuccess('/credentials/present', event.uri);
        break;

      default:
        yield QRCodeStateUnknown();
        break;
    }
    yield QRCodeStateWorking();
  }
}

Stream<void> handleTinyVp(qrcodeJson) async* {
  print('1: --------------------------------------------------------');
  print(qrcodeJson);
  print('--------------------------------------------------------');
  // assert(qrcodeJson.contains('type'));
  // final type = qrcodeJson['type'];
  // switch (type) {
  //   case Constants.tinyVP:
  assert(qrcodeJson.contains('data'));
  // TODO: move to proper place.
  // Deserialize presentation:
  print('2: --------------------------------------------------------');
  print(qrcodeJson);
  print('--------------------------------------------------------');
  final tinyVP = qrcodeJson['data'];
  final gzipped = base64.decode(tinyVP);
  final utf8_encoded = gzip.decode(gzipped);
  final presentation = utf8.decode(utf8_encoded);
  // TODO: pass presentation to PresentationViewer.

  // TODO: check holder field
  final did = jsonDecode(presentation)['holder'];
  final opts = jsonEncode(await ffi_config_instance.get_ffi_config());
  try {
    await trustchain_ffi.vpVerifyPresentation(
        presentation: presentation, opts: opts);
    print(presentation);
    // TODO: create new page to display verification outcome & attributes.
    print('--------------------------------------------------------');
    print('--------------------------------------------------------');
    print('verified TINY VP!');
    yield QRCodeStateMessage(StateMessage.success('VERIFIED TINY VP!'));
    print('--------------------------------------------------------');
    print('--------------------------------------------------------');
  } on FfiException {
    yield QRCodeStateMessage(
        StateMessage.error('Failed verification of VP from holder $did'));
    //   }
    //   break;
    // default:
    //   throw FormatException('Invalid type: $type');
  }
}

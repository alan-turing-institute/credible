import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:credible/app/interop/trustchain/trustchain.dart';
import 'package:credible/app/pages/credentials/blocs/scan.dart';
import 'package:credible/app/shared/config.dart';
import 'package:credible/app/shared/constants.dart';
import 'package:credible/app/shared/globals.dart';
import 'package:credible/app/shared/model/message.dart';
import 'package:dio/dio.dart';
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

      // Handle TinyVP case
      try {
        print('1: --------------------------------------------------------');
        print(qrcodeJson);
        print('--------------------------------------------------------');
        assert(qrcodeJson.contains('type'));
        final type = qrcodeJson['type'];
        switch (type) {
          case Constants.tinyVP:
            assert(qrcodeJson.contains('data'));
            // TODO: move to proper place.
            // Deserialize presentation:
            print(
                '2: --------------------------------------------------------');
            print(qrcodeJson);
            print('--------------------------------------------------------');
            final tinyVP = qrcodeJson['data'];
            final gzipped = base64.decode(tinyVP);
            final utf8_encoded = gzip.decode(gzipped);
            final presentation = utf8.decode(utf8_encoded);
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
              yield QRCodeStateMessage(
                  StateMessage.success('VERIFIED TINY VP!'));
              print('--------------------------------------------------------');
              print('--------------------------------------------------------');
            } on FfiException {
              yield QRCodeStateMessage(
                  StateMessage.error('Failed verification of $did'));
            }
            break;
          default:
            throw FormatException('Invalid type: $type');
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

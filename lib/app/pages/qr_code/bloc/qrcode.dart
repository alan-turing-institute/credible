import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:canonical_json/canonical_json.dart';
import 'package:credible/app/interop/trustchain/trustchain.dart';
import 'package:credible/app/pages/credentials/blocs/scan.dart';
import 'package:credible/app/pages/qr_code/scan.dart';
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

class QRCodeStateService extends QRCodeState {
  final Uri uri;
  final bool verified;
  final ServiceType type;

  QRCodeStateService(this.uri, this.verified, this.type);
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

  final _log = Logger('credible/qrcode_bloc');

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

    // Decode the JSON string
    try {
      final qrcodeJson = jsonDecode(event.data);
      // Handle the Trustchain-specific case of TinyVP.
      if (qrcodeJson.containsKey(Constants.tinyVP)) {
        yield handleTinyVp(qrcodeJson);
      } else {
        // Handle the generic case of a DID service.
        yield await handleService(qrcodeJson);
      }
    } on DioError catch (e) {
      yield QRCodeStateMessage(StateMessage.error(
          // Trustchain endpoint (server) is unreachable.
          '''Failed to reach the Trustchain endpoint.
          \n\nPlease check your network connection.
          \n\nThe server may be offline. Please try again later.'''));
    } catch (e) {
      yield QRCodeStateMessage(StateMessage.error(
          // TODO: improve errors/error messages.
          // In particular, handle the case that the root event date is set but the
          // Trustchain endpoint (server) is unreachable.
          e.toString().replaceAll(RegExp('^[^:]*:'), '').trimLeft()));
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

// Handle the specific case of a QR-encoded, compressed Verifiable Presentation.
  QRCodeState handleTinyVp(qrcodeJson) {
    // Deserialize the verifiable presentation.
    final tinyVP = qrcodeJson[Constants.tinyVP];
    final gzipped = base64.decode(tinyVP);
    final bytes = gzip.decode(gzipped);
    final presentation = canonicalJson.decode(bytes).toString();

    // // TODO: check holder field
    // final did = jsonDecode(presentation.toString())['holder'];
    // final opts = jsonEncode(await ffi_config_instance.get_ffi_config());
    return QRCodeStateSuccessTinyVP(presentation);
  }

// Handle the generic case of a QR-encoded DID service.
  Future<QRCodeState> handleService(qrcodeJson) async {
    // Extract the DID and service id from the QR code JSON.
    assert(qrcodeJson.containsKey('did'));
    assert(qrcodeJson.containsKey('service'));
    final String did = qrcodeJson['did'];
    final String service = qrcodeJson['service'][0] == '#'
        ? qrcodeJson['service']
        : '#' + qrcodeJson['service'];

    // Verify the DID with an FFI call.
    final ffiConfig = await ffi_config_instance.get_ffi_config();
    dynamic verified = false;
    try {
      await trustchain_ffi.didVerify(did: did, opts: jsonEncode(ffiConfig));
      verified = true;
    } on FfiException {
      _log.info('Failed verification of $did');
    }
    // Resolve the verified DID.
    final didModel = await resolveDid(did);

    // Extract the service endpoint and the service type.
    final endpoint = extractEndpoint(didModel.data['didDocument'], service)!;
    final type = extractServiceType(didModel.data['didDocument'], service)!;
    try {
      ServiceType.values.byName(type);
    } on ArgumentError {
      return QRCodeStateMessage(
          StateMessage.error('DID service type not handled: $type'));
    }

    // TODO: handle the case that the DID document does not contain a service with the given id.

    // Construct the URI from the service endpoint and relative ref.
    final uri = qrcodeJson.containsKey('relativeRef')
        ? endpoint + qrcodeJson['relativeRef']
        : endpoint;

    return QRCodeStateService(
        Uri.parse(uri), verified, ServiceType.values.byName(type));
  }
}

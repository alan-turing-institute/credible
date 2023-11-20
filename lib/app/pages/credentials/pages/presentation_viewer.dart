import 'dart:convert';

import 'package:credible/app/interop/didkit/didkit.dart';
import 'package:credible/app/interop/trustchain/trustchain.dart';
import 'package:credible/app/pages/credentials/blocs/wallet.dart';
import 'package:credible/app/pages/credentials/models/credential.dart';
import 'package:credible/app/pages/credentials/models/credential_display.dart';
import 'package:credible/app/pages/credentials/models/verification_state.dart';
import 'package:credible/app/pages/credentials/widget/credential.dart';
import 'package:credible/app/pages/credentials/widget/document.dart';
import 'package:credible/app/shared/config.dart';
import 'package:credible/app/shared/constants.dart';
import 'package:credible/app/shared/ui/ui.dart';
import 'package:credible/app/shared/widget/back_leading_button.dart';
import 'package:credible/app/shared/widget/base/button.dart';
import 'package:credible/app/shared/widget/base/page.dart';
import 'package:credible/app/shared/widget/confirm_dialog.dart';
import 'package:credible/app/shared/widget/text_field_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_json_viewer/flutter_json_viewer.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logging/logging.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PresentationViewer extends StatefulWidget {
  final String item;

  const PresentationViewer({Key? key, required this.item}) : super(key: key);

  @override
  _PresentationViewerState createState() => _PresentationViewerState();
}

class _PresentationViewerState
    extends ModularState<PresentationViewer, WalletBloc> {
  bool showShareMenu = false;
  dynamic issuerDidDocument;
  VerificationState verification = VerificationState.Unverified;

  final logger = Logger('credible/presentation/view');

  @override
  void initState() {
    super.initState();
    verify();
  }

  void verify() async {
    print(widget.item);
    final json = jsonDecode(widget.item);
    assert(json.containsKey('holder'));
    final opts = jsonEncode(await ffi_config_instance.get_ffi_config());
    try {
      await trustchain_ffi.vpVerifyPresentation(
          presentation: widget.item, opts: opts);
      // print(widget.item);
      // TODO: create new page to display verification outcome & attributes.
      print('--------------------------------------------------------');
      print('--------------------------------------------------------');
      print('verified TINY VP!');
      // yield QRCodeStateMessage(StateMessage.success('VERIFIED TINY VP!'));
      print('--------------------------------------------------------');
      print('--------------------------------------------------------');
      setState(() {
        verification = VerificationState.Verified;
      });
    } on FfiException catch (err) {
      // yield QRCodeStateMessage(
      //     StateMessage.error('Failed verification of VP from holder $did'));
      print(err);
      setState(() {
        verification = VerificationState.VerifiedWithError;
      });
    }

    // final vcStr = jsonEncode(widget.item.data);
    // // Modify FFI config as required
    // final ffiConfig = await ffi_config_instance.get_ffi_config();
    // print(jsonEncode(ffiConfig));
    // // final optStr = jsonEncode({'proofPurpose': 'assertionMethod'});
    // try {
    //   await trustchain_ffi.vcVerifyCredential(
    //       credential: vcStr, opts: jsonEncode(ffiConfig));
    //   setState(() {
    //     verification = VerificationState.Verified;
    //   });
    // } on FfiException catch (err) {
    //   // TODO [#39]: Handle specific error cases
    //   print(err);
    //   setState(() {
    //     verification = VerificationState.VerifiedWithError;
    //   });
    // }
  }

  IconButton handleBackButton() {
    return IconButton(
      onPressed: () {
        if (kDebugMode) {
          // Emulator: go to list
          Modular.to.pushReplacementNamed('/credentials/list');
        } else {
          // Release mode: return to scanner
          Modular.to.pushReplacementNamed('/qr-code/scan');
        }
      },
      icon: Icon(
        Icons.arrow_back,
        color: UiKit.palette.icon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Add proper localization
    final localizations = AppLocalizations.of(context)!;

    return BasePage(
      title: 'Presentation',
      titleLeading: handleBackButton(),
      navigation: Container(
        color: UiKit.palette.navBarBackground,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            // TODO: replace all Text buttons with icons.
            children: [],
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 64.0),
          if (verification == VerificationState.Unverified)
            Center(child: CircularProgressIndicator())
          else ...<Widget>[
            Center(
              child: Text(
                localizations.credentialDetailStatus,
                style: Theme.of(context).textTheme.overline!,
              ),
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  verification.icon,
                  color: verification.color,
                ),
                const SizedBox(width: 8.0),
                Text(
                  verification.message,
                  style: Theme.of(context)
                      .textTheme
                      .caption!
                      .apply(color: verification.color),
                ),
              ],
            ),
          ],
          const SizedBox(height: 64.0),
        ],
      ),
    );
  }
}

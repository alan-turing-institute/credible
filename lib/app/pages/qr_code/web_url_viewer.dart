import 'package:credible/app/pages/credentials/blocs/wallet.dart';
import 'package:credible/app/pages/credentials/models/verification_state.dart';
import 'package:credible/app/shared/ui/trustchain/palette.dart';
import 'package:credible/app/shared/ui/ui.dart';
import 'package:credible/app/shared/widget/base/button.dart';
import 'package:credible/app/shared/widget/base/page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:logging/logging.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class WebUrlViewer extends StatefulWidget {
  final Uri url;
  final VerificationState verificationState;
  final String did;

  const WebUrlViewer(
      {Key? key,
      required this.url,
      required this.verificationState,
      required this.did})
      : super(key: key);

  @override
  _WebUrlViewerState createState() => _WebUrlViewerState();
}

class _WebUrlViewerState extends ModularState<WebUrlViewer, WalletBloc> {
  bool showShareMenu = false;

  final logger = Logger('credible/web_url/view');

  @override
  void initState() {
    super.initState();
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

  // Launch a uri in the in-app browser.
  Future<bool> _launchURL(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);

      // Wait until the browser closes
      // (see https://github.com/flutter/flutter/issues/57536)
      await Future.delayed(Duration(milliseconds: 100));
      while (
          WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
        await Future.delayed(Duration(milliseconds: 100));
      }
      // await closeInAppWebView();
      return true;
    } else {
      logger.severe('cannot launch url: $uri');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Add proper localization
    final localizations = AppLocalizations.of(context)!;

    return BasePage(
      title: widget.verificationState == VerificationState.Verified
          ? 'Verified URL'
          : 'Unverified URL',
      titleLeading: handleBackButton(),
      navigation: Container(
        color: UiKit.palette.navBarBackground,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [],
          ),
        ),
      ),
      body: widget.verificationState == VerificationState.Verified
          ? bodyVerified(context)
          : bodyUnverified(context),
    );
  }

  Widget bodyVerified(BuildContext context) {
    // TODO: Add proper localization
    final localizations = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: 32.0),
        Text(widget.url.toString(),
            textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 32.0),
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
              widget.verificationState.icon,
              color: widget.verificationState.color,
            ),
            const SizedBox(width: 8.0),
            Text(
              widget.verificationState.message,
              style: Theme.of(context)
                  .textTheme
                  .caption!
                  .apply(color: widget.verificationState.color),
            ),
          ],
        ),
        const SizedBox(height: 32.0),
        BaseButton.primary(
          // Temp URL for testing/demo purposes:
          onPressed: () => _launchURL(Uri.parse('https://www.justpark.com/')),
          // Replace with the following line when not running a demo:
          // onPressed: () => _launchURL(widget.url),
          child: Tooltip(
            message: localizations.credentialDetailShowChainTooltip,
            child: Text(
              'Visit verified URL',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: UiKit.palette.credentialText),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 64.0),
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('The above URL has been successfully verified.',
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 16.0),
            Text('If you wish to view the chain of attestations, click below.',
                overflow: TextOverflow.ellipsis),
          ],
        ),
        const SizedBox(height: 32.0),
        BaseButton.primary(
          onPressed: () => Modular.to.pushNamed(
            '/did/chain',
            arguments: [widget.did],
          ),
          child: Tooltip(
            message: localizations.credentialDetailShowChainTooltip,
            child: Text(
              'Show attestation chain',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: UiKit.palette.credentialText),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  // TODO.
  Widget bodyUnverified(BuildContext context) {
    // TODO: Add proper localizations
    final localizations = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: 32.0),
        Text(widget.url.toString(),
            textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 32.0),
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
              widget.verificationState.icon,
              color: widget.verificationState.color,
            ),
            const SizedBox(width: 8.0),
            Text(
              widget.verificationState.message,
              style: Theme.of(context)
                  .textTheme
                  .caption!
                  .apply(color: widget.verificationState.color),
            ),
          ],
        ),
        const SizedBox(height: 64.0),
        Column(
          mainAxisSize:
              MainAxisSize.min, // Not max, else the layout throws an error.
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('The above URL failed the verification process.',
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 16.0),
            Flexible(
              child: Text(
                  'You are advised NOT to trust this link. It may be a QR code scam.'),
            ),
            const SizedBox(height: 16.0),
            // Temp additional message for testing/demo purposes:
            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  const TextSpan(
                    text: 'Learn more about QR code scams in this ',
                    // TODO: fix the text style in these TextSpan widgets.
                    style: TextStyle(color: TrustchainPalette.text),
                  ),
                  TextSpan(
                    text: 'BBC video',
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => _launchURL(Uri.parse(
                          'https://www.bbc.co.uk/programmes/articles/2ds8k78dDqJbrLz6SnbqBw0/qr-code-scams')),
                  ),
                  const TextSpan(
                    text: '.',
                    style: TextStyle(color: TrustchainPalette.text),
                  )
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:credible/app/pages/credentials/models/credential.dart';
import 'package:credible/app/shared/ui/ui.dart';
import 'package:credible/app/shared/widget/back_leading_button.dart';
import 'package:credible/app/shared/widget/base/page.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class QrCodeDisplayPage extends StatefulWidget {
  final CredentialModel credentialModel;

  QrCodeDisplayPage({Key? key, required this.credentialModel})
      : super(key: key);

  @override
  State<QrCodeDisplayPage> createState() => _QrCodeDisplayPageState();
}

class _QrCodeDisplayPageState extends State<QrCodeDisplayPage> {
  String tinyVP = '';

  @override
  void initState() {
    super.initState();
    setTinyVP();
  }

  void setTinyVP() async {
    final _tinyVP = await widget.credentialModel.asTinyVp();
    setState(() {
      tinyVP = _tinyVP;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return BasePage(
      title: ' ',
      titleLeading: BackLeadingButton(),
      scrollView: false,
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    localizations.qrCodeSharing,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    widget.credentialModel.id,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.caption,
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(32.0),
                    child: QrImage(
                        data: tinyVP,
                        version: QrVersions.auto,
                        foregroundColor: Colors.black // UiKit.palette.icon,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

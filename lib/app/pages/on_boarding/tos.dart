import 'package:credible/app/shared/ui/ui.dart';
import 'package:credible/app/shared/widget/app_version.dart';
import 'package:credible/app/shared/widget/base/button.dart';
import 'package:credible/app/shared/widget/base/page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OnBoardingTosPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final scrollController = ScrollController();

    return BasePage(
      title: localizations.onBoardingTosTitle,
      scrollView: false,
      padding: EdgeInsets.zero,
      useSafeArea: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 32.0),
          AppVersion(),
          const SizedBox(height: 16.0),
          Expanded(
            child: Scrollbar(
              isAlwaysShown: true,
              controller: scrollController,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 16.0,
                ),
                controller: scrollController,
                child: Center(
                  child: Text(
                    // TODO: add to localizations.
                    "This software is provided 'as is', without any express or implied warranty. In no event shall the authors or copyright holders be liable for any claim, damages or other liability arising from or out of or in connection with the software or its use.",
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                // child: SelectableText(
                //   '',
                //   style: Theme.of(context).textTheme.bodyText2,
                // ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: UiKit.palette.navBarBackground,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: UiKit.palette.shadow,
                  offset: Offset(-1.0, -1.0),
                  blurRadius: 4.0,
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      localizations.onBoardingTosText,
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                    const SizedBox(height: 20.0),
                    BaseButton.primary(
                      onPressed: () {
                        Modular.to.pushReplacementNamed('/on-boarding/key');
                      },
                      child: Text(localizations.onBoardingTosButton),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
